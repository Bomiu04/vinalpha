import React, { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { LayoutDashboard, ShieldCheck, UserCog, Settings, LogOut, HelpCircle } from 'lucide-react';

const SidebarAdmin = () => {
  const location = useLocation();
  const navigate = useNavigate();

  // 👉 1. State quản lý hiển thị Modal
  const [showLogoutModal, setShowLogoutModal] = useState(false);

  const menuItems = [
    { path: '/Admin/dashboard', icon: <LayoutDashboard size={20} />, label: 'Tổng quan' },
    { path: '/Admin/users', icon: <UserCog size={20} />, label: 'Quản lý tài khoản' },
    { path: '/Admin/LocationSettings', icon: <Settings size={20} />, label: 'Cài đặt vị trí chấm công' },
  ];

  // 👉 2. Hàm khi bấm nút Đăng Xuất ở Sidebar -> Chỉ hiện Modal
  const handleLogoutClick = (e) => {
    e.preventDefault();
    setShowLogoutModal(true);
  };

  // 👉 3. Hàm thực thi khi bấm "Xác nhận" trong Modal
  const confirmLogout = () => {
    localStorage.removeItem('user');
    localStorage.removeItem('token'); // Xóa luôn token cho an toàn
    setShowLogoutModal(false);
    navigate('/login');
  };

  return (
    <>
      <aside className="sidebar">
        <div className="logo" style={{ marginBottom: '40px' }}>
          <img src="/logo.png" alt="HR PeopleTech" style={{ height: '40px' }} />
        </div>

        <nav style={{ flex: 1 }}>
          <p style={{ color: '#9ca3af', fontSize: '12px', fontWeight: 'bold', marginBottom: '16px' }}>QUẢN TRỊ VIÊN</p>
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

        <div className="sidebar-footer" style={{ borderTop: '1px solid #e5e7eb', paddingTop: '20px' }}>
          {/* 👉 Nút Đăng Xuất đã được gắn sự kiện gọi Modal */}
          <button 
            onClick={handleLogoutClick} 
            className="menu-item" 
            style={{ width: '100%', background: 'none', border: 'none', cursor: 'pointer', textAlign: 'left', padding: '12px', color: '#dc2626', display: 'flex', alignItems: 'center' }}
          >
            <LogOut size={20} /> <span style={{ marginLeft: '12px' }}>Đăng Xuất</span>
          </button>
        </div>
      </aside>

      {/* 👉 4. MODAL XÁC NHẬN ĐĂNG XUẤT */}
      {showLogoutModal && (
        <div className="modal-overlay">
          <div className="logout-modal">
            <div className="modal-icon-container">
               <div className="icon-circle">
                  <HelpCircle size={40} color="#16a34a" />
               </div>
            </div>
            
            <h3>Xác nhận đăng xuất</h3>
            <p>Bạn có chắc chắn muốn đăng xuất?</p>
            
            <div className="modal-actions">
              <button className="btn-confirm" onClick={confirmLogout}>Xác nhận</button>
              <button className="btn-cancel" onClick={() => setShowLogoutModal(false)}>Hủy</button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default SidebarAdmin;