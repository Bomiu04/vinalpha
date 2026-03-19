import React, { useState } from 'react';
import { ArrowLeft } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import './Login.css';

const ForgotPassword = () => {
  const [email, setEmail] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(''); // Thêm state để bắt lỗi
  const navigate = useNavigate();

  const handleSendOTP = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError(''); // Reset lỗi mỗi lần bấm

    try {
      // Gọi API thực tế xuống Backend (Đổi port 5000 nếu backend của bạn chạy port khác)
      const response = await fetch('http://localhost:5000/api/auth/forgot-password', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email }), // Gửi email lên server
      });

      const data = await response.json();

      if (data.success) {
        setIsLoading(false);
        // Nếu API báo thành công, chuyển sang trang OTP
        navigate('/verify-otp', { state: { email: email } }); 
      } else {
        // Lỗi từ server (VD: Email không tồn tại, lỗi gửi mail)
        setError(data.message);
        setIsLoading(false);
      }
    } catch (err) {
      console.error(err);
      setError('Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng!');
      setIsLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <div className="login-top-bar"></div>

        <div className="login-header">
          <h2>Quên mật khẩu?</h2>
          <p>
            Đừng lo lắng! Vui lòng nhập địa chỉ email liên kết với tài khoản của bạn. 
            Chúng tôi sẽ gửi một mã xác nhận (OTP) để giúp bạn đặt lại mật khẩu.
          </p>
        </div>

        {/* --- KHU VỰC HIỂN THỊ LỖI --- */}
        {error && (
          <div className="mb-4 p-3 bg-red-50 text-red-600 text-sm rounded-lg text-center" style={{ marginBottom: '16px', color: '#dc2626', backgroundColor: '#fef2f2', padding: '12px', borderRadius: '8px', fontSize: '14px' }}>
            {error}
          </div>
        )}

        <form onSubmit={handleSendOTP}>
          <div className="form-group">
            <label htmlFor="email" className="form-label">Email đã đăng ký</label>
            <div className="input-wrapper">
              <input
                id="email"
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="form-input"
                placeholder="Ví dụ: nguyenvan.a@congty.com"
              />
            </div>
          </div>

          <button type="submit" disabled={isLoading} className="btn-login" style={{ marginTop: '10px' }}>
            {isLoading ? 'Đang gửi mã OTP...' : 'Gửi mã OTP'}
          </button>
        </form>

        <div style={{ marginTop: '24px', textAlign: 'center' }}>
          <button 
            onClick={() => navigate('/login')}
            style={{
              background: 'none', border: 'none', display: 'inline-flex', alignItems: 'center', 
              color: '#6b7280', fontSize: '14px', fontWeight: '500', cursor: 'pointer', gap: '6px'
            }}
            onMouseOver={(e) => e.target.style.color = '#1da053'}
            onMouseOut={(e) => e.target.style.color = '#6b7280'}
          >
            <ArrowLeft size={16} /> Quay lại đăng nhập
          </button>
        </div>
      </div>
    </div>
  );
};

export default ForgotPassword;