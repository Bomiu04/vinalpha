import React, { useEffect, useState, useCallback } from 'react';
import { Search, Download, RefreshCw, Clock, CheckCircle2, XCircle, AlertCircle } from 'lucide-react';
import axiosClient from '../../api/axiosClient';

const STATUS_MAP = {
  on_time:        { label: 'Đúng giờ',       color: 'bg-green-100 text-green-700' },
  late:           { label: 'Đi muộn',        color: 'bg-yellow-100 text-yellow-700' },
  early_leave:    { label: 'Về sớm',         color: 'bg-orange-100 text-orange-700' },
  late_early_leave:{ label: 'Muộn & Về sớm', color: 'bg-red-100 text-red-700' },
  absent:         { label: 'Vắng mặt',       color: 'bg-gray-100 text-gray-500' },
};

const fmt = (iso) => {
  if (!iso) return '—';
  return new Date(iso).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
};

const fmtDate = (d) => {
  if (!d) return '—';
  const [y, m, day] = d.split('-');
  return `${day}/${m}/${y}`;
};

export default function AdminAttendance() {
  const today = new Date();
  const defaultDate = `${today.getFullYear()}-${String(today.getMonth()+1).padStart(2,'0')}-${String(today.getDate()).padStart(2,'0')}`;

  const [date, setDate] = useState(defaultDate);
  const [search, setSearch] = useState('');
  const [records, setRecords] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const res = await axiosClient.get('/admin/attendance', { params: { date } });
      setRecords(res.data?.data || res.data || []);
    } catch (e) {
      setError(e?.response?.data?.message || 'Không thể tải dữ liệu chấm công.');
    } finally {
      setLoading(false);
    }
  }, [date]);

  useEffect(() => { fetchData(); }, [fetchData]);

  const filtered = records.filter(r =>
    !search || r.full_name?.toLowerCase().includes(search.toLowerCase()) ||
    r.employee_code?.toLowerCase().includes(search.toLowerCase())
  );

  const stats = {
    total: filtered.length,
    onTime: filtered.filter(r => r.status === 'on_time').length,
    late: filtered.filter(r => r.status === 'late' || r.status === 'late_early_leave').length,
    absent: filtered.filter(r => !r.check_in_time).length,
  };

  return (
    <div className="p-6 min-h-screen bg-gray-50">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Quản lý Chấm công</h1>
        <p className="text-gray-500 text-sm mt-1">Xem toàn bộ dữ liệu chấm công của nhân viên theo ngày</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-4 gap-4 mb-6">
        {[
          { label: 'Tổng nhân viên', value: stats.total, icon: <Clock size={20} className="text-blue-500"/>, bg: 'bg-blue-50' },
          { label: 'Đúng giờ', value: stats.onTime, icon: <CheckCircle2 size={20} className="text-green-500"/>, bg: 'bg-green-50' },
          { label: 'Đi muộn', value: stats.late, icon: <AlertCircle size={20} className="text-yellow-500"/>, bg: 'bg-yellow-50' },
          { label: 'Chưa chấm công', value: stats.absent, icon: <XCircle size={20} className="text-red-500"/>, bg: 'bg-red-50' },
        ].map(s => (
          <div key={s.label} className={`${s.bg} rounded-xl p-4 flex items-center gap-3`}>
            {s.icon}
            <div>
              <div className="text-2xl font-bold text-gray-800">{s.value}</div>
              <div className="text-xs text-gray-500">{s.label}</div>
            </div>
          </div>
        ))}
      </div>

      {/* Toolbar */}
      <div className="bg-white rounded-xl shadow-sm p-4 mb-4 flex flex-wrap gap-3 items-center">
        <input
          type="date"
          value={date}
          onChange={e => setDate(e.target.value)}
          className="border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-300"
        />
        <div className="relative flex-1 min-w-[200px]">
          <Search size={16} className="absolute left-3 top-2.5 text-gray-400"/>
          <input
            type="text"
            placeholder="Tìm tên hoặc mã nhân viên..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="w-full pl-9 pr-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-300"
          />
        </div>
        <button
          onClick={fetchData}
          className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors"
        >
          <RefreshCw size={15}/> Làm mới
        </button>
      </div>

      {/* Table */}
      <div className="bg-white rounded-xl shadow-sm overflow-hidden">
        {error && <div className="p-4 text-red-600 text-sm">{error}</div>}
        {loading ? (
          <div className="p-8 text-center text-gray-400">Đang tải...</div>
        ) : (
          <table className="w-full text-sm">
            <thead className="bg-gray-50 border-b border-gray-100">
              <tr>
                {['Mã NV','Họ tên','Phòng ban','Giờ vào','Giờ ra','Giờ công','Trạng thái'].map(h => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {filtered.length === 0 ? (
                <tr><td colSpan={7} className="px-4 py-8 text-center text-gray-400">Không có dữ liệu chấm công ngày {fmtDate(date)}</td></tr>
              ) : filtered.map((r, i) => {
                const st = STATUS_MAP[r.status] || { label: r.status || '—', color: 'bg-gray-100 text-gray-500' };
                return (
                  <tr key={i} className="hover:bg-gray-50 transition-colors">
                    <td className="px-4 py-3 font-mono text-gray-500 text-xs">{r.employee_code}</td>
                    <td className="px-4 py-3 font-semibold text-gray-800">{r.full_name}</td>
                    <td className="px-4 py-3 text-gray-500">{r.department_name || '—'}</td>
                    <td className="px-4 py-3">{r.check_in_time ? <span className="text-green-700 font-medium">{fmt(r.check_in_time)}</span> : <span className="text-gray-300">—</span>}</td>
                    <td className="px-4 py-3">{r.check_out_time ? <span className="text-blue-700 font-medium">{fmt(r.check_out_time)}</span> : <span className="text-gray-300">—</span>}</td>
                    <td className="px-4 py-3 font-medium text-gray-700">{r.total_work_hours != null ? `${Number(r.total_work_hours).toFixed(2)}h` : '—'}</td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${st.color}`}>{st.label}</span>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>

      {filtered.length > 0 && (
        <div className="mt-3 text-xs text-gray-400 text-right">Hiển thị {filtered.length} bản ghi</div>
      )}
    </div>
  );
}
