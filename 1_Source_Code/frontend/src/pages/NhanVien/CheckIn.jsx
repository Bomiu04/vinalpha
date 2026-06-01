import React, { useCallback, useEffect, useMemo, useState } from 'react';
import { Fingerprint, History, Clock, CheckCircle2, XCircle } from 'lucide-react';
import toast from 'react-hot-toast';
import AttendanceHistoryModal from '../../components/AttendanceHistoryModal';
import { attendanceService } from '../../services/attendanceService';

const formatTime = (isoOrTs) => {
  if (!isoOrTs) return '--:--';
  const d = new Date(isoOrTs);
  if (Number.isNaN(d.getTime())) return '--:--';
  return d.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
};

const statusLabel = {
  on_time: 'Đúng giờ',
  late: 'Đi muộn',
  early_leave: 'Về sớm',
  late_early_leave: 'Muộn & Về sớm',
  absent: 'Vắng mặt',
};

const CheckIn = () => {
  const [attendanceToday, setAttendanceToday] = useState({
    checkInTime: null,
    checkOutTime: null,
    status: null,
    totalWorkHours: 0,
  });
  const [actionLoading, setActionLoading] = useState(false);
  const [historyOpen, setHistoryOpen] = useState(false);
  const [historyLoading, setHistoryLoading] = useState(false);
  const [historyError, setHistoryError] = useState('');
  const [historyData, setHistoryData] = useState(null);
  const [monthYear, setMonthYear] = useState(() => {
    const now = new Date();
    return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
  });

  const user = useMemo(() => {
    try {
      return JSON.parse(localStorage.getItem('user') || 'null');
    } catch {
      return null;
    }
  }, []);

  const employeeId = useMemo(() => user?.employee_id || user?.id || null, [user]);

  const canCheckIn = !attendanceToday.checkInTime;
  const canCheckOut = !!attendanceToday.checkInTime && !attendanceToday.checkOutTime;
  const isDone = !!attendanceToday.checkOutTime;

  const fetchSummary = useCallback(async () => {
    if (!employeeId) return;
    try {
      const json = await attendanceService.getSummary(employeeId);
      if (!json?.success) throw new Error(json?.message || 'Không tải được dữ liệu');
      setAttendanceToday(json.data?.attendanceToday || {
        checkInTime: null, checkOutTime: null, status: null, totalWorkHours: 0,
      });
    } catch (err) {
      toast.error(err.message || 'Lỗi tải dữ liệu chấm công');
    }
  }, [employeeId]);

  const fetchHistory = useCallback(async () => {
    if (!employeeId) return;
    const [y, m] = String(monthYear || '').split('-');
    setHistoryLoading(true);
    setHistoryError('');
    try {
      const json = await attendanceService.getHistory(employeeId, {
        month: Number(m), year: Number(y),
      });
      if (!json?.success) throw new Error(json?.message || 'Không tải được lịch sử');
      setHistoryData(json.data || null);
    } catch (err) {
      setHistoryError(err.message || String(err));
    } finally {
      setHistoryLoading(false);
    }
  }, [employeeId, monthYear]);

  useEffect(() => { void fetchSummary(); }, [fetchSummary]);

  const handleCheckIn = async () => {
    if (actionLoading || !canCheckIn) return;
    setActionLoading(true);
    try {
      const json = await attendanceService.checkIn(employeeId, {});
      if (!json?.success) throw new Error(json?.message || 'Lỗi check-in');
      toast.success('Check-in thành công!');
      await fetchSummary();
    } catch (err) {
      toast.error(err.message || 'Lỗi check-in');
    } finally {
      setActionLoading(false);
    }
  };

  const handleCheckOut = async () => {
    if (actionLoading || !canCheckOut) return;
    if (!window.confirm('Xác nhận Check-out?')) return;
    setActionLoading(true);
    try {
      const json = await attendanceService.checkOut(employeeId, {});
      if (!json?.success) throw new Error(json?.message || 'Lỗi check-out');
      toast.success('Check-out thành công!');
      await fetchSummary();
    } catch (err) {
      toast.error(err.message || 'Lỗi check-out');
    } finally {
      setActionLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col items-center justify-center p-4">
      <div className="w-full max-w-sm bg-white rounded-2xl shadow-lg overflow-hidden">

        {/* Header */}
        <div className="bg-blue-600 px-6 py-5 flex items-center justify-between">
          <div>
            <div className="text-white text-xs font-medium opacity-80 uppercase tracking-wide">Chấm công</div>
            <div className="text-white text-lg font-bold mt-0.5">
              {new Date().toLocaleDateString('vi-VN', { weekday: 'long', day: 'numeric', month: 'long' })}
            </div>
          </div>
          <button
            type="button"
            onClick={() => { setHistoryOpen(true); void fetchHistory(); }}
            className="text-white opacity-80 hover:opacity-100 p-2 rounded-full hover:bg-blue-500 transition-colors"
            aria-label="Lịch sử chấm công"
          >
            <History size={22} />
          </button>
        </div>

        {/* Status row */}
        <div className="px-6 py-4 border-b border-gray-100 grid grid-cols-2 gap-4">
          <div className="flex flex-col gap-0.5">
            <span className="text-xs text-gray-400 font-medium">Giờ vào</span>
            <div className="flex items-center gap-1.5">
              <Clock size={14} className={attendanceToday.checkInTime ? 'text-green-500' : 'text-gray-300'} />
              <span className={`text-base font-bold ${attendanceToday.checkInTime ? 'text-gray-800' : 'text-gray-300'}`}>
                {formatTime(attendanceToday.checkInTime)}
              </span>
            </div>
          </div>
          <div className="flex flex-col gap-0.5">
            <span className="text-xs text-gray-400 font-medium">Giờ ra</span>
            <div className="flex items-center gap-1.5">
              <Clock size={14} className={attendanceToday.checkOutTime ? 'text-blue-500' : 'text-gray-300'} />
              <span className={`text-base font-bold ${attendanceToday.checkOutTime ? 'text-gray-800' : 'text-gray-300'}`}>
                {formatTime(attendanceToday.checkOutTime)}
              </span>
            </div>
          </div>
        </div>

        {/* Work hours + status */}
        {isDone && (
          <div className="px-6 py-3 bg-green-50 border-b border-green-100 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <CheckCircle2 size={16} className="text-green-600" />
              <span className="text-sm font-medium text-green-700">
                {statusLabel[attendanceToday.status] || attendanceToday.status || 'Đã chấm công'}
              </span>
            </div>
            <span className="text-sm font-bold text-green-700">
              {Number(attendanceToday.totalWorkHours || 0).toFixed(2)} giờ
            </span>
          </div>
        )}

        {/* Action buttons */}
        <div className="px-6 py-6 flex flex-col gap-3">
          {isDone ? (
            <div className="flex flex-col items-center gap-2 py-4">
              <CheckCircle2 size={48} className="text-green-500" />
              <p className="text-gray-600 font-medium text-center">Bạn đã hoàn tất chấm công hôm nay</p>
            </div>
          ) : canCheckOut ? (
            <>
              <div className="flex items-center gap-2 bg-yellow-50 rounded-lg px-4 py-2.5">
                <Clock size={16} className="text-yellow-600 flex-shrink-0" />
                <span className="text-sm text-yellow-700">
                  Đang trong ca — vào lúc <strong>{formatTime(attendanceToday.checkInTime)}</strong>
                </span>
              </div>
              <button
                type="button"
                onClick={handleCheckOut}
                disabled={actionLoading}
                className="w-full flex items-center justify-center gap-2.5 bg-red-500 hover:bg-red-600 active:bg-red-700 disabled:opacity-60 disabled:cursor-not-allowed text-white font-bold text-base py-4 rounded-xl transition-colors shadow-sm"
              >
                <Fingerprint size={26} />
                {actionLoading ? 'Đang xử lý...' : 'CHECK OUT'}
              </button>
            </>
          ) : (
            <>
              <div className="flex items-center gap-2 bg-blue-50 rounded-lg px-4 py-2.5">
                <XCircle size={16} className="text-blue-500 flex-shrink-0" />
                <span className="text-sm text-blue-700">Bạn chưa bắt đầu ca làm việc hôm nay</span>
              </div>
              <button
                type="button"
                onClick={handleCheckIn}
                disabled={actionLoading}
                className="w-full flex items-center justify-center gap-2.5 bg-blue-600 hover:bg-blue-700 active:bg-blue-800 disabled:opacity-60 disabled:cursor-not-allowed text-white font-bold text-base py-4 rounded-xl transition-colors shadow-sm"
              >
                <Fingerprint size={26} />
                {actionLoading ? 'Đang xử lý...' : 'CHECK IN'}
              </button>
            </>
          )}
        </div>
      </div>

      <AttendanceHistoryModal
        open={historyOpen}
        onClose={() => setHistoryOpen(false)}
        monthYear={monthYear}
        setMonthYear={setMonthYear}
        loading={historyLoading}
        error={historyError}
        data={historyData}
        onSearch={() => void fetchHistory()}
      />
    </div>
  );
};

export default CheckIn;
