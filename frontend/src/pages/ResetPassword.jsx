import React, { useState } from 'react';
import { Eye, EyeOff, ArrowLeft } from 'lucide-react';
import { useNavigate, useLocation } from 'react-router-dom';
import './Login.css';

const ResetPassword = () => {
  const navigate = useNavigate();
  const location = useLocation();
  
  // Lấy email từ trang OTP truyền sang qua state
  const email = location.state?.email || "";
  
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleResetPassword = async (e) => {
    e.preventDefault();
    setError('');

    if (newPassword !== confirmPassword) {
      setError('Mật khẩu xác nhận không khớp!');
      return;
    }

    if (newPassword.length < 6) {
      setError('Mật khẩu phải có ít nhất 6 ký tự!');
      return;
    }

    setIsLoading(true);

    try {
      // GỌI API CẬP NHẬT MẬT KHẨU THẬT
      const response = await fetch('http://localhost:5000/api/auth/reset-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: email, newPassword: newPassword }),
      });

      const data = await response.json();

      if (data.success) {
        setIsLoading(false);
        alert('🎉 Đổi mật khẩu thành công! Bạn có thể đăng nhập ngay bây giờ.');
        navigate('/login');
      } else {
        setError(data.message || 'Có lỗi xảy ra, vui lòng thử lại.');
        setIsLoading(false);
      }
    } catch (err) {
      console.error(err);
      setError('Không thể kết nối đến máy chủ!');
      setIsLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <div className="login-top-bar"></div>
        <div className="login-header">
          <h2>Thiết lập mật khẩu mới</h2>
          <p>Đang đặt lại mật khẩu cho: <strong>{email}</strong></p>
        </div>

        {error && (
          <div style={{ color: '#dc2626', backgroundColor: '#fef2f2', padding: '12px', borderRadius: '8px', marginBottom: '16px', fontSize: '14px', textAlign: 'center' }}>
            {error}
          </div>
        )}

        <form onSubmit={handleResetPassword}>
          <div className="form-group">
            <label className="form-label">Mật khẩu mới</label>
            <div className="input-wrapper">
              <input
                type={showNewPassword ? "text" : "password"}
                required
                className="form-input"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                placeholder="Nhập mật khẩu mới"
                style={{ paddingRight: '48px' }}
              />
              <button type="button" className="btn-toggle-password" onClick={() => setShowNewPassword(!showNewPassword)}>
                {showNewPassword ? <Eye size={20} /> : <EyeOff size={20} />}
              </button>
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">Xác nhận mật khẩu</label>
            <div className="input-wrapper">
              <input
                type={showConfirmPassword ? "text" : "password"}
                required
                className="form-input"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="Nhập lại mật khẩu"
                style={{ paddingRight: '48px' }}
              />
              <button type="button" className="btn-toggle-password" onClick={() => setShowConfirmPassword(!showConfirmPassword)}>
                {showConfirmPassword ? <Eye size={20} /> : <EyeOff size={20} />}
              </button>
            </div>
          </div>

          <button type="submit" disabled={isLoading} className="btn-login" style={{ marginTop: '24px' }}>
            {isLoading ? 'Đang cập nhật...' : 'Cập nhật mật khẩu'}
          </button>
        </form>
      </div>
    </div>
  );
};

export default ResetPassword;