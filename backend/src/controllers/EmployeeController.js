const db = require('../config/database');
const { QueryTypes } = require('sequelize');
exports.getDashboard = async (req, res) => {
  try {
    const { id } = req.params;

    console.log("ID:", id);

    // 1. Nhân viên
   const employeeResult = await db.query(
  `SELECT full_name FROM employee WHERE id = $1`,
  {
    bind: [id],
    type: QueryTypes.SELECT
  }
    );

const employee = employeeResult[0];

    if (!employee) {
      return res.status(404).json({ message: 'Không tìm thấy nhân viên' });
    }

        const statsResult = await db.query(`
              SELECT 
                COUNT(*) FILTER (WHERE status = 'on_time')::int AS present,
                COUNT(*) FILTER (WHERE status IN ('late','early_leave'))::int AS late,
                COUNT(*) FILTER (WHERE status = 'absent')::int AS absent
              FROM attendance
              WHERE employee_id = $1
              AND EXTRACT(MONTH FROM attendance_date) = EXTRACT(MONTH FROM CURRENT_DATE)
              AND EXTRACT(YEAR FROM attendance_date) = EXTRACT(YEAR FROM CURRENT_DATE)
            `, {
              bind: [id],
              type: QueryTypes.SELECT
            });

        const stats = statsResult[0];

    res.json({
      employee,
      stats
    });

  } catch (error) {
    console.error("🔥 LỖI:", error);
    res.status(500).json({ message: 'Lỗi server', error: error.message });
  }
};