const sequelize = require('../config/database'); 

const notificationController = {
  // 1. DÀNH CHO QUẢN LÝ: Lấy danh sách tất cả thông báo
  getAllNotifications: async (req, res) => {
    try {
      const query = `
        SELECT id, sender_id, title, "desc", content, target, status, notification_type, created_at 
        FROM notification 
        ORDER BY created_at DESC
      `;
      const [results] = await sequelize.query(query);
      res.status(200).json(results);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Lỗi server khi lấy thông báo' });
    }
  },

  // 2. DÀNH CHO QUẢN LÝ: Tạo thông báo mới
  createNotification: async (req, res) => {
    const t = await sequelize.transaction(); 
    try {
      const { title, content, target, notification_type, sender_id, desc, status } = req.body;
      const safeSenderId = sender_id || null;

      const insertNotiQuery = `
        INSERT INTO notification (sender_id, title, "desc", content, target, status, notification_type) 
        VALUES (:sender_id, :title, :desc, :content, :target, :status, :notification_type::notification_type) 
        RETURNING id
      `;
      const [notiResult] = await sequelize.query(insertNotiQuery, {
        replacements: { 
          sender_id: safeSenderId, title, desc: desc || '', 
          content, target: target || 'Tất cả nhân viên', 
          status: status || 'Đã gửi', notification_type 
        },
        transaction: t
      });
      const newNotiId = notiResult[0].id; 

      // ĐẢM BẢO: Lấy tất cả nhân viên để rải thông báo
      const [empResult] = await sequelize.query(
        `SELECT id FROM employee`, 
        { transaction: t }
      );
      const employeeIds = empResult.map(emp => emp.id);

      // Rải thông báo vào bảng notification_recipient
      if (employeeIds.length > 0) {
        const valuesString = employeeIds.map(id => `('${newNotiId}', '${id}', false)`).join(', ');
        await sequelize.query(`
          INSERT INTO notification_recipient (notification_id, employee_id, is_read) 
          VALUES ${valuesString}
        `, { transaction: t });
      }

      await t.commit(); 
      res.status(201).json({ message: 'Tạo thông báo thành công!' });
    } catch (error) {
      await t.rollback(); 
      console.error("=== LỖI TẠO THÔNG BÁO ===", error);
      res.status(500).json({ message: 'Lỗi khi tạo thông báo' });
    }
  },

  // [THÊM MỚI] 2.5. DÀNH CHO QUẢN LÝ: Chỉnh sửa thông báo
  updateNotification: async (req, res) => {
    const t = await sequelize.transaction();
    try {
      const { id } = req.params;
      // Đảm bảo lấy đầy đủ các trường từ body
      const { title, content, target, notification_type, desc, status } = req.body;

      // 1. Cập nhật bảng thông báo
      const updateQuery = `
        UPDATE notification 
        SET 
          title = :title, 
          "desc" = :desc, 
          content = :content, 
          target = :target, 
          status = :status, 
          notification_type = :notification_type::notification_type 
        WHERE id = :id
      `;
      
      await sequelize.query(updateQuery, {
        replacements: { 
          id, 
          title, 
          desc: desc || '', 
          content, 
          target: target || 'Tất cả nhân viên', 
          notification_type, 
          status: status || 'Đã gửi' // Nếu không có status thì mặc định là Đã gửi
        },
        transaction: t
      });

      // 2. Logic rải chuông cho nhân viên:
      // Nếu trạng thái chuyển từ Nháp sang "Đã gửi" hoặc "Đã chỉnh sửa"
      if (status !== 'Nháp') {
        // Xóa các bản ghi cũ trong bảng recipient để tránh bị lặp thông báo khi sửa nhiều lần
        await sequelize.query(`DELETE FROM notification_recipient WHERE notification_id = :id`, { 
          replacements: { id }, 
          transaction: t 
        });
        
        // Lấy danh sách nhân viên để rải lại
        const [empResult] = await sequelize.query(`SELECT id FROM employee`, { transaction: t });
        const employeeIds = empResult.map(emp => emp.id);

        if (employeeIds.length > 0) {
          const valuesString = employeeIds.map(empId => `('${id}', '${empId}', false)`).join(', ');
          await sequelize.query(`
            INSERT INTO notification_recipient (notification_id, employee_id, is_read) 
            VALUES ${valuesString}
          `, { transaction: t });
        }
      }

      await t.commit();
      res.status(200).json({ message: 'Cập nhật thành công' });
    } catch (error) {
      await t.rollback();
      console.error("=== LỖI CẬP NHẬT ===", error);
      res.status(500).json({ message: 'Lỗi hệ thống khi cập nhật' });
    }
  },

  // 3. DÀNH CHO NHÂN VIÊN: Lấy chuông thông báo cá nhân
  getMyBellNotifications: async (req, res) => {
    try {
      const { userId } = req.params;
      // [ĐÃ SỬA]: Cập nhật gọi thêm cột n.status để Frontend có thể hiển thị chữ "Đã chỉnh sửa"
      const query = `
        SELECT n.id, n.title, n."desc", n.content, n.target, n.status, n.notification_type, n.created_at, nr.is_read
        FROM notification n
        JOIN notification_recipient nr ON n.id = nr.notification_id
        WHERE nr.employee_id = :userId
        ORDER BY n.created_at DESC
      `;
      const [results] = await sequelize.query(query, {
        replacements: { userId }
      });
      res.status(200).json(results);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Lỗi lấy chuông thông báo' });
    }
  },

  // 4. DÀNH CHO NHÂN VIÊN: Đánh dấu 1 thông báo là đã đọc
  markAsRead: async (req, res) => {
    try {
      const { notiId } = req.params;
      const { userId } = req.body;
      
      const query = `
        UPDATE notification_recipient 
        SET is_read = true, read_at = NOW() 
        WHERE notification_id = :notiId AND employee_id = :userId
      `;
      await sequelize.query(query, {
        replacements: { notiId, userId }
      });
      res.status(200).json({ message: 'Đã cập nhật trạng thái đọc thành công' });
    } catch (error) {
      console.error("=== LỖI UPDATE ĐÃ ĐỌC ===", error);
      res.status(500).json({ message: 'Lỗi cập nhật', error: error.message });
    }
  },

  // (Optional) Đánh dấu đọc tất cả
  markAllAsRead: async (req, res) => {
    try {
      const { userId } = req.params;
      await sequelize.query(`
        UPDATE notification_recipient SET is_read = true, read_at = NOW() WHERE employee_id = :userId AND is_read = false
      `, { replacements: { userId } });
      res.status(200).json({ message: 'Đã đọc tất cả' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Lỗi' });
    }
  }
};

module.exports = notificationController;