const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { QueryTypes } = require('sequelize');


// ==============================
// 1️⃣ LẤY DANH SÁCH PHÒNG BAN
// ==============================
router.get('/', async (req, res) => {
  try {
    const departments = await db.query(
      `
      SELECT 
        d.id,
        d.department_code,
        d.department_name,
        d.is_active,
        b.branch_name,

        e.full_name AS manager_name,

        COALESCE(emp_count.total, 0) AS total_employees

      FROM department d
      LEFT JOIN branch b ON d.branch_id = b.id
      LEFT JOIN employee e ON d.manager_id = e.id

      LEFT JOIN (
        SELECT position.department_id, COUNT(emp.id) AS total
        FROM employee emp
        LEFT JOIN position ON emp.position_id = position.id
        GROUP BY position.department_id
      ) emp_count ON emp_count.department_id = d.id

      ORDER BY d.department_name;
      `,
      { type: QueryTypes.SELECT }
    );

    res.json(departments);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi lấy phòng ban' });
  }
});


// ==============================
// 2️⃣ LẤY NHÂN VIÊN THEO PHÒNG BAN
// ==============================
router.get('/:id/employees', async (req, res) => {
  const { id } = req.params;

  try {
    const employees = await db.query(
      `
      SELECT 
        emp.id,
        emp.employee_code,
        emp.full_name,
        emp.phone_number,
        emp.work_email,
        p.position_name
      FROM employee emp
      LEFT JOIN position p ON emp.position_id = p.id
      WHERE p.department_id = :deptId
      ORDER BY emp.full_name;
      `,
      {
        type: QueryTypes.SELECT,
        replacements: { deptId: id }
      }
    );

    res.json(employees);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi lấy nhân viên' });
  }
});


// ==============================
// 3️⃣ TẠO PHÒNG BAN (FIX CHÍNH)
// ==============================
router.post('/', async (req, res) => {
  const { 
    department_code, 
    department_name, 
    branch_id,
    manager_id,
    is_active
  } = req.body;

  if (!department_name) {
    return res.status(400).json({
      message: "Thiếu tên phòng ban"
    });
  }

  try {
    const [result] = await db.query(
      `
      INSERT INTO department 
      (department_code, department_name, branch_id, manager_id, is_active)
      VALUES (:code, :name, :branch, :manager, :active)
      RETURNING *;
      `,
      {
        replacements: {
          code: department_code || `PB_${Date.now()}`, // 🔥 chống null
          name: department_name,
          branch: branch_id || null,
          manager: manager_id || null,
          active: is_active ?? true
        },
        type: QueryTypes.INSERT
      }
    );

    res.json({
      message: "Tạo phòng ban thành công",
      data: result[0]
    });

  } catch (err) {
    console.error("🔥 ERROR:", err);

    res.status(500).json({
      message: err.message // 👈 trả lỗi thật về FE
    });
  }
});

module.exports = router;