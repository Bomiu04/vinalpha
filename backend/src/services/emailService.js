const nodemailer = require('nodemailer');

// Cấu hình transporter với Gmail
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// Hàm gửi OTP
const sendOTPEmail = async (toEmail, otpCode) => {
  try {
    const mailOptions = {
      from: `"Hệ thống Quản lý Nhân sự GPS" <${process.env.EMAIL_USER}>`,
      to: toEmail,
      subject: 'Mã xác nhận OTP Đặt lại mật khẩu',
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; background-color: #f4f6f8;">
          <div style="max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
            <h2 style="color: #1da053; text-align: center;">YÊU CẦU ĐẶT LẠI MẬT KHẨU</h2>
            <p>Chào bạn,</p>
            <p>Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản liên kết với email này.</p>
            <p>Mã xác nhận (OTP) của bạn là:</p>
            <div style="text-align: center; margin: 20px 0;">
              <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #111827; background: #f3f4f6; padding: 10px 20px; border-radius: 8px;">
                ${otpCode}
              </span>
            </div>
            <p style="color: #dc2626; font-size: 14px;"><i>*Mã này sẽ hết hạn trong vòng 5 phút. Vui lòng không chia sẻ mã này cho bất kỳ ai!</i></p>
            <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 20px 0;" />
            <p style="font-size: 12px; color: #6b7280; text-align: center;">Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email này.</p>
          </div>
        </div>
      `,
    };

    const info = await transporter.sendMail(mailOptions);
    console.log('Đã gửi email thành công: ' + info.response);
    return true;
  } catch (error) {
    console.error('Lỗi khi gửi email: ', error);
    throw new Error('Không thể gửi email OTP');
  }
};

module.exports = {
  sendOTPEmail,
};