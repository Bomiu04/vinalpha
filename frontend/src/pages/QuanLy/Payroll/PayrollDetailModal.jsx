import React from 'react';

// Hàm format số nguyên
const fmt = (val) => new Intl.NumberFormat('vi-VN').format(Math.round(val || 0));

const PayrollDetailModal = ({ data, onClose }) => {
  if (!data) return null;

  const normalizeStatus = (status) => {
    if (!status) return { label: 'Không dữ liệu', rowClass: 'bg-gray-100 text-gray-500' };

    switch (status) {
      case 'on_time':
        return { label: 'Đủ công', rowClass: 'bg-emerald-50 text-emerald-700' };
      case 'late':
        return { label: 'Đi muộn', rowClass: 'bg-amber-50 text-amber-700' };
      case 'early_leave':
        return { label: 'Về sớm', rowClass: 'bg-orange-50 text-orange-700' };
      case 'absent':
        return { label: 'Vắng', rowClass: 'bg-red-50 text-red-700' };
      case 'future':
        return { label: 'Chưa tới ngày', rowClass: 'bg-gray-100 text-gray-500' };
      default:
        return { label: status, rowClass: 'bg-slate-50 text-slate-700' };
    }
  };

  const attendanceDetail = Array.isArray(data.attendance_detail) ? data.attendance_detail : [];

  return (
    // FIX ZOOM 1: z-[9999] để đè lên mọi Sidebar/Header, bg full màn hình
    <div className="fixed inset-0 z-[9999] overflow-y-auto bg-[#f4f6f8] custom-scrollbar">
      
      {/* Container căn giữa */}
      <div className="min-h-screen p-4 md:p-6 lg:p-8 flex justify-center items-start">
        
        {/* FIX ZOOM 2: w-full max-w-[1400px] overflow-hidden ép khung không bung quá màn hình */}
        <div className="bg-white w-full max-w-[1400px] rounded-2xl shadow-lg border border-gray-100 p-5 md:p-8 flex flex-col gap-8 md:gap-10 overflow-hidden relative">
          
          {/* HEADER */}
          <div className="flex justify-between items-center pb-2 md:pb-4">
            <h1 className="text-xl md:text-2xl font-black text-gray-800">Chi Tiết Tính Lương</h1>
            <button 
              onClick={onClose} 
              className="bg-[#3b82f6] hover:bg-blue-600 text-white px-5 py-2.5 rounded-lg text-sm font-semibold transition-all active:scale-95 shadow-sm whitespace-nowrap"
            >
              Quay Lại
            </button>
          </div>

          {/* 1. THÔNG TIN NHÂN VIÊN */}
          <section className="w-full">
            <h2 className="text-base md:text-lg font-bold text-gray-800 mb-4">Thông Tin Nhân Viên</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 w-full">
              <InfoCard label="MÃ NHÂN VIÊN" value={data.employee_code} />
              <InfoCard label="TÊN" value={data.full_name} />
              <InfoCard label="PHÒNG BAN" value={data.department_name} />
              <InfoCard label="CHỨC VỤ" value={data.position_name || 'Nhân Viên'} />
            </div>
          </section>

          {/* 2. CHI TIẾT LƯƠNG */}
          <section className="w-full max-w-full">
            <h2 className="text-base md:text-lg font-bold text-gray-800 mb-4">Chi Tiết Lương</h2>
            
            {/* FIX ZOOM 3: w-full overflow-x-auto giúp cuộn ngang mượt mà khi màn hình hẹp/zoom to */}
            <div className="w-full overflow-x-auto border border-gray-100 rounded-lg custom-scrollbar">
              <table className="w-full min-w-max text-center text-sm whitespace-nowrap">
                <thead className="bg-[#f8f9fa] text-gray-600 font-semibold border-b border-gray-200">
                  <tr>
                    <th className="py-4 px-4 font-semibold text-[13px]">Thu nhập tháng</th>
                    <th className="py-4 px-4 font-semibold text-[13px]">Số ngày công</th>
                    <th className="py-4 px-4 font-semibold text-[13px]">Tăng ca</th>
                    <th className="py-4 px-4 font-semibold text-[13px]">Kỷ luật</th>
                    <th className="py-4 px-4 font-semibold text-[13px]">Thưởng</th>
                    <th className="py-4 px-4 font-semibold text-[13px]">BHXH DN</th>
                    <th className="py-4 px-4 font-semibold text-[13px]">BHXH NLĐ</th>
                    <th className="py-4 px-4 font-semibold text-[13px]">Thu nhập sau BH</th>
                    <th className="py-4 px-4 font-semibold text-[13px]">Doanh Nghiệp Đóng Thuế</th>
                    <th className="py-4 px-4 font-semibold text-[13px]">Chi phí tiền lương</th>
                  </tr>
                </thead>
                <tbody className="text-gray-800">
                  <tr>
                    <td className="py-5 px-4">{fmt(data.actual_salary)}</td>
                    <td className="py-5 px-4">{data.total_work_days}</td>
                    <td className="py-5 px-4">{data.overtime > 0 ? fmt(data.overtime) : '0'}</td>
                    <td className="py-5 px-4">{data.discipline > 0 ? fmt(data.discipline) : '0'}</td>
                    <td className="py-5 px-4 bg-gray-50/50 font-bold">{fmt(data.reward)}</td>
                    <td className="py-5 px-4">{fmt(data.compInsurance?.total)}</td>
                    <td className="py-5 px-4">{fmt(data.empInsurance?.total)}</td>
                    <td className="py-5 px-4">{fmt(data.income_after_insurance)}</td>
                    <td className="py-5 px-4">{fmt(data.compInsurance?.total)}</td>
                    <td className="py-5 px-4">{fmt(data.company_cost)}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </section>

          {/* 3. CHI TIẾT NGÀY CÔNG */}
          <section className="pb-8 w-full max-w-full">
            <h2 className="text-base md:text-lg font-bold text-gray-800 mb-4">Chi Tiết Ngày Công</h2>
            
            {/* FIX ZOOM 4: Giống bảng lương, bọc cuộn ngang và khóa min-w-max */}
            <div className="w-full overflow-x-auto border border-gray-100 rounded-lg custom-scrollbar">
              <table className="w-full min-w-[800px] text-center text-sm whitespace-nowrap">
                <thead className="bg-[#f8f9fa] text-gray-600 font-semibold border-b border-gray-200">
                  <tr>
                    <th className="py-4 px-6 text-left font-semibold text-[13px]">Ngày</th>
                    <th className="py-4 px-4 font-semibold text-[13px]">Check In</th>
                    <th className="py-4 px-4 font-semibold text-[13px]">Check Out</th>
                    <th className="py-4 px-4 font-semibold text-[13px]">Số giờ</th>
                    <th className="py-4 px-4 font-semibold text-[13px]">Công</th>
                    <th className="py-4 px-4 font-semibold text-[13px]">Tăng Ca</th>
                    <th className="py-4 px-4 text-left font-semibold text-[13px]">Trạng thái</th>
                    <th className="py-4 px-6 text-right font-semibold text-[13px]"></th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100 text-gray-700">
                  {attendanceDetail.map((row, idx) => (
                    <tr key={idx} className={`transition-colors ${normalizeStatus(row.status).rowClass}`}>
                      <td className="py-4 px-6 text-left font-bold">{row.day}</td>
                      <td className="py-4 px-4">{row.checkIn || '-'}</td>
                      <td className="py-4 px-4">{row.checkOut || '-'}</td>
                      <td className="py-4 px-4">{row.hours || '-'}</td>
                      <td className="py-4 px-4">{typeof row.cong === 'number' ? row.cong : '-'}</td>
                      
                      <td className="py-4 px-4">
                        {row.ot && Number(row.ot) > 0 ? (
                          <div className="flex flex-col items-center justify-center leading-tight">
                            <span>{row.ot}</span>
                            <span className="text-[11px] text-blue-600 font-semibold">Tăng ca</span>
                          </div>
                        ) : (
                          '-'
                        )}
                      </td>
                      
                      <td className="py-4 px-4 text-left font-bold">
                        {normalizeStatus(row.status).label}
                      </td>
                      
                      <td className="py-4 px-6 text-right">
                        <button className="bg-[#f59e0b] hover:bg-[#ea580c] text-white text-xs font-semibold py-1.5 px-4 rounded transition-colors shadow-sm">
                          Sửa
                        </button>
                      </td>
                    </tr>
                  ))}
                  {attendanceDetail.length === 0 && (
                    <tr>
                      <td colSpan="8" className="py-8 text-center text-gray-400 font-medium">
                        Chưa có dữ liệu chấm công.
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </section>

        </div>
      </div>
    </div>
  );
};

// Component Thẻ thông tin
const InfoCard = ({ label, value }) => (
  <div className="bg-[#fdfbf2] border border-[#f5f0db] rounded-xl py-4 md:py-5 px-4 flex flex-col items-center justify-center w-full shadow-[0_1px_2px_rgba(0,0,0,0.02)]">
    <span className="text-[10px] md:text-[11px] text-gray-500 font-semibold uppercase tracking-widest mb-1.5">{label}</span>
    <span className="text-sm md:text-base font-black text-gray-900 text-center break-words w-full">{value}</span>
  </div>
);

export default PayrollDetailModal;