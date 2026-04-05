/**
 * Geofencing + Socket.io: track_location, grace 5 phút, auto check-in/out.
 * Trạng thái timer: một bản ghi / nhân viên (Map), tránh tạo vô hạn timer.
 */

const jwt = require('jsonwebtoken');
const db = require('../config/database');
const { QueryTypes } = require('sequelize');
const {
  haversineDistanceMeters,
  impliedSpeedMetersPerSecond,
  isWeakGpsAccuracy,
} = require('../utils/geoUtils');
const { fetchWorkLocation, fetchTodayAttendance, checkInEmployee, checkOutEmployee } = require('./attendanceActions');

const GRACE_MS = 5 * 60 * 1000;
const HARD_BUFFER_M = 300;
const MAX_SPEED_MPS = 40;
const ACCURACY_WARN_M = 80;

const AUTO_CHECKOUT_NOTE = 'Tự động checkout do rời vị trí';
const AUTO_CHECKOUT_NOTE_HARD = 'Tự động checkout do rời xa vùng làm việc';

/** @type {Map<string, { last?: { lat, lng, t, accuracy? }, graceTimer?: ReturnType<typeof setTimeout>, leaveWarningSent?: boolean }>} */
const employeeTrackState = new Map();

function clearGraceTimer(employeeId) {
  const st = employeeTrackState.get(employeeId);
  if (!st) return;
  if (st.graceTimer) clearTimeout(st.graceTimer);
  employeeTrackState.set(employeeId, {
    ...st,
    graceTimer: undefined,
    leaveWarningSent: false,
  });
}

function setState(employeeId, partial) {
  const prev = employeeTrackState.get(employeeId) || {};
  employeeTrackState.set(employeeId, { ...prev, ...partial });
}

async function resolveEmployeeIdFromToken(token) {
  if (!token || typeof token !== 'string') {
    throw new Error('Thiếu token');
  }
  const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your_jwt_secret');
  const rows = await db.query(
    `SELECT employee_id FROM user_account WHERE id = :uid AND status = 'active' LIMIT 1`,
    { replacements: { uid: decoded.id }, type: QueryTypes.SELECT }
  );
  if (!rows?.length) throw new Error('Không tìm thấy tài khoản');
  return rows[0].employee_id;
}

function branchRoom(branchId) {
  return branchId != null ? `branch_${String(branchId)}` : null;
}

function emitManagerAlert(io, branchId, payload) {
  const room = branchRoom(branchId);
  if (io && room) io.to(room).emit('geofence_manager_alert', payload);
}

function emitEmployee(io, employeeId, event, payload) {
  if (io) io.to(`employee_${employeeId}`).emit(event, payload);
}

/**
 * Xử lý một điểm vị trí từ mobile.
 */
async function processTrackLocation(io, employeeId, payload) {
  const lat = Number(payload?.latitude);
  const lng = Number(payload?.longitude);
  const accuracy = payload?.accuracy != null ? Number(payload.accuracy) : null;
  const now = Date.now();

  if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
    emitEmployee(io, employeeId, 'tracking_error', { message: 'latitude/longitude không hợp lệ' });
    return;
  }

  const prevState = employeeTrackState.get(employeeId) || {};
  const prev = prevState.last;

  if (prev) {
    const dtMs = now - prev.t;
    const speed =
      dtMs > 5 * 60 * 1000
        ? null
        : impliedSpeedMetersPerSecond(
            { lat: prev.lat, lng: prev.lng, t: prev.t },
            { lat, lng, t: now }
          );
    if (speed != null && speed > MAX_SPEED_MPS) {
      const workLocation = await fetchWorkLocation(employeeId);
      emitManagerAlert(io, workLocation?.branch_id, {
        type: 'speed_anomaly',
        severity: 'warning',
        employee_id: employeeId,
        implied_speed_mps: Number(speed.toFixed(2)),
        max_allowed_mps: MAX_SPEED_MPS,
        message: 'Vị trí di chuyển bất thường (tốc độ ước lượng quá cao giữa hai lần gửi).',
      });
    }
  }

  if (isWeakGpsAccuracy(accuracy, ACCURACY_WARN_M)) {
    const workLocation = await fetchWorkLocation(employeeId);
    emitManagerAlert(io, workLocation?.branch_id, {
      type: 'poor_accuracy',
      severity: 'info',
      employee_id: employeeId,
      accuracy_meters: accuracy,
      message: 'Độ chính xác GPS thấp — có nguy cơ sai lệch vị trí.',
    });
  }

  setState(employeeId, { last: { lat, lng, t: now, accuracy } });

  const workLocation = await fetchWorkLocation(employeeId);
  if (!workLocation) {
    emitEmployee(io, employeeId, 'tracking_error', { message: 'Chưa cấu hình địa điểm chấm công' });
    return;
  }

  const centerLat = Number(workLocation.latitude);
  const centerLng = Number(workLocation.longitude);
  const radius = workLocation.radius_meters == null ? 100 : Number(workLocation.radius_meters);
  const dist = haversineDistanceMeters(lat, lng, centerLat, centerLng);
  const inside = dist <= radius;
  const beyondHard = dist > radius + HARD_BUFFER_M;

  const attendance = await fetchTodayAttendance(employeeId);
  const hasCheckIn = Boolean(attendance?.check_in_time);
  const hasCheckOut = Boolean(attendance?.check_out_time);

  // --- Auto check-in: chưa vào ca, đang trong vùng ---
  if (!hasCheckIn && inside) {
    clearGraceTimer(employeeId);
    const result = await checkInEmployee(employeeId, lat, lng, {
      deviceIp: 'socket:geofence',
      io,
      skipGeofenceValidation: true,
      skipWifiIpValidation: true,
    });
    if (result.ok) {
      emitEmployee(io, employeeId, 'geofence_auto_checkin', {
        message: 'Đã tự động check-in khi vào vùng chấm công.',
        data: result.data,
      });
    }
    return;
  }

  if (!hasCheckIn && !inside) {
    return;
  }

  if (hasCheckOut) {
    clearGraceTimer(employeeId);
    return;
  }

  // --- Đã check-in, chưa check-out ---
  if (inside) {
    clearGraceTimer(employeeId);
    return;
  }

  // Ra khỏi vùng
  if (beyondHard) {
    clearGraceTimer(employeeId);
    const out = await checkOutEmployee(employeeId, lat, lng, {
      deviceIp: 'socket:geofence',
      io,
      skipGeofenceValidation: true,
      skipWifiIpValidation: true,
      checkOutNote: AUTO_CHECKOUT_NOTE_HARD,
    });
    if (out.ok) {
      emitEmployee(io, employeeId, 'geofence_auto_checkout', {
        message: AUTO_CHECKOUT_NOTE_HARD,
        data: out.data,
      });
    }
    clearGraceTimer(employeeId);
    return;
  }

  // Ngoài vùng nhưng chưa vượt ngưỡng cứng → grace 5 phút
  const st = employeeTrackState.get(employeeId) || {};
  if (!st.leaveWarningSent) {
    setState(employeeId, { leaveWarningSent: true });
    emitEmployee(io, employeeId, 'geofence_leave_warning', {
      message: 'Bạn đã ra khỏi vùng chấm công, vui lòng quay lại trong 5 phút',
      grace_ms: GRACE_MS,
      distance_meters: Number(dist.toFixed(2)),
      radius_meters: radius,
    });
  }

  if (!st.graceTimer) {
    const timer = setTimeout(async () => {
      try {
        const latest = employeeTrackState.get(employeeId);
        const last = latest?.last;
        if (!last) return;

        const att = await fetchTodayAttendance(employeeId);
        if (!att?.check_in_time || att.check_out_time) {
          clearGraceTimer(employeeId);
          return;
        }

        const wl = await fetchWorkLocation(employeeId);
        if (!wl) return;
        const cLat = Number(wl.latitude);
        const cLng = Number(wl.longitude);
        const R = wl.radius_meters == null ? 100 : Number(wl.radius_meters);
        const d = haversineDistanceMeters(last.lat, last.lng, cLat, cLng);

        if (d <= R) {
          clearGraceTimer(employeeId);
          return;
        }

        const out = await checkOutEmployee(employeeId, last.lat, last.lng, {
          deviceIp: 'socket:geofence:grace',
          io,
          skipGeofenceValidation: true,
          skipWifiIpValidation: true,
          checkOutNote: AUTO_CHECKOUT_NOTE,
        });
        if (out.ok) {
          emitEmployee(io, employeeId, 'geofence_auto_checkout', {
            message: AUTO_CHECKOUT_NOTE,
            data: out.data,
          });
        }
        clearGraceTimer(employeeId);
      } catch (e) {
        console.error('[geofence] grace checkout error:', e);
      }
    }, GRACE_MS);

    setState(employeeId, { graceTimer: timer, leaveWarningSent: true });
  }
}

function registerGeofencingSocket(io) {
  io.on('connection', (socket) => {
    socket.on('authenticate_tracking', async (payload, ack) => {
      try {
        const token = payload?.token;
        const employeeId = await resolveEmployeeIdFromToken(token);
        socket.data.employeeId = employeeId;
        socket.join(`employee_${employeeId}`);

        const wl = await fetchWorkLocation(employeeId);
        const room = branchRoom(wl?.branch_id);
        if (room) socket.join(room);

        const reply = { ok: true, employee_id: employeeId, branch_id: wl?.branch_id ?? null };
        if (typeof ack === 'function') ack(reply);
        socket.emit('tracking_authenticated', reply);
      } catch (e) {
        console.warn('[geofence] authenticate_tracking failed:', e.message);
        const err = { ok: false, message: e.message || 'Xác thực thất bại' };
        if (typeof ack === 'function') ack(err);
        socket.emit('tracking_error', err);
      }
    });

    socket.on('track_location', async (payload) => {
      const employeeId = socket.data.employeeId;
      if (!employeeId) {
        socket.emit('tracking_error', { message: 'Chưa xác thực (authenticate_tracking).' });
        return;
      }
      try {
        await processTrackLocation(io, employeeId, payload || {});
        const lat = Number(payload?.latitude);
        const lng = Number(payload?.longitude);
        if (Number.isFinite(lat) && Number.isFinite(lng)) {
          io.emit('employee_location_update', {
            user_id: employeeId,
            employee_id: employeeId,
            latitude: lat,
            longitude: lng,
            timestamp: typeof payload?.timestamp === 'number' ? payload.timestamp : Date.now(),
            accuracy: payload?.accuracy != null ? Number(payload.accuracy) : undefined,
          });
        }
      } catch (e) {
        console.error('[geofence] track_location error:', e);
        socket.emit('tracking_error', { message: e.message || 'Lỗi xử lý vị trí' });
      }
    });

    socket.on('disconnect', () => {
      // Giữ grace timer theo employeeId — không hủy khi socket rớt (mobile có thể tạm ngắt).
    });
  });

  console.log('[Geofence] Socket handlers đã đăng ký (authenticate_tracking, track_location)');
}

module.exports = {
  registerGeofencingSocket,
  processTrackLocation,
  employeeTrackState,
  GRACE_MS,
  HARD_BUFFER_M,
};
