import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';

// Import Layout và các Trang công khai
import MainLayout from './pages/MainLayout'; 
import Login from './pages/Login'; 
import ForgotPassword from './pages/ForgotPassword';
import VerifyOTP from './pages/VerifyOTP';
import ResetPassword from './pages/ResetPassword';
import ProtectedRoute from './components/ProtectedRoute'; 

// Import trang Nhân viên
import DashboardHome from './pages/NhanVien/DashboardHome'; 

// Import trang Admin (Thêm dòng này để gọi trang Quản lý User vào)
import UserManagement from './pages/Admin/UserManagement';

// Các trang tạm thời của Nhân Viên
const CheckInPage = () => <div style={{padding: '20px'}}>Trang Chấm công</div>;
const SalaryPage = () => <div style={{padding: '20px'}}>Trang Bảng lương</div>;
const LeaveRequestPage = () => <div style={{padding: '20px'}}>Trang Đơn xin phép</div>;

// Các trang tạm thời cho Giám đốc và Quản lý
const GiamDocDashboard = () => <div style={{padding: '20px'}}>Trang Tổng quan Giám Đốc</div>;
const QuanLyDashboard = () => <div style={{padding: '20px'}}>Trang Quản Lý Bộ Phận</div>;

function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* ========================================== */}
        {/* LUỒNG 1: CÔNG KHAI (Không cần đăng nhập)   */}
        {/* ========================================== */}
        <Route path="/login" element={<Login />} />
        <Route path="/forgot-password" element={<ForgotPassword />} />
        <Route path="/verify-otp" element={<VerifyOTP />} />
        <Route path="/reset-password" element={<ResetPassword />} />

        {/* ========================================== */}
        {/* LUỒNG 2: DÀNH CHO NHÂN VIÊN (USER)         */}
        {/* ========================================== */}
        {/* Mảng allowedRoles quyết định ai được vào. Ở đây cho phép cả 4 Role đều có thể xem trang chấm công */}
        <Route element={<ProtectedRoute allowedRoles={['USER', 'MANAGER', 'DIRECTOR', 'ADMIN']} />}>
          <Route element={<MainLayout />}>
            <Route path="/dashboard" element={<DashboardHome />} />
            <Route path="/checkin" element={<CheckInPage />} />
            <Route path="/salary" element={<SalaryPage />} />
            <Route path="/leave-request" element={<LeaveRequestPage />} />
          </Route>
        </Route>

        {/* ========================================== */}
        {/* LUỒNG 3: DÀNH CHO ADMIN                    */}
        {/* ========================================== */}
        {/* Chỉ duy nhất tài khoản có role ADMIN mới lọt qua được cửa này */}
        <Route element={<ProtectedRoute allowedRoles={['ADMIN']} />}>
          <Route element={<MainLayout />}>
            <Route path="/admin/users" element={<UserManagement />} />
          </Route>
        </Route>

        {/* ========================================== */}
        {/* LUỒNG 4: DÀNH CHO QUẢN LÝ (MANAGER)        */}
        {/* ========================================== */}
        <Route element={<ProtectedRoute allowedRoles={['MANAGER']} />}>
          <Route element={<MainLayout />}>
            <Route path="/quanly/dashboard" element={<QuanLyDashboard />} />
          </Route>
        </Route>

        {/* ========================================== */}
        {/* LUỒNG 5: DÀNH CHO GIÁM ĐỐC (DIRECTOR)      */}
        {/* ========================================== */}
        <Route element={<ProtectedRoute allowedRoles={['DIRECTOR']} />}>
          <Route element={<MainLayout />}>
            <Route path="/giamdoc/dashboard" element={<GiamDocDashboard />} />
          </Route>
        </Route>

        {/* ========================================== */}
        {/* FALLBACK: Nhập link bậy bạ thì văng ra Login*/}
        {/* ========================================== */}
        <Route path="/" element={<Navigate to="/login" replace />} />
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;