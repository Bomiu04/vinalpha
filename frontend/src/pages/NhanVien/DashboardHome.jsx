import React from 'react';
import './DashboardHome.css';

const DashboardHome = () => {
  return (
    <div className="dashboard-container">
      <div className="dashboard-main-grid">
        {/* KHỐI TRÁI: ĐIỂM DANH */}
        <div className="main-checkin-card">
          <div className="checkin-left">
            <h4>Thứ Ba, 17 tháng 3, 2026</h4>
            <h2>7:55 AM</h2>
            <div className="status-tag">✓ Bạn đang đến sớm 5 phút</div>
            <p style={{fontSize: '12px', color: '#9ca3af', marginTop: '10px'}}>● Tọa độ GPS sẵn sàng</p>
          </div>
          <button className="btn-checkin-circle">
            ĐIỂM DANH VÀO
            <div style={{fontSize: '10px', fontWeight: 'normal', marginTop: '5px'}}>Trạng thái: Chưa Check-in</div>
          </button>
        </div>

        {/* KHỐI PHẢI: CA LÀM VIỆC */}
        <div className="info-card">
          <h4 style={{marginBottom: '20px'}}>Ca làm việc hôm nay</h4>
          <div className="info-row">
            <span>Giờ vào ca</span>
            <span>08:00 AM</span>
          </div>
          <div className="info-row">
            <span>Giờ ra ca</span>
            <span>05:00 PM</span>
          </div>
          <hr style={{border: 'none', borderTop: '1px solid #eee', margin: '15px 0'}} />
          <div className="info-row">
            <span>Thời gian còn lại</span>
            <span style={{color: '#3b82f6'}}>8h 5m</span>
          </div>
        </div>
      </div>

      {/* HÀNG 3 CARD THỐNG KÊ */}
      <div className="stats-row">
        <div className="stat-box">
          <p style={{fontSize: '12px', color: '#6b7280'}}>Ngày công tháng này</p>
          <h3 style={{fontSize: '24px', margin: '10px 0'}}>12</h3>
        </div>
        <div className="stat-box">
          <p style={{fontSize: '12px', color: '#6b7280'}}>Đi trễ / Về sớm</p>
          <h3 style={{fontSize: '24px', margin: '10px 0', color: '#f59e0b'}}>02</h3>
        </div>
        <div className="stat-box">
          <p style={{fontSize: '12px', color: '#6b7280'}}>Ngày vắng mặt</p>
          <h3 style={{fontSize: '24px', margin: '10px 0', color: '#ef4444'}}>0</h3>
        </div>
      </div>
    </div>
  );
};

export default DashboardHome;