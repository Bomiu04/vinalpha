import React from 'react';
import { Outlet, Link, useLocation } from 'react-router-dom';
import { Home, MapPin, CreditCard, FileText, Settings, HelpCircle, LogOut, Bell } from 'lucide-react';
import './MainLayout.css';

const MainLayout = () => {
  const location = useLocation();

  const menuItems = [
    { path: '/dashboard', icon: <Home size={20} />, label: 'Trang chủ' },
    { path: '/checkin', icon: <MapPin size={20} />, label: 'Chấm công' },
    { path: '/salary', icon: <CreditCard size={20} />, label: 'Xem bảng lương' },
    { path: '/leave-request', icon: <FileText size={20} />, label: 'Tạo Đơn xin phép' },
  ];

  return (
    <div className="admin-layout">
      {/* SIDEBAR BÊN TRÁI */}
      <aside className="sidebar">
        <div className="logo" style={{ marginBottom: '40px' }}>
          <img src="/logo.png" alt="HR PeopleTech" style={{ height: '40px' }} />
        </div>

        <nav style={{ flex: 1 }}>
          <p style={{ color: '#9ca3af', fontSize: '12px', fontWeight: 'bold', marginBottom: '16px' }}>TRANG CHỦ</p>
          {menuItems.map((item) => (
            <Link 
              key={item.path} 
              to={item.path} 
              className={`menu-item ${location.pathname === item.path ? 'active' : ''}`}
            >
              {item.icon} <span style={{ marginLeft: '12px' }}>{item.label}</span>
            </Link>
          ))}
        </nav>

        <div className="sidebar-footer">
          <p style={{ color: '#9ca3af', fontSize: '12px', fontWeight: 'bold', marginBottom: '16px' }}>SUPPORT</p>
          <Link to="/settings" className="menu-item"><Settings size={20} /> <span style={{ marginLeft: '12px' }}>Cài Đặt</span></Link>
          <Link to="/help" className="menu-item"><HelpCircle size={20} /> <span style={{ marginLeft: '12px' }}>Trợ Giúp</span></Link>
          <Link to="/login" className="menu-item"><LogOut size={20} /> <span style={{ marginLeft: '12px' }}>Đăng Xuất</span></Link>
        </div>
      </aside>

      {/* NỘI DUNG BÊN PHẢI */}
      <main className="main-content">
        <header className="top-header">
          <div className="datetime-box" style={{ background: 'white', padding: '8px 20px', borderRadius: '20px', fontWeight: '500' }}>
            17/03/2026 . 7:55 AM
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
            <button style={{ background: 'white', border: 'none', padding: '10px', borderRadius: '50%', cursor: 'pointer' }}>
              <Bell size={20} color="#6b7280" />
            </button>
            <div className="user-profile" style={{ display: 'flex', alignItems: 'center', gap: '10px', background: 'white', padding: '5px 15px', borderRadius: '30px' }}>
              <div style={{ width: '35px', height: '35px', borderRadius: '50%', background: '#e5e7eb', display: 'flex', alignItems: 'center', justifyCenter: 'center' }}>👤</div>
              <div>
                <div style={{ fontSize: '14px', fontWeight: 'bold' }}>User name</div>
                <div style={{ fontSize: '10px', color: '#1da053' }}>POSITIONS</div>
              </div>
            </div>
          </div>
        </header>

        {/* NƠI HIỂN THỊ CÁC TRANG CON (Home, Chấm công...) */}
        <div className="content-body">
          <Outlet />
        </div>
      </main>
    </div>
  );
};

export default MainLayout;