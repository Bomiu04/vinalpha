const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { QueryTypes } = require('sequelize');
const notificationController = require('../controllers/notificationController');

// ==========================================
// 1️⃣ LẤY DANH SÁCH THÔNG BÁO (ADMIN)
// ==========================================
router.get('/', async (req, res) => {
  try {
    const notifications = await db.query(
      `SELECT * FROM notification ORDER BY created_at DESC`,
      { type: QueryTypes.SELECT }
    );
    res.json(notifications);
  } catch (err) {
    console.error("🔥 Lỗi lấy thông báo:", err);
    res.status(500).json({ message: 'Lỗi lấy danh sách thông báo' });
  }
});

// ==========================================
// 1.1️⃣ CHUÔNG THÔNG BÁO (NHÂN VIÊN)
// ==========================================
router.get('/my-bell/:userId', notificationController.getMyBellNotifications);
router.put('/read-all/:userId', notificationController.markAllAsRead);
router.put('/read/:notiId', notificationController.markAsRead);

// ==========================================
// 2️⃣ TẠO THÔNG BÁO MỚI (HỖ TRỢ ẢNH BASE64 & TRANSACTION)
// ==========================================
router.post('/', async (req, res) => {
  const t = await db.transaction(); // Khởi tạo transaction để đảm bảo an toàn dữ liệu
  try {
    const { 
      title, 
      content, 
      notification_type, 
      target, 
      department_id, 
      employee_id, 
      desc, 
      sender_id 
    } = req.body;

    if (!title || !String(title).trim()) {
      await t.rollback();
      return res.status(400).json({ message: "Thiếu tiêu đề thông báo" });
    }

    // INSERT vào bảng notification
    // Lưu ý: "desc" là từ khóa trong Postgres nên phải bọc trong dấu ngoặc kép
    const [newNotiRows] = await db.query(
      `INSERT INTO notification (title, content, notification_type, target, "desc", status, sender_id, created_at) 
       VALUES (:title, :content, :type, :target, :desc, 'Đã gửi', :sender, NOW()) RETURNING id`,
      {
        replacements: {
          title,
          content,
          type: notification_type || 'info',
          target: target || 'Toàn công ty',
          desc: desc || '',
          sender: sender_id || null
        },
        transaction: t
      }
    );

    const notificationId = newNotiRows?.[0]?.id;
    if (!notificationId) {
      throw new Error('Không lấy được ID thông báo vừa tạo.');
    }

    // XỬ LÝ GỬI CHO ĐỐI TƯỢNG (Lưu vào bảng notification_recipient)
    if (target === 'Toàn công ty') {
        // Gửi cho tất cả nhân viên đang làm việc
        await db.query(
            `INSERT INTO notification_recipient (notification_id, employee_id)
             SELECT :notiId, id FROM employee WHERE status = 'active'`,
            { replacements: { notiId: notificationId }, transaction: t }
        );
    } 
    else if (target === 'Phòng ban' && department_id) {
        // Gửi cho nhân viên thuộc phòng ban thông qua bảng "position"
        await db.query(
            `INSERT INTO notification_recipient (notification_id, employee_id)
             SELECT :notiId, e.id FROM employee e 
             JOIN "position" p ON e.position_id = p.id 
             WHERE p.department_id = :deptId AND e.status = 'active'`,
            { replacements: { notiId: notificationId, deptId: department_id }, transaction: t }
        );
    } 
    else if (target === 'Cá nhân' && employee_id) {
        // Gửi đích danh cho 1 nhân viên
        await db.query(
            `INSERT INTO notification_recipient (notification_id, employee_id) VALUES (:notiId, :empId)`,
            { replacements: { notiId: notificationId, empId: employee_id }, transaction: t }
        );
    }

    await t.commit(); // Xác nhận lưu mọi thay đổi
    res.status(201).json({ message: "Gửi thông báo thành công", id: notificationId });
  } catch (err) {
    await t.rollback(); // Hủy bỏ nếu có lỗi (đặc biệt khi dữ liệu ảnh quá nặng làm đứng query)
    console.error("🔥 Lỗi tạo thông báo:", err);
    res.status(500).json({ message: "Lỗi hệ thống khi lưu dữ liệu", error: err.message });
  }
});

// ==========================================
// 2.5️⃣ CẬP NHẬT THÔNG BÁO
// ==========================================
router.put('/:id', async (req, res) => {
  const t = await db.transaction();
  try {
    const { id } = req.params;
    const {
      title,
      content,
      notification_type,
      target,
      department_id,
      employee_id,
      desc,
      sender_id,
      status
    } = req.body;

    if (!title || !String(title).trim()) {
      await t.rollback();
      return res.status(400).json({ message: "Thiếu tiêu đề thông báo" });
    }

    await db.query(
      `UPDATE notification
       SET title = :title,
           content = :content,
           notification_type = :type,
           target = :target,
           "desc" = :desc,
           status = :status,
           sender_id = :sender
       WHERE id = :id`,
      {
        replacements: {
          id,
          title,
          content,
          type: notification_type || 'info',
          target: target || 'Toàn công ty',
          desc: desc || '',
          status: status || 'Đã chỉnh sửa',
          sender: sender_id || null
        },
        transaction: t
      }
    );

    await db.query(`DELETE FROM notification_recipient WHERE notification_id = :id`, {
      replacements: { id },
      transaction: t
    });

    if (target === 'Toàn công ty') {
      await db.query(
        `INSERT INTO notification_recipient (notification_id, employee_id)
        SELECT :notiId, id FROM employee WHERE status = 'active'`,
        { replacements: { notiId: id }, transaction: t }
      );
    } else if (target === 'Phòng ban' && department_id) {
      await db.query(
        `INSERT INTO notification_recipient (notification_id, employee_id)
         SELECT :notiId, e.id
         FROM employee e
         JOIN "position" p ON e.position_id = p.id
         WHERE p.department_id = :deptId
           AND e.status = 'active'`,
        { replacements: { notiId: id, deptId: department_id }, transaction: t }
      );
    } else if (target === 'Cá nhân' && employee_id) {
      await db.query(
        `INSERT INTO notification_recipient (notification_id, employee_id)
         VALUES (:notiId, :empId)`,
        { replacements: { notiId: id, empId: employee_id }, transaction: t }
      );
    }

    await t.commit();
    res.json({ message: "Cập nhật thông báo thành công" });
  } catch (err) {
    await t.rollback();
    console.error("🔥 Lỗi cập nhật thông báo:", err);
    res.status(500).json({ message: "Lỗi hệ thống khi cập nhật", error: err.message });
  }
});

// ==========================================
// 3️⃣ LẤY CHI TIẾT 1 THÔNG BÁO
// ==========================================
router.get('/:id', async (req, res) => {
    try {
        const [notification] = await db.query(
            `SELECT * FROM notification WHERE id = :id`,
            { replacements: { id: req.params.id }, type: QueryTypes.SELECT }
        );
        if (!notification) return res.status(404).json({ message: "Không tìm thấy thông báo" });
        res.json(notification);
    } catch (err) {
        res.status(500).json({ message: "Lỗi server" });
    }
});

// ==========================================
// 4️⃣ XOÁ THÔNG BÁO
// ==========================================
router.delete('/:id', async (req, res) => {
    const t = await db.transaction();
    try {
        const { id } = req.params;
        // Xoá người nhận trước (khóa ngoại)
        await db.query(`DELETE FROM notification_recipient WHERE notification_id = :id`, { replacements: { id }, transaction: t });
        // Xoá thông báo chính
        await db.query(`DELETE FROM notification WHERE id = :id`, { replacements: { id }, transaction: t });
        
        await t.commit();
        res.json({ message: "Đã xoá thông báo" });
    } catch (err) {
        await t.rollback();
        res.status(500).json({ message: "Lỗi khi xoá" });
    }
});

module.exports = router;