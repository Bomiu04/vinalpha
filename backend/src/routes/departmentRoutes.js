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
                d.description,
                d.is_active,
                b.branch_name,
                e.full_name AS manager_name,
                e.work_email AS manager_email,
                COALESCE(emp_count.total, 0) AS total_employees
            FROM department d
            LEFT JOIN branch b ON d.branch_id = b.id
            LEFT JOIN employee e ON d.manager_id = e.id
            LEFT JOIN (
                /* Sửa logic đếm: Đếm qua bảng position */
                SELECT p.department_id, COUNT(emp.id) AS total
                FROM employee emp
                JOIN "position" p ON emp.position_id = p.id
                GROUP BY p.department_id
            ) emp_count ON emp_count.department_id = d.id
            ORDER BY d.department_name;
            `,
            { type: QueryTypes.SELECT }
        );
        res.json(departments);
    } catch (err) {
        console.error("🔥 Lỗi lấy danh sách phòng ban:", err);
        res.status(500).json({ message: 'Lỗi lấy phòng ban' });
    }
});

// ==============================
// 2️⃣ LẤY PHÒNG BAN THEO ID
// ==============================
router.get('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const [department] = await db.query(
            `
            SELECT 
                d.*, 
                b.branch_name,
                e.full_name AS manager_name
            FROM department d
            LEFT JOIN branch b ON d.branch_id = b.id
            LEFT JOIN employee e ON d.manager_id = e.id
            WHERE d.id = :id
            `,
            {
                replacements: { id },
                type: QueryTypes.SELECT
            }
        );

        if (!department) {
            return res.status(404).json({ message: "Không tìm thấy phòng ban" });
        }
        res.json(department);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Lỗi lấy chi tiết phòng ban" });
    }
});

// ==============================
// 3️⃣ LẤY NHÂN VIÊN THEO PHÒNG BAN
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
                emp.work_email,
                p.position_name
            FROM employee emp
            JOIN "position" p ON emp.position_id = p.id
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
        res.status(500).json({ message: 'Lỗi lấy danh sách nhân viên' });
    }
});

// ==============================
// 4️⃣ TẠO PHÒNG BAN
// ==============================
router.post('/', async (req, res) => {
    const { department_code, department_name, branch_id, manager_id, description, is_active } = req.body;

    if (!department_name) {
        return res.status(400).json({ message: "Thiếu tên phòng ban" });
    }

    try {
        const result = await db.query(
            `
            INSERT INTO department 
            (department_code, department_name, branch_id, manager_id, description, is_active, created_at)
            VALUES (:code, :name, :branch, :manager, :description, :active, NOW())
            RETURNING *;
            `,
            {
                replacements: {
                    code: department_code || `PB_${Date.now()}`,
                    name: department_name,
                    branch: branch_id || null,
                    manager: manager_id || null,
                    description: description || null,
                    active: is_active ?? true
                },
                type: QueryTypes.INSERT
            }
        );

        res.status(201).json({
            message: "Tạo phòng ban thành công",
            data: result[0][0]
        });
    } catch (err) {
        console.error("🔥 ERROR:", err);
        res.status(500).json({ message: err.message });
    }
});

// ==============================
// 5️⃣ CẬP NHẬT PHÒNG BAN
// ==============================
router.put('/:id', async (req, res) => {
    const { id } = req.params;
    const { department_name, branch_id, manager_id, description, is_active } = req.body;

    try {
        await db.query(
            `
            UPDATE department
            SET 
                department_name = :name,
                branch_id = :branch,
                manager_id = :manager,
                description = :description,
                is_active = :active
            WHERE id = :id
            `,
            {
                replacements: {
                    id,
                    name: department_name,
                    branch: branch_id || null,
                    manager: manager_id || null,
                    description: description || null,
                    active: is_active ?? true
                }
            }
        );
        res.json({ message: "Cập nhật phòng ban thành công" });
    } catch (err) {
        res.status(500).json({ message: "Lỗi cập nhật phòng ban" });
    }
});

// File: routes/departmentRoutes.js
// Sửa lại Route số 6 để khớp với Frontend
router.get('/dropdown/list', async (req, res) => {
  try {
    const data = await db.query(
      `SELECT id, department_name FROM department WHERE is_active = true ORDER BY department_name`,
      { type: QueryTypes.SELECT }
    );
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: "Lỗi load dropdown" });
  }
});

// ==============================
// 7️⃣ XOÁ PHÒNG BAN (Có logic chuyển nhân sự)
// ==============================
router.delete('/:id', async (req, res) => {
    const { id } = req.params;
    const { move_to_department_id } = req.body;

    try {
        // Kiểm tra nhân viên thuộc phòng ban thông qua position
        const [check] = await db.query(
            `
            SELECT COUNT(emp.id) AS total
            FROM employee emp
            JOIN "position" p ON emp.position_id = p.id
            WHERE p.department_id = :id
            `,
            { replacements: { id }, type: QueryTypes.SELECT }
        );

        const total = parseInt(check.total);

        if (total > 0) {
            if (!move_to_department_id) {
                return res.status(400).json({ message: "Phòng ban có nhân sự, vui lòng chọn phòng ban mới để chuyển họ sang." });
            }
            // Chuyển toàn bộ position thuộc phòng cũ sang phòng mới
            await db.query(
                `UPDATE "position" SET department_id = :newDept WHERE department_id = :oldDept`,
                { replacements: { newDept: move_to_department_id, oldDept: id } }
            );
        }

        await db.query(`DELETE FROM department WHERE id = :id`, { replacements: { id } });
        res.json({ message: "Xoá phòng ban thành công" });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Lỗi xoá phòng ban" });
    }
});

module.exports = router;