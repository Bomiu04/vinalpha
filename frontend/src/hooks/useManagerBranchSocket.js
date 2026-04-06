import { useEffect } from 'react';
import { getManagerSocket } from '../services/managerSocket';

/**
 * Khớp backend: join_branch_room(branch_id), geofence_manager_alert, attendance_changed, admin_locations_updated
 * @param {object} opts
 * @param {string|null} opts.branchId — gửi lên server dạng string/number đều được (room branch_${id})
 * @param {string} opts.socketUrl — origin Socket.io (vd http://localhost:5000)
 * @param {() => void} opts.onAttendanceChanged
 * @param {(payload: object) => void} opts.onManagerAlert — geofence_manager_alert
 * @param {() => void} [opts.onAdminLocationsUpdated] — io.emit('admin_locations_updated') từ API cấu hình địa điểm
 * @param {(data: object) => void} [opts.onEmployeeLocationUpdate] — broadcast từ mobile track_location
 * @param {(data: { employee_id: number, secondsRemaining: number|null }) => void} [opts.onEmployeeOutOfZoneTick]
 */
export function useManagerBranchSocket({
  branchId,
  socketUrl,
  onAttendanceChanged,
  onManagerAlert,
  onAdminLocationsUpdated,
  onEmployeeLocationUpdate,
  onEmployeeOutOfZoneTick,
}) {
  useEffect(() => {
    if (!socketUrl || !onAdminLocationsUpdated) return;
    const socket = getManagerSocket(socketUrl);
    const onLoc = () => onAdminLocationsUpdated();
    socket.on('admin_locations_updated', onLoc);
    return () => {
      socket.off('admin_locations_updated', onLoc);
    };
  }, [socketUrl, onAdminLocationsUpdated]);

  useEffect(() => {
    if (!socketUrl || !onEmployeeLocationUpdate) return;
    const socket = getManagerSocket(socketUrl);
    const onTrack = (data) => onEmployeeLocationUpdate(data);
    socket.on('employee_location_update', onTrack);
    return () => {
      socket.off('employee_location_update', onTrack);
    };
  }, [socketUrl, onEmployeeLocationUpdate]);

  useEffect(() => {
    if (branchId == null || branchId === '') return;

    const socket = getManagerSocket(socketUrl);

    const joinRoom = () => {
      socket.emit('join_branch_room', branchId);
    };

    const onAttendance = () => {
      onAttendanceChanged?.();
    };

    const onAlert = (payload) => {
      onManagerAlert?.(payload);
    };

    socket.on('connect', joinRoom);
    if (socket.connected) joinRoom();

    const onOutTick = (data) => {
      onEmployeeOutOfZoneTick?.(data);
    };

    socket.on('attendance_changed', onAttendance);
    socket.on('geofence_manager_alert', onAlert);
    socket.on('employee_out_of_zone_tick', onOutTick);

    return () => {
      socket.off('connect', joinRoom);
      socket.off('attendance_changed', onAttendance);
      socket.off('geofence_manager_alert', onAlert);
      socket.off('employee_out_of_zone_tick', onOutTick);
    };
  }, [branchId, socketUrl, onAttendanceChanged, onManagerAlert, onEmployeeOutOfZoneTick]);
}
