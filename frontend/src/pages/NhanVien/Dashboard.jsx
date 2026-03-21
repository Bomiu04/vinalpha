import React, { useEffect, useState } from 'react';

import './Dashboard.css';

const getWorkStatus = (checkInTime, checkOutTime) => {
  const now = new Date();

  const shifts = [
    { name: 'morning', start: 8, end: 12 },
    { name: 'afternoon', start: 13, end: 17 }
  ];

  // ✅ FIX: chọn đúng ca
  const currentShift = shifts.find(shift => {
    const start = new Date();
    start.setHours(shift.start, 0, 0);

    const end = new Date();
    end.setHours(shift.end, 0, 0);

    return now >= start && now <= end;
  });

  if (!currentShift) {
    return { text: 'Hết ca làm', type: 'done', canCheckIn: false };
  }

  const start = new Date();
  start.setHours(currentShift.start, 0, 0);

  const end = new Date();
  end.setHours(currentShift.end, 0, 0);

  if (!checkInTime) {
    const diff = Math.floor((now - start) / 60000);

    if (diff < 0) {
      return {
        text: `Bạn đang đến sớm ${Math.abs(diff)} phút`,
        type: 'success',
        canCheckIn: true
      };
    } else {
      return {
        text: `Bạn đã đi trễ ${diff} phút`,
        type: 'danger',
        canCheckIn: true
      };
    }
  }

  if (checkInTime && !checkOutTime) {
    const diff = Math.floor((end - now) / 60000);

    return {
      text:
        diff > 0
          ? `Còn ${diff} phút để checkout`
          : `Quá giờ ${Math.abs(diff)} phút`,
      type: diff > 0 ? 'warning' : 'danger',
      canCheckIn: false
    };
  }

  return {
    text: 'Đã hoàn thành ca',
    type: 'done',
    canCheckIn: false
  };
};

const Dashboard = () => {

  const [data, setData] = useState({
    name: '',
    stats: {},
  });

  const [attendance, setAttendance] = useState({
    checkIn: null,
    checkOut: null
  });

  // ✅ THÊM realtime time
  const [currentTime, setCurrentTime] = useState(new Date());

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  useEffect(() => {
    const user = JSON.parse(localStorage.getItem('user'));

    if (!user) return;

    fetch(`http://localhost:5000/api/employee/dashboard/${user.employee_id}`)
      .then(res => res.json())
      .then(result => {
        if (!result.employee) return;

        setData({
          name: result.employee.full_name || '',
          stats: result.stats || {}
        });

        setAttendance({
          checkIn: result.checkIn,
          checkOut: result.checkOut
        });
      })
      .catch(err => console.error(err));

  }, []);

  // ✅ status realtime
  const workStatus = getWorkStatus(attendance.checkIn, attendance.checkOut);

  return (
    <div className="dashboard-wrapper">
      <div className="dashboard-content-box">

        {/* CỘT TRÁI */}
        <div className="left-section">
          
          <div className="checkin-card">
            <div className="checkin-info">

              {/* ✅ dùng currentTime */}
              <h4 className="date-text">
                {currentTime.toLocaleDateString('vi-VN')}
              </h4>

              {/* ✅ bỏ giây + realtime */}
              <h2 className="time-text">
                {currentTime.toLocaleTimeString('en-US', {
                  hour: '2-digit',
                  minute: '2-digit',
                  hour12: true
                })}
              </h2>

              {/* ✅ status động */}
              <div className="status-badge">
                <span className="icon-check">✓</span>
                <span>{workStatus.text}</span>
              </div>

              <p className="gps-status">● Tọa độ GPS sẵn sàng</p>
            </div>

            <div className="checkin-action-group">
              <button
                className="checkin-button"
                disabled={!workStatus.canCheckIn}
               
              >
                ĐIỂM DANH VÀO
              </button>

              <p className="external-status-text">
                Trạng thái:{' '}
                <span>
                  {attendance.checkIn
                    ? attendance.checkOut
                      ? 'Đã checkout'
                      : 'Đã check-in'
                    : 'Chưa check-in'}
                </span>
              </p>
            </div>
          </div>

          <div className="stats-container">
            <div className="stat-card">
              <div className="stat-icon-wrapper success">✓</div>
              <p>Ngày công tháng</p>
              <h3>{data.stats.present || 0}</h3>
            </div>

            <div className="stat-card">
              <div className="stat-icon-wrapper warning">!</div>
              <p>Đi trễ / Về sớm</p>
              <h3 className="warning-text">{data.stats.late || 0}</h3>
            </div>

            <div className="stat-card">
              <div className="stat-icon-wrapper danger">X</div>
              <p>Ngày vắng mặt</p>
              <h3 className="danger-text">{data.stats.absent || 0}</h3>
            </div>
          </div>
        </div>

        {/* CỘT PHẢI */}
        <div className="right-section">
          <div className="info-card">
            <h4 className="section-title">Ca làm việc hôm nay</h4>

            <div className="info-item">
              <span className="time-label">Giờ vào ca</span>
              <span className="time-value">08:00 AM</span>
            </div>

            <div className="info-item">
              <span className="time-label">Giờ ra ca</span>
              <span className="time-value">05:00 PM</span>
            </div>

            <div className="time-remaining-container">
              <div className="info-item remaining">
                <span>Thời gian còn lại</span>
                <span className="time-remaining-value">
                  {/* (giữ nguyên layout, chưa động phần này) */}
                  8h 5m
                </span>
              </div>
            </div>
          </div>

          <div className="notification-card">
            <div className="notif-header">
              <h4>Thông báo</h4>
              <a href="#" className="see-all">Xem tất cả</a>
            </div>

            <ul className="notif-list">
              <li>
                <div className="notif-dot green"></div>
                <div className="notif-content">
                  <p>Duyệt đơn xin nghỉ phép</p>
                  <span className="notif-time">10 phút trước</span>
                </div>
              </li>

              <li>
                <div className="notif-dot orange"></div>
                <div className="notif-content">
                  <p>Bạn chưa check-in hôm nay</p>
                  <span className="notif-time">Hệ thống</span>
                </div>
              </li>
            </ul>
          </div>
        </div>

      </div>
    </div>
  );
};

export default Dashboard;