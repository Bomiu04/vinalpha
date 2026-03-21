const express = require("express");
const router = express.Router();
const db = require("../config/database"); // Sequelize

// ✅ Nhân viên đã check-in
router.get("/present", async (req, res) => {
  try {
    const [results] = await db.query(`
      SELECT 
        e.full_name,
        e.phone_number,
        a.check_in_time,
        a.check_in_latitude,
        a.check_in_longitude,
        w.location_name
      FROM attendance a
      JOIN employee e ON e.id = a.employee_id
      LEFT JOIN work_location w ON w.id = a.work_location_id
      WHERE a.attendance_date = CURRENT_DATE
      AND a.check_in_time IS NOT NULL
    `);

    res.json(results);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Lỗi server" });
  }
});

// ✅ Nhân viên chưa check-in
router.get("/absent", async (req, res) => {
  try {
    const [results] = await db.query(`
      SELECT e.full_name, e.phone_number
      FROM employee e
      WHERE e.status = 'active'
      AND e.id NOT IN (
        SELECT employee_id
        FROM attendance
        WHERE attendance_date = CURRENT_DATE
        AND check_in_time IS NOT NULL
      )
    `);

    res.json(results);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Lỗi server" });
  }
});

module.exports = router;