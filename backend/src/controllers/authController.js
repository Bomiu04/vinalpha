const { sendOTPEmail } = require('../services/emailService');
const db = require('../config/database');
// Nơi lưu trữ OTP tạm thời (Trong thực tế nên dùng Redis hoặc lưu vào bảng trong Database)
global.otpStorage = global.otpStorage || {}; 

const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ success: false, message: 'Vui lòng cung cấp email!' });
    }

    // 1. Tạo mã OTP 6 số ngẫu nhiên
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();

    // 2. Lưu OTP vào bộ nhớ tạm với thời hạn 5 phút
    global.otpStorage[email] = {
      otp: otpCode,
      expiresAt: Date.now() + 5 * 60 * 1000 // 5 phút (tính bằng milliseconds)
    };

    // 3. Gọi hàm gửi Email (đã viết ở file emailService.js)
    await sendOTPEmail(email, otpCode);

    res.status(200).json({ 
      success: true, 
      message: 'Mã OTP đã được gửi đến email của bạn!' 
    });

  } catch (error) {
    console.error('Lỗi API forgotPassword:', error);
    res.status(500).json({ success: false, message: 'Lỗi Server khi gửi email' });
  }
};
const verifyOTP = async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({ success: false, message: 'Vui lòng cung cấp đủ email và mã OTP!' });
    }

    const record = global.otpStorage[email];

    if (!record) {
      return res.status(400).json({ success: false, message: 'Mã OTP không tồn tại hoặc chưa được yêu cầu!' });
    }

    if (Date.now() > record.expiresAt) {
      delete global.otpStorage[email];
      return res.status(400).json({ success: false, message: 'Mã OTP đã hết hạn! Vui lòng gửi lại mã mới.' });
    }

    if (record.otp !== otp) {
      return res.status(400).json({ success: false, message: 'Mã OTP không chính xác!' });
    }

    delete global.otpStorage[email]; // Dùng xong thì xóa

    res.status(200).json({ success: true, message: 'Xác thực mã OTP thành công!' });
  } catch (error) {
    console.error('Lỗi API verifyOTP:', error);
    res.status(500).json({ success: false, message: 'Lỗi Server khi xác thực OTP' });
  }
};
const bcrypt = require('bcryptjs'); // Hoặc dùng thư viện mã hóa của bạn

const resetPassword = async (req, res) => {
  try {
    const { email, newPassword } = req.body;

    if (!email || !newPassword) {
      return res.status(400).json({ success: false, message: 'Thiếu email hoặc mật khẩu mới!' });
    }

    // 1. Lệnh SQL UPDATE MẬT KHẨU THẬT SỰ
    // Dùng hàm crypt() và gen_salt('bf') của PostgreSQL để mã hóa mật khẩu mới
    const result = await db.query(
      `UPDATE user_account 
       SET password_hash = crypt(:newPassword, gen_salt('bf')) 
       WHERE employee_id = (
           SELECT id FROM employee WHERE personal_email = :email LIMIT 1
       )`,
      {
        replacements: { 
          newPassword: newPassword, 
          email: email 
        },
        type: db.QueryTypes.UPDATE
      }
    );

    // 2. Trả về thành công
    console.log(`✅ Đã cập nhật mật khẩu mới thành công cho tài khoản có email: ${email}`);
    res.status(200).json({ 
      success: true, 
      message: 'Mật khẩu đã được cập nhật thành công!' 
    });

  } catch (error) {
    console.error('❌ Lỗi Reset Password:', error);
    res.status(500).json({ success: false, message: 'Lỗi server khi cập nhật mật khẩu' });
  }
};
const login = async (req, res) => {
  try {
    const { username, password } = req.body;

    // 1. Truy vấn kiểm tra username và mật khẩu (dùng hàm crypt của Postgres)
    const [user] = await db.query(
      `SELECT ua.username, ua.role_code, e.full_name, e.id as employee_id 
       FROM user_account ua
       JOIN employee e ON ua.employee_id = e.id
       WHERE ua.username = :username 
       AND ua.password_hash = crypt(:password, ua.password_hash)
       AND ua.status = 'active'`,
      {
        replacements: { username, password },
        type: db.QueryTypes.SELECT
      }
    );

    if (!user) {
      return res.status(401).json({ 
        success: false, 
        message: 'Tên đăng nhập hoặc mật khẩu không chính xác!' 
      });
    }

    // 2. Trả về thông tin đăng nhập thành công
    res.status(200).json({
      success: true,
      message: 'Đăng nhập thành công!',
      user: {
        username: user.username,
        fullName: user.full_name,
        role: user.role_code,
        id: user.employee_id
      }
    });

  } catch (error) {
    console.error('Lỗi Login:', error);
    res.status(500).json({ success: false, message: 'Lỗi máy chủ nội bộ' });
  }
};

module.exports = {
    login,
    forgotPassword,
    verifyOTP,
    resetPassword
};