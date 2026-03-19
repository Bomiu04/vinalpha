import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';

// Import Layout và các Trang
import MainLayout from './pages/MainLayout'; // File này đang nằm trực tiếp trong pages
import Login from './pages/Login'; 
import ForgotPassword from './pages/ForgotPassword';
import VerifyOTP from './pages/VerifyOTP';
import ResetPassword from './pages/ResetPassword';

// ĐƯỜNG DẪN MỚI CHO DASHBOARD (Vì bạn để trong thư mục NhanVien)
import DashboardHome from './pages/NhanVien/DashboardHome'; 

// Các trang tạm thời (Bạn có thể tạo file trống trong thư mục NhanVien sau)
const CheckInPage = () => <div style={{padding: '20px'}}>Trang Chấm công</div>;
const SalaryPage = () => <div style={{padding: '20px'}}>Trang Bảng lương</div>;
const LeaveRequestPage = () => <div style={{padding: '20px'}}>Trang Đơn xin phép</div>;

function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Luồng không có Sidebar */}
        <Route path="/login" element={<Login />} />
        <Route path="/forgot-password" element={<ForgotPassword />} />
        <Route path="/verify-otp" element={<VerifyOTP />} />
        <Route path="/reset-password" element={<ResetPassword />} />

        {/* Luồng Dashboard CÓ Sidebar */}
        <Route element={<MainLayout />}>
          <Route path="/dashboard" element={<DashboardHome />} />
          <Route path="/checkin" element={<CheckInPage />} />
          <Route path="/salary" element={<SalaryPage />} />
          <Route path="/leave-request" element={<LeaveRequestPage />} />
        </Route>

        {/* Mặc định vào Login */}
        <Route path="/" element={<Navigate to="/login" replace />} />
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;