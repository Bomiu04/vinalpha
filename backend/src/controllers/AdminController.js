const db = require('../config/database');

const getAllUsers = async (req, res) => {
  try {
    // Truy vấn kết hợp (JOIN) bảng employee và user_account
    // Sắp xếp Admin lên đầu tiên, sau đó theo tên Alphabet
    const query = `
      SELECT 
        e.id, 
        e.full_name as name, 
        e.work_email as email, 
        ua.username, 
        ua.role_code, 
        ua.status 
      FROM employee e
      JOIN user_account ua ON e.id = ua.employee_id
      ORDER BY 
        CASE WHEN ua.role_code = 'ADMIN' THEN 1 ELSE 2 END,
        e.full_name ASC
    `;
    
    // Thực thi truy vấn
    const usersDB = await db.query(query, { type: db.QueryTypes.SELECT });

    // Format lại dữ liệu để khớp y hệt với giao diện Frontend Figma
    const users = usersDB.map(user => ({
      id: user.id,
      name: user.name,
      email: user.email || 'Chưa cập nhật',
      username: user.username,
      // Chuyển đổi mã Quyền (Role) sang chữ hiển thị đẹp
      role: user.role_code === 'ADMIN' ? 'System Admin' : (user.role_code === 'HR' ? 'HR Manager' : 'User'),
      // Tạm thời Fake thời gian và IP (Sau này có thể thêm bảng log để query thật)
      lastLoginTime: 'Vừa xong', 
      lastLoginIp: 'IP: 192.168.1.1',
      // Xử lý trạng thái (active/inactive)
      status: user.status === 'active',
      security: user.status === 'active' ? (user.role_code === 'ADMIN' ? 'Hệ thống' : 'Bình thường') : 'Bị khóa',
      inactive: user.status !== 'active',
      // Tự động tạo Avatar từ tên thật
      avatar: `https://ui-avatars.com/api/?name=${encodeURIComponent(user.name)}&background=random&color=fff`
    }));

    res.status(200).json({ success: true, users });
  } catch (error) {
    console.error('Lỗi lấy danh sách user:', error);
    res.status(500).json({ success: false, message: 'Lỗi máy chủ nội bộ khi lấy danh sách tài khoản' });
  }
};

module.exports = {
  getAllUsers
};