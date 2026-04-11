const fs = require('fs');
const path = require('path');
const nodemailer = require('nodemailer');
const { Resend } = require('resend'); // Thêm Resend
const PDFDocument = require('pdfkit');

// Khởi tạo Resend (cho Production)
const resend = new Resend(process.env.RESEND_API_KEY);

// Khởi tạo Nodemailer (cho Local)
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
  family: 4 // Ép IPv4 cho chắc ăn ở local
});

const isProd = process.env.NODE_ENV === 'production';

/**
 * HÀM GỬI MAIL TỔNG QUÁT (Cốt lõi để tách môi trường)
 */
async function transportMail({ to, subject, html, attachments = [] }) {
  if (isProd) {
    // CHẠY TRÊN RENDER: Dùng Resend qua HTTP API (Cổng 443 không bao giờ treo)
    console.log(`🚀 [Resend] Đang gửi mail tới: ${to}`);
    return resend.emails.send({
      from: 'HR System <hrmgpsattendance.web.app>', // Sau này bạn có domain riêng thì thay vào đây
      to: to,
      subject: subject,
      html: html,
      attachments: attachments.map(att => ({
        filename: att.filename,
        content: att.content, // Resend nhận Buffer trực tiếp
      }))
    });
  } else {
    // CHẠY Ở LOCAL: Dùng Nodemailer/Gmail
    console.log(`🏠 [Local] Đang gửi mail tới: ${to}`);
    return transporter.sendMail({
      from: `"Hệ thống Quản lý Nhân sự GPS" <${process.env.EMAIL_USER}>`,
      to,
      subject,
      html,
      attachments,
    });
  }
}

function resolveVietnameseFontPath() {
  const preferred = path.join(FONTS_DIR, 'Times-New-Roman.ttf');
  if (fs.existsSync(preferred)) return preferred;
  if (!fs.existsSync(FONTS_DIR)) return null;
  const ttf = fs.readdirSync(FONTS_DIR).find((f) => f.toLowerCase().endsWith('.ttf'));
  return ttf ? path.join(FONTS_DIR, ttf) : null;
}

function escapeHtml(value) {
  if (value == null) return '';
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function formatVietnameseCalendarDate(dateInput) {
  const d = dateInput instanceof Date ? dateInput : new Date(dateInput);
  if (Number.isNaN(d.getTime())) return String(dateInput);
  return `ngày ${d.getDate()} tháng ${d.getMonth() + 1} năm ${d.getFullYear()}`;
}

function safePdfFilename(decisionNumber) {
  const base = String(decisionNumber || 'Quyet-dinh').replace(/[/\\?%*:|"<>]/g, '_');
  return `${base}.pdf`;
}

/**
 * Tạo buffer PDF quyết định (font TTF trong src/fonts để hiển thị tiếng Việt).
 */
function generateDecisionPdfBuffer(employeeName, decisionData) {
  const fontPath = resolveVietnameseFontPath();

  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ size: 'A4', margin: 50 });
    const chunks = [];
    doc.on('data', (chunk) => chunks.push(chunk));
    doc.on('end', () => resolve(Buffer.concat(chunks)));
    doc.on('error', reject);

    const fontMain = 'VNBody';
    if (fontPath) {
      doc.registerFont(fontMain, fontPath);
    } else {
      console.warn(
        '[emailService] Chưa có file .ttf trong src/fonts (ví dụ Times-New-Roman.ttf). PDF có thể hiển thị sai dấu tiếng Việt.'
      );
    }

    const useFont = fontPath ? fontMain : 'Helvetica';
    const company = process.env.COMPANY_NAME || '................................';
    const issuePlace = process.env.DECISION_ISSUE_PLACE || '..........';
    const { decision_number, decision_type, form, amount, reason, issue_date } = decisionData;
    const isReward = decision_type === 'reward';
    const amountNum = Number(amount) || 0;
    const yearRef = (() => {
      const d = new Date(issue_date);
      return Number.isNaN(d.getTime()) ? new Date().getFullYear() : d.getFullYear();
    })();

    const leftX = 50;
    const rightX = 290;
    const rightW = 245;
    let y = 50;

    doc.font(useFont).fontSize(11);
    doc.text(`CÔNG TY ${company}`, leftX, y, { width: 220, align: 'left' });
    doc.fontSize(10).text('CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM', rightX, y, { width: rightW, align: 'center' });
    y += 28;
    doc.text('Độc lập - Tự do - Hạnh phúc', rightX, y, { width: rightW, align: 'center' });
    y += 18;
    const lineY = y;
    doc
      .moveTo(rightX + 30, lineY)
      .lineTo(rightX + rightW - 30, lineY)
      .dash(4, { space: 3 })
      .strokeColor('#333333')
      .stroke()
      .undash();
    y += 20;

    doc.fontSize(11);
    doc.text(`Số: ${decision_number}`, leftX, y, { width: 220, align: 'left' });
    doc.text(
      `${issuePlace}, ${formatVietnameseCalendarDate(issue_date)}`,
      rightX,
      y,
      { width: rightW, align: 'center' }
    );
    y += 36;

    doc.fontSize(13).text('QUYẾT ĐỊNH', leftX, y, { width: 495, align: 'center' });
    y += 22;
    const subjectLine = isReward
      ? `V/v: Khen thưởng cá nhân xuất sắc năm ${yearRef}`
      : `V/v: Xử lý kỷ luật lao động năm ${yearRef}`;
    doc.fontSize(12).text(subjectLine, leftX, y, { width: 495, align: 'center' });
    y += 20;
    doc.text('CÔNG TY', leftX, y, { width: 495, align: 'center' });
    y += 28;

    doc.fontSize(11).text('Căn cứ:', leftX, y, { width: 495, align: 'left' });
    y += 16;
    const basis = [
      'Căn cứ Bộ luật Lao động 2019;',
      `Căn cứ vào Điều lệ hoạt động của Công ty ${company};`,
      'Để động viên, khuyến khích CBNV toàn Công ty;',
      'Xét đề nghị của Trưởng phòng Hành chính — Nhân sự.',
    ];
    if (!isReward) {
      basis[2] = 'Để duy trì kỷ luật lao động, nề nếp làm việc tại Công ty;';
    }
    basis.forEach((line) => {
      doc.text(`- ${line}`, leftX, y, { width: 495, align: 'left' });
      y += 14;
    });
    y += 10;

    doc.fontSize(12).text('QUYẾT ĐỊNH:', leftX, y, { width: 495, align: 'center' });
    y += 22;

    doc.fontSize(11);
    if (isReward) {
      doc.text(
        `Điều 1. Khen thưởng: ${employeeName} theo hình thức «${form}» trong năm ${yearRef}.`,
        leftX,
        y,
        { width: 495, align: 'left' }
      );
      y += 16;
      if (amountNum > 0) {
        doc.text(
          `- Mức khen thưởng: ${new Intl.NumberFormat('vi-VN').format(amountNum)} VNĐ`,
          leftX,
          y,
          { width: 495, align: 'left' }
        );
        y += 14;
      }
      doc.text(`- Lý do, thành tích: ${reason}`, leftX, y, { width: 495, align: 'left' });
      y += 28;
    } else {
      doc.text(
        `Điều 1. Áp dụng hình thức kỷ luật «${form}» đối với ông/bà ${employeeName}.`,
        leftX,
        y,
        { width: 495, align: 'left' }
      );
      y += 16;
      doc.text(`- Lý do chi tiết: ${reason}`, leftX, y, { width: 495, align: 'left' });
      y += 14;
      if (amountNum > 0) {
        doc.text(
          `- Số tiền (nếu có): ${new Intl.NumberFormat('vi-VN').format(amountNum)} VNĐ`,
          leftX,
          y,
          { width: 495, align: 'left' }
        );
        y += 14;
      }
      y += 14;
    }

    doc.text(
      'Điều 2. Quyết định có hiệu lực kể từ ngày ký. Phòng Kế toán, Phòng Hành chính — Nhân sự và các phòng/ban có liên quan chịu trách nhiệm thi hành quyết định này.',
      leftX,
      y,
      { width: 495, align: 'left' }
    );
    y += 56;
    doc.text('Nơi nhận:', leftX, y, { width: 200 });
    y += 14;
    doc.text('- Như Điều 2;', leftX, y);
    y += 14;
    doc.text('- Lưu: HCNS.', leftX, y);
    y += 40;
    doc.text('TM. BAN GIÁM ĐỐC', rightX, y, { width: rightW, align: 'center' });
    y += 14;
    doc.text('GIÁM ĐỐC', rightX, y, { width: rightW, align: 'center' });

    doc.end();
  });
}

function buildDecisionEmailHtml(employeeName, decisionData, isReward) {
  const { decision_number, form, amount, reason, issue_date } = decisionData;
  const amountNum = Number(amount) || 0;
  const accent = isReward ? '#059669' : '#dc2626';
  const accentBg = isReward ? '#ecfdf5' : '#fef2f2';
  const title = isReward ? 'THÔNG BÁO QUYẾT ĐỊNH KHEN THƯỞNG' : 'THÔNG BÁO QUYẾT ĐỊNH KỶ LUẬT';
  const amountRow =
    amountNum > 0
      ? `<tr>
          <td style="padding:10px 12px;border-bottom:1px solid #e5e7eb;color:#6b7280;width:38%;">Số tiền</td>
          <td style="padding:10px 12px;border-bottom:1px solid #e5e7eb;font-weight:600;">${escapeHtml(
            new Intl.NumberFormat('vi-VN').format(amountNum)
          )} VNĐ</td>
        </tr>`
      : '';

  return `
    <div style="font-family: Georgia, 'Times New Roman', serif; background:#f3f4f6; padding:24px;">
      <div style="max-width:600px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden;border:1px solid #e5e7eb;">
        <div style="background:${accent};color:#fff;padding:22px 24px;text-align:center;">
          <h1 style="margin:0;font-size:20px;letter-spacing:0.5px;">${title}</h1>
          <p style="margin:10px 0 0;font-size:14px;opacity:0.95;">Ban hành kèm bản quyết định định dạng PDF</p>
        </div>
        <div style="padding:24px;color:#1f2937;line-height:1.65;font-size:15px;">
          <p>Kính gửi <strong>${escapeHtml(employeeName)}</strong>,</p>
          <p>Phòng Hành chính — Nhân sự trân trọng thông báo: Công ty đã ban hành quyết định hành chính liên quan đến Anh/Chị. Dưới đây là tóm tắt nội dung; văn bản chính thức đính kèm file PDF.</p>
          <table style="width:100%;border-collapse:collapse;margin:20px 0;background:${accentBg};border-radius:8px;overflow:hidden;">
            <tr>
              <td style="padding:10px 12px;border-bottom:1px solid #e5e7eb;color:#6b7280;width:38%;">Họ và tên</td>
              <td style="padding:10px 12px;border-bottom:1px solid #e5e7eb;font-weight:600;">${escapeHtml(employeeName)}</td>
            </tr>
            <tr>
              <td style="padding:10px 12px;border-bottom:1px solid #e5e7eb;color:#6b7280;">Số quyết định</td>
              <td style="padding:10px 12px;border-bottom:1px solid #e5e7eb;font-weight:600;">${escapeHtml(decision_number)}</td>
            </tr>
            <tr>
              <td style="padding:10px 12px;border-bottom:1px solid #e5e7eb;color:#6b7280;">Hình thức</td>
              <td style="padding:10px 12px;border-bottom:1px solid #e5e7eb;font-weight:600;">${escapeHtml(form)}</td>
            </tr>
            ${amountRow}
            <tr>
              <td style="padding:10px 12px;border-bottom:1px solid #e5e7eb;color:#6b7280;vertical-align:top;">Ngày hiệu lực</td>
              <td style="padding:10px 12px;border-bottom:1px solid #e5e7eb;font-weight:600;">${escapeHtml(
                formatVietnameseCalendarDate(issue_date)
              )}</td>
            </tr>
            <tr>
              <td style="padding:10px 12px;color:#6b7280;vertical-align:top;">Lý do chi tiết</td>
              <td style="padding:10px 12px;">${escapeHtml(reason).replace(/\n/g, '<br/>')}</td>
            </tr>
          </table>
          <p style="margin-bottom:0;">Trân trọng,<br/><strong>Phòng Hành chính — Nhân sự</strong><br/><span style="color:#6b7280;font-size:13px;">Email được gửi tự động từ hệ thống Quản lý Nhân sự GPS</span></p>
        </div>
      </div>
    </div>
  `;
}

const sendOTPEmail = async (toEmail, otpCode) => {
  const html = `<h2>Mã OTP của bạn là: ${otpCode}</h2>`;
  try {
    await transportMail({ to: toEmail, subject: 'Mã xác nhận OTP', html });
    return true;
  } catch (error) {
    console.error('Lỗi gửi OTP:', error);
    throw error;
  }
};

/**
 * Gửi Thông tin tài khoản
 */
const sendAccountEmail = async (email, fullName, username, password) => {
  const html = `
    <div style="font-family: Arial;">
      <h2>Chào mừng ${fullName}</h2>
      <p>User: <b>${username}</b></p>
      <p>Pass: <b>${password}</b></p>
    </div>
  `;
  try {
    // Ở đây ta KHÔNG await để nó chạy ngầm, tránh treo API
    transportMail({ to: email, subject: 'Cấp tài khoản hệ thống', html })
      .catch(e => console.error("Gửi mail ngầm thất bại:", e));
    return true;
  } catch (error) {
    console.error('Lỗi kích hoạt luồng gửi email:', error);
    return false;
  }
};

/**
 * Gửi Quyết định (Đính kèm PDF)
 */
const sendDecisionEmail = async (email, employeeName, decisionData, pdfBuffer) => {
  const { decision_number, decision_type } = decisionData;
  const isReward = decision_type === 'reward';
  const subject = isReward ? `[Khen thưởng] ${decision_number}` : `[Kỷ luật] ${decision_number}`;
  const html = buildDecisionEmailHtml(employeeName, decisionData, isReward);
  
  const attachments = [
    {
      filename: safePdfFilename(decision_number),
      content: pdfBuffer,
    }
  ];

  try {
    await transportMail({ to: email, subject, html, attachments });
    return true;
  } catch (error) {
    console.error('Lỗi gửi quyết định:', error);
    throw error;
  }
};

module.exports = {
  sendOTPEmail,
  sendAccountEmail,
  sendDecisionEmail,
  generateDecisionPdfBuffer,
};