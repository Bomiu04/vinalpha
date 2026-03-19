import React, { useState } from 'react';
import { Eye, EyeOff } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import './Login.css'; // <--- Import file CSS ở đây

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    
    // Fake delay
    setTimeout(() => {
      setIsLoading(false);
      navigate('/'); 
    }, 1000);
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <div className="login-top-bar"></div>

        <div className="login-header">
          <h2>Đăng nhập</h2>
          <p>Vui lòng đăng nhập để truy cập hệ thống</p>
        </div>

        <form onSubmit={handleLogin}>
          <div className="form-group">
            <label htmlFor="email" className="form-label">Email</label>
            <div className="input-wrapper">
              <input
                id="email"
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="form-input"
                placeholder="Hãy nhập địa chỉ Email của bạn"
              />
            </div>
          </div>

          <div className="form-group">
            <label htmlFor="password" className="form-label">Mật khẩu</label>
            <div className="input-wrapper">
              <input
                id="password"
                type={showPassword ? "text" : "password"}
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="form-input"
                placeholder="Nhập mật khẩu"
                style={{ paddingRight: '48px' }}
              />
              <button
                type="button"
                className="btn-toggle-password"
                onClick={() => setShowPassword(!showPassword)}
              >
                {showPassword ? <Eye size={20} /> : <EyeOff size={20} />}
              </button>
            </div>
          </div>

          <div className="login-actions">
            <label className="remember-me" htmlFor="remember-me">
              <input id="remember-me" type="checkbox" />
              Ghi nhớ mật khẩu
            </label>
            <a href="/forgot-password" className="forgot-password-link">
              Quên mật khẩu?
            </a>
          </div>

          <button type="submit" disabled={isLoading} className="btn-login">
            {isLoading ? 'Đang xử lý...' : 'Đăng nhập'}
          </button>
        </form>

        <div className="login-footer">
          Tài khoản được cấp bởi quản trị hệ thống
        </div>
      </div>
    </div>
  );
};

export default Login;