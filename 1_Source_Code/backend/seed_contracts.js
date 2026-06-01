/**
 * Seed contracts + attendance tháng 6/2026 cho tất cả nhân viên
 * Chạy: node seed_contracts.js
 */
const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost', port: 5432,
  user: 'postgres', password: '123456',
  database: 'attendance_db',
});

function rand(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function getWorkdays(year, month) {
  const days = [];
  const date = new Date(year, month - 1, 1);
  while (date.getMonth() === month - 1) {
    const dow = date.getDay();
    if (dow !== 0 && dow !== 6) days.push(new Date(date));
    date.setDate(date.getDate() + 1);
  }
  return days;
}

function getBaseSalary(roleCode) {
  const map = { director: 35000000, manager: 22000000, employee: 13000000, admin: 15000000 };
  return map[roleCode] || 13000000;
}

async function main() {
  const client = await pool.connect();
  try {
    // Lấy tất cả nhân viên + role
    const { rows: employees } = await client.query(`
      SELECT e.id AS employee_id, e.full_name, e.join_date, u.role_code
      FROM employee e
      LEFT JOIN user_account u ON u.employee_id = e.id
      WHERE e.status = 'active'
      LIMIT 50
    `);

    console.log(`Tìm thấy ${employees.length} nhân viên\n`);

    let contractCount = 0;
    let attendCount = 0;

    for (const emp of employees) {
      const baseSalary = getBaseSalary(emp.role_code);
      const allowances = JSON.stringify({
        transport: 500000,
        meal: rand(500000, 800000),
        phone: emp.role_code === 'manager' || emp.role_code === 'director' ? 300000 : 0,
      });

      // ---- 1. Tạo hợp đồng nếu chưa có ----
      const { rows: existing } = await client.query(
        `SELECT id FROM contract WHERE employee_id = $1 AND is_active = true LIMIT 1`,
        [emp.employee_id]
      );

      if (!existing.length) {
        const contractType = emp.role_code === 'director' ? 'indefinite'
          : emp.role_code === 'manager' ? 'fixed_3y' : 'fixed_1y';
        const startDate = emp.join_date || '2026-01-01';
        const contractNo = `HD-${Math.random().toString(36).substring(2, 8).toUpperCase()}`;

        await client.query(
          `INSERT INTO contract
            (contract_number, employee_id, contract_type, start_date, base_salary, allowances, is_active)
           VALUES ($1,$2,$3,$4,$5,$6,true)
           ON CONFLICT DO NOTHING`,
          [contractNo, emp.employee_id, contractType, startDate, baseSalary, allowances]
        );
        contractCount++;
        console.log(`  ✅ Hợp đồng: ${emp.full_name} - ${baseSalary.toLocaleString('vi-VN')}đ`);
      } else {
        // Cập nhật lương nếu = 0
        await client.query(
          `UPDATE contract SET base_salary = $1 WHERE employee_id = $2 AND is_active = true AND base_salary = 0`,
          [baseSalary, emp.employee_id]
        );
        console.log(`  ⏭  Đã có hợp đồng: ${emp.full_name}`);
      }

      // ---- 2. Thêm attendance tháng 6/2026 nếu chưa có ----
      const today = new Date('2026-06-01');
      const workdays = getWorkdays(2026, 6).filter(d => d <= today);

      for (const day of workdays) {
        const dateStr = day.toISOString().split('T')[0];
        const { rows: att } = await client.query(
          `SELECT id FROM attendance WHERE employee_id=$1 AND attendance_date=$2 LIMIT 1`,
          [emp.employee_id, dateStr]
        );
        if (att.length) continue;

        const roll = Math.random();
        let status, checkIn, checkOut, totalHours;

        if (roll < 0.05) {
          status = 'absent'; checkIn = null; checkOut = null; totalHours = 0;
        } else if (roll < 0.20) {
          status = 'late';
          const lateMin = rand(15, 60);
          const h = 8 + Math.floor(lateMin / 60), m = lateMin % 60;
          checkIn  = `${dateStr} ${String(h).padStart(2,'0')}:${String(m).padStart(2,'0')}:00+07`;
          checkOut = `${dateStr} 17:30:00+07`;
          totalHours = parseFloat(((17.5 * 60 - (h * 60 + m)) / 60).toFixed(2));
        } else {
          status = 'on_time';
          const inM = rand(0, 10);
          checkIn  = `${dateStr} 08:0${inM}:00+07`;
          const outM = rand(30, 59);
          checkOut = `${dateStr} 17:${String(outM).padStart(2,'0')}:00+07`;
          totalHours = parseFloat(((17 * 60 + outM - (8 * 60 + inM)) / 60).toFixed(2));
        }

        await client.query(
          `INSERT INTO attendance (employee_id, work_location_id, attendance_date, check_in_time, check_out_time, status, total_work_hours)
           VALUES ($1, 1, $2, $3, $4, $5, $6) ON CONFLICT DO NOTHING`,
          [emp.employee_id, dateStr, checkIn, checkOut, status, totalHours]
        );
        attendCount++;
      }
    }

    console.log(`\n✅ Hoàn thành!`);
    console.log(`   - Hợp đồng mới: ${contractCount}`);
    console.log(`   - Attendance tháng 6 thêm mới: ${attendCount}`);
    console.log(`\nBây giờ vào "Xem bảng lương" → chọn Tháng 6/2026 → bấm Tìm để tính lương.`);
  } catch (err) {
    console.error('Lỗi:', err.message);
    throw err;
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch(console.error);
