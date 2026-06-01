import React, { useEffect, useState } from 'react';
import { Users, CheckCircle2, XCircle, Clock, AlertCircle, ArrowRight } from 'lucide-react';
import axiosClient from '../../api/axiosClient';
import { useNavigate } from 'react-router-dom';

const STATUS_MAP = {
  on_time:         { label: 'Đúng giờ',       color: 'text-green-600',  dot: 'bg-green-500' },
  late:            { label: 'Đi muộn',         color: 'text-yellow-600', dot: 'bg-yellow-500' },
  early_leave:     { label: 'Về sớm',          color: 'text-orange-600', dot: 'bg-orange-500' },
  late_early_leave:{ label: 'Muộn & Về sớm',  color: 'text-red-600',    dot: 'bg-red-500' },
  absent:          { label: 'Vắng mặt',        color: 'text-gray-400',   dot: 'bg-gray-300' },
};

const fmt = (iso) => {
  if (!iso) return '—';
  return new Date(iso).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
};

export default function AdminDashboard() {
  const navigate = useNavigate();
  const today = new Date(new Date().getTime() + 7 * 3600000).toISOString().slice(0, 10);
  const [records, setRecords] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    axiosClient.get('/admin/attendance', { params: { date: today } })
      .then(res => setRecords(res.data?.data || []))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, [today]);

  const checkedIn   = records.filter(r => r.check_in_time);
  const notChecked  = records.filter(r => !r.check_in_time);
  const checkedOut  = records.filter(r => r.check_out_time);
  const onTime      = records.filter(r => r.status === 'on_time');
  const late        = records.filter(r => r.status === 'late' || r.status === 'late_early_leave');

  const [dd, mm, yyyy] = new Date().toLocaleDateString('vi-VN').split('/');

  return (
    <div className="p-6 min-h-screen bg-gray-50">
      {/* Header */}
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Tổng quan chấm công</h1>
          <p className="text-gray-400 text-sm mt-0.5">
            {new Date().toLocaleDateString('vi-VN', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}
          </p>
        </div>
        <button
          onClick={() => navigate('/Admin/attendance')}
          className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors"
        >
          Xem chi tiết <ArrowRight size={16}/>
        </button>
      </div>

      {/* Stat cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        {[
          { label: 'Tổng nhân viên', value: records.length, icon: <Users size={22}/>, bg: 'bg-blue-50', iconColor: 'text-blue-500' },
          { label: 'Đã check-in',    value: checkedIn.length, icon: <CheckCircle2 size={22}/>, bg: 'bg-green-50', iconColor: 'text-green-500' },
          { label: 'Chưa check-in',  value: notChecked.length, icon: <XCircle size={22}/>, bg: 'bg-red-50', iconColor: 'text-red-400' },
          { label: 'Đúng giờ',       value: onTime.length, icon: <Clock size={22}/>, bg: 'bg-purple-50', iconColor: 'text-purple-500' },
        ].map(s => (
          <div key={s.label} className={`${s.bg} rounded-2xl p-5 flex items-center gap-4`}>
            <div className={`${s.iconColor}`}>{s.icon}</div>
            <div>
              <div className="text-3xl font-bold text-gray-800">{loading ? '…' : s.value}</div>
              <div className="text-xs text-gray-500 mt-0.5">{s.label}</div>
            </div>
          </div>
        ))}
      </div>

      {/* Table — top 10 */}
      <div className="bg-white rounded-2xl shadow-sm overflow-hidden">
        <div className="px-5 py-4 border-b border-gray-100 flex items-center justify-between">
          <h2 className="font-semibold text-gray-700">Danh sách chấm công hôm nay</h2>
          {late.length > 0 && (
            <span className="flex items-center gap-1 text-xs text-yellow-600 bg-yellow-50 px-2 py-1 rounded-full">
              <AlertCircle size={12}/> {late.length} người đi muộn
            </span>
          )}
        </div>
        <table className="w-full text-sm">
          <thead className="bg-gray-50">
            <tr>
              {['Nhân viên','Phòng ban','Check-in','Check-out','Giờ công','Trạng thái'].map(h => (
                <th key={h} className="px-4 py-3 text-left text-xs font-semibold text-gray-400 uppercase">{h}</th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-50">
            {loading ? (
              <tr><td colSpan={6} className="py-10 text-center text-gray-300">Đang tải...</td></tr>
            ) : records.length === 0 ? (
              <tr><td colSpan={6} className="py-10 text-center text-gray-300">Chưa có dữ liệu hôm nay</td></tr>
            ) : records.slice(0, 15).map((r, i) => {
              const st = STATUS_MAP[r.status] || STATUS_MAP.absent;
              return (
                <tr key={i} className="hover:bg-gray-50 transition-colors">
                  <td className="px-4 py-3">
                    <div className="font-medium text-gray-800">{r.full_name}</div>
                    <div className="text-xs text-gray-400">{r.employee_code}</div>
                  </td>
                  <td className="px-4 py-3 text-gray-500">{r.department_name || '—'}</td>
                  <td className="px-4 py-3 font-medium text-green-700">{fmt(r.check_in_time)}</td>
                  <td className="px-4 py-3 font-medium text-blue-700">{fmt(r.check_out_time)}</td>
                  <td className="px-4 py-3 text-gray-700">
                    {r.total_work_hours != null ? `${Number(r.total_work_hours).toFixed(2)}h` : '—'}
                  </td>
                  <td className="px-4 py-3">
                    <span className={`flex items-center gap-1.5 text-xs font-medium ${st.color}`}>
                      <span className={`w-1.5 h-1.5 rounded-full ${st.dot}`}/>
                      {r.check_in_time ? st.label : 'Chưa chấm'}
                    </span>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
        {records.length > 15 && (
          <div className="px-5 py-3 border-t border-gray-50 text-center">
            <button onClick={() => navigate('/Admin/attendance')} className="text-blue-600 text-sm hover:underline">
              Xem tất cả {records.length} nhân viên →
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
