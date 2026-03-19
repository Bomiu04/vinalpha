import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';

// Import các trang (Pages) của bạn vào đây
// Lưu ý: Đảm bảo đường dẫn import khớp với cấu trúc thư mục của bạn
import Login from './pages/Login'; 
import ForgotPassword from './pages/ForgotPassword';
import VerifyOTP from './pages/VerifyOTP';
import ResetPassword from './pages/ResetPassword';
function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Nếu người dùng vào thẳng localhost:5173, tự động đá sang trang Đăng nhập */}
        <Route path="/" element={<Navigate to="/login" replace />} />

        {/* Cấu hình các luồng Đăng nhập & Quên mật khẩu */}
        <Route path="/login" element={<Login />} />
        <Route path="/forgot-password" element={<ForgotPassword />} />

        {/* Các trang chúng ta sẽ code tiếp theo (Tạm thời comment lại để không lỗi) */}
        <Route path="/verify-otp" element={<VerifyOTP />} />
        {/* <Route path="/reset-password" element={<ResetPasswor
        d />} /> */}
          <Route path="/reset-password" element={<ResetPassword />} />
        {/* Bắt lỗi 404: Nếu gõ link bậy bạ, đá về trang Login */}
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;