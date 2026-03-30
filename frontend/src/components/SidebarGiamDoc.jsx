import React, { useState } from 'react'; // 👉 Thêm useState
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { Home, Building, Users, FileText, MapPin, Briefcase, CheckSquare, Settings, HelpCircle, LogOut } from 'lucide-react';

const SidebarGiamDoc = () => {
  const location = useLocation();
  const navigate = useNavigate();

  // 👉 1. State quản lý hiển thị Modal
  const [showLogoutModal, setShowLogoutModal] = useState(false);

  const menuItems = [
    { path: '/GiamDoc/dashboard', icon: <Home size={20} />, label: 'Trang chủ' },
    { path: '/GiamDoc/departments', icon: <Building size={20} />, label: 'Phòng ban' },
    { path: '/GiamDoc/contracts', icon: <FileText size={20} />, label: 'Hợp đồng' },
    { path: '/GiamDoc/branches', icon: <MapPin size={20} />, label: 'Chi nhánh' },
    { path: '/GiamDoc/positions', icon: <Briefcase size={20} />, label: 'Chức vụ' },
    { path: '/GiamDoc/approvals', icon: <CheckSquare size={20} />, label: 'Phê duyệt' },
  ];

  // 👉 2. Hàm khi bấm nút Đăng Xuất ở Sidebar -> Chỉ hiện Modal
  const handleLogoutClick = (e) => {
    e.preventDefault();
    setShowLogoutModal(true);
  };

  // 👉 3. Hàm thực thi khi bấm "Xác nhận" trong Modal
  const confirmLogout = () => {
    localStorage.removeItem('user');
    localStorage.removeItem('token'); // Xóa thêm token nếu có để bảo mật
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
          <p style={{ color: '#9ca3af', fontSize: '12px', fontWeight: 'bold', marginBottom: '16px' }}>
            GIÁM ĐỐC
          </p>

          {menuItems.map((item) => {
            const isActive = location.pathname.startsWith(item.path);

            return (
              <Link 
                key={item.path} 
                to={item.path} 
                className={`menu-item ${isActive ? 'active' : ''}`}
              >
                {item.icon}
                <span style={{ marginLeft: '12px' }}>{item.label}</span>
              </Link>
            );
          })}
        </nav>

        <div className="sidebar-footer">
          <p style={{ color: '#9ca3af', fontSize: '12px', fontWeight: 'bold', marginBottom: '16px' }}>
            SUPPORT
          </p>

          <Link to="/settings" className="menu-item">
            <Settings size={20} /> 
            <span style={{ marginLeft: '12px' }}>Cài Đặt</span>
          </Link>

          <Link to="/help" className="menu-item">
            <HelpCircle size={20} /> 
            <span style={{ marginLeft: '12px' }}>Trợ Giúp</span>
          </Link>

          {/* 👉 Nút Đăng Xuất gắn với hàm handleLogoutClick */}
          <button 
            onClick={handleLogoutClick} 
            className="menu-item"
            style={{
              width: '100%',
              background: 'none',
              border: 'none',
              cursor: 'pointer',
              textAlign: 'left',
              padding: '12px',
              color: '#6b7280',
              display: 'flex',
              alignItems: 'center'
            }}
          >
            <LogOut size={20} /> 
            <span style={{ marginLeft: '12px' }}>Đăng Xuất</span>
          </button>
        </div>
      </aside>

      {/* 👉 4. MODAL XÁC NHẬN ĐĂNG XUẤT */}
      {showLogoutModal && (
        <div className="modal-overlay">
          <div className="logout-modal">
            <div className="modal-icon-container">
               <div className="icon-circle">
                  {/* Dùng tạm HelpCircle thay thế vì QuestionIcon chưa được import */}
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

export default SidebarGiamDoc;