import React, { useState, useRef, useEffect } from 'react';
import { ArrowLeft } from 'lucide-react';
import { useNavigate, useLocation } from 'react-router-dom';
import './Login.css';

const VerifyOTP = () => {
  const navigate = useNavigate();
  const location = useLocation();
  
  // Lấy email từ màn hình trước truyền sang
  const email = location.state?.email || '';

  const [otp, setOtp] = useState(['', '', '', '', '', '']);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(''); // Biến lưu lỗi nếu nhập sai mã
  const [countdown, setCountdown] = useState(60); // Đếm ngược 60 giây
  
  const inputRefs = useRef([]);

  // Xử lý đếm ngược thời gian gửi lại mã
  useEffect(() => {
    let timer;
    if (countdown > 0) {
      timer = setInterval(() => setCountdown(c => c - 1), 1000);
    }
    return () => clearInterval(timer);
  }, [countdown]);

  // Xử lý khi gõ từng số
  const handleChange = (element, index) => {
    if (isNaN(element.value)) return;

    const newOtp = [...otp];
    newOtp[index] = element.value;
    setOtp(newOtp);

    if (element.value !== '' && index < 5) {
      inputRefs.current[index + 1].focus();
    }
  };

  // Xử lý phím Backspace (Xóa lùi)
  const handleKeyDown = (e, index) => {
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      inputRefs.current[index - 1].focus();
    }
  };

  // ==========================================
  // HÀM GỌI API XÁC THỰC MÃ OTP
  // ==========================================
  const handleVerify = async (e) => {
    e.preventDefault();
    const otpCode = otp.join('');
    
    if (otpCode.length < 6) {
      setError("Vui lòng nhập đủ 6 số OTP!");
      return;
    }

    setIsLoading(true);
    setError(''); // Reset lỗi

    try {
      // Gọi API xuống Backend
      const response = await fetch('http://localhost:5000/api/auth/verify-otp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: email, otp: otpCode }), 
      });

      const data = await response.json();

      if (data.success) {
        setIsLoading(false);
        
        // 1. Hiển thị thông báo thành công
        alert('🎉 Xác thực OTP THÀNH CÔNG! Đang chuyển sang trang Đổi mật khẩu...');
        
        // 2. Chuyển sang trang Đổi mật khẩu (Mang theo email)
        navigate('/reset-password', { state: { email: email } }); 
      } else {
        // Lỗi: Sai mã hoặc hết hạn
        setError(data.message);
        setIsLoading(false);
      }
    } catch (err) {
      console.error(err);
      setError('Không thể kết nối đến máy chủ!');
      setIsLoading(false);
    }
  };

const handleResend = async () => {
    setError(''); // Xóa lỗi cũ nếu có

    try {
      // Gọi lại API forgot-password y hệt như màn hình trước
      const response = await fetch('http://localhost:5000/api/auth/forgot-password', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email: email }), 
      });

      const data = await response.json();

      if (data.success) {
        // Nếu API báo thành công, hiện thông báo và bắt đầu đếm ngược lại
        alert('Mã OTP mới đã được gửi! Vui lòng kiểm tra lại email của bạn.');
        setCountdown(60); 
      } else {
        // Nếu có lỗi từ server
        setError(data.message || 'Lỗi khi gửi lại mã OTP');
      }
    } catch (err) {
      console.error(err);
      setError('Không thể kết nối đến máy chủ để gửi lại mã!');
    }setIsLoading(true);
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <div className="login-top-bar"></div>

        <div className="login-header">
          <h2>Xác nhận mã OTP</h2>
          <p>
            Mã xác nhận gồm 6 chữ số đã được gửi đến email <br />
            <strong style={{ color: '#111827' }}>{email}</strong>
          </p>
        </div>

        {/* --- HIỂN THỊ LỖI MÀU ĐỎ NẾU NHẬP SAI --- */}
        {error && (
          <div style={{ marginBottom: '16px', color: '#dc2626', backgroundColor: '#fef2f2', padding: '12px', borderRadius: '8px', fontSize: '14px', textAlign: 'center' }}>
            {error}
          </div>
        )}

        <form onSubmit={handleVerify}>
          <div className="otp-container">
            {otp.map((data, index) => (
              <input
                key={index}
                type="text"
                maxLength="1"
                className="otp-input"
                value={data}
                ref={(el) => (inputRefs.current[index] = el)}
                onChange={(e) => handleChange(e.target, index)}
                onKeyDown={(e) => handleKeyDown(e, index)}
                onFocus={(e) => e.target.select()}
                autoFocus={index === 0}
              />
            ))}
          </div>

          <div className="resend-text">
            Bạn chưa nhận được mã?{' '}
            <button 
              type="button" 
              className="resend-link" 
              onClick={handleResend}
              disabled={countdown > 0}
            >
              Gửi lại {countdown > 0 ? `(${countdown}s)` : ''}
            </button>
          </div>

          <button type="submit" disabled={isLoading} className="btn-login">
            {isLoading ? 'Đang xác thực...' : 'Xác nhận'}
          </button>
        </form>

        <div style={{ marginTop: '24px', textAlign: 'center' }}>
          <button 
            onClick={() => navigate('/forgot-password')}
            style={{
              background: 'none', border: 'none', display: 'inline-flex', alignItems: 'center', 
              color: '#6b7280', fontSize: '14px', fontWeight: '500', cursor: 'pointer', gap: '6px'
            }}
            onMouseOver={(e) => e.target.style.color = '#1da053'}
            onMouseOut={(e) => e.target.style.color = '#6b7280'}
          >
            <ArrowLeft size={16} /> Quay lại
          </button>
        </div>

      </div>
    </div>
  );
};

export default VerifyOTP;