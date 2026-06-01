/**
 * Seed script: Tạo dữ liệu chấm công và lương ảo cho tất cả nhân viên
 * Chạy: node seed_attendance_payroll.js
 */

const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  user: 'postgres',
  password: '123456',
  database: 'attendance_db',
});

// Ngày làm việc trong tháng (bỏ thứ 7, CN)
function getWorkdays(year, month) {
  const days = [];
  const date = new Date(year, month - 1, 1);
  while (date.getMonth() === month - 1) {
    const dow = date.getDay();
    if (dow !== 0 && dow !== 6) {
      days.push(new Date(date));
    }
    date.setDate(date.getDate() + 1);
  }
  return days;
}

// Random int trong [min, max]
function rand(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

// Lương cơ bản theo vai trò
function getBaseSalary(roleCode) {
  const map = {
    director: 35000000,
    manager:  22000000,
    employee: 13000000,
    admin:    15000000,
  };
  return map[roleCode] || 13000000;
}

// Tạo dữ liệu attendance cho 1 nhân viên, 1 tháng
async function seedAttendanceMonth(client, employeeId, year, month, payrollId) {
  const workdays = getWorkdays(year, month);
  let workDaysCount = 0;

  for (const day of workdays) {
    // 5% vắng, 15% đi trễ, 5% về sớm, 75% đúng giờ
    const roll = Math.random();
    let status, checkIn, checkOut, totalHours;

    const dateStr = day.toISOString().split('T')[0];

    if (roll < 0.05) {
      // Vắng mặt
      status = 'absent';
      checkIn = null;
      checkOut = null;
      totalHours = 0;
    } else if (roll < 0.20) {
      // Đi trễ (8:15 - 9:00)
      status = 'late';
      const lateMin = rand(15, 60);
      const checkInH = 8 + Math.floor((lateMin) / 60);
      const checkInM = lateMin % 60;
      checkIn  = `${dateStr} ${String(checkInH).padStart(2,'0')}:${String(checkInM).padStart(2,'0')}:00+07`;
      checkOut = `${dateStr} 17:30:00+07`;
      totalHours = parseFloat(((17.5 * 60 - (checkInH * 60 + checkInM)) / 60).toFixed(2));
      workDaysCount++;
    } else if (roll < 0.25) {
      // Về sớm (trước 17:00)
      status = 'early_leave';
      checkIn  = `${dateStr} 08:00:00+07`;
      const outH = rand(14, 16);
      const outM = rand(0, 59);
      checkOut = `${dateStr} ${String(outH).padStart(2,'0')}:${String(outM).padStart(2,'0')}:00+07`;
      totalHours = parseFloat(((outH * 60 + outM - 8 * 60) / 60).toFixed(2));
      workDaysCount++;
    } else {
      // Đúng giờ
      status = 'on_time';
      const inM = rand(0, 10); // 8:00 - 8:10
      checkIn  = `${dateStr} 08:0${inM}:00+07`;
      const outM2 = rand(30, 59); // 17:30 - 17:59
      checkOut = `${dateStr} 17:${String(outM2).padStart(2,'0')}:00+07`;
      totalHours = parseFloat(((17 * 60 + outM2 - (8 * 60 + inM)) / 60).toFixed(2));
      workDaysCount++;
    }

    await client.query(
      `INSERT INTO attendance
        (employee_id, work_location_id, attendance_date, check_in_time, check_out_time,
         status, total_work_hours, payroll_id)
       VALUES ($1, 1, $2, $3, $4, $5, $6, $7)
       ON CONFLICT DO NOTHING`,
      [employeeId, dateStr, checkIn, checkOut, status, totalHours, payrollId]
    );
  }

  return { workDays: workDaysCount, totalDays: workdays.length };
}

async function main() {
  const client = await pool.connect();
  try {
    console.log('Lấy danh sách nhân viên...');

    // Lấy tất cả nhân viên active kèm role
    const { rows: employees } = await client.query(`
      SELECT e.id AS employee_id, e.full_name, u.role_code
      FROM employee e
      LEFT JOIN user_account u ON u.employee_id = e.id
      WHERE e.status = 'active'
      LIMIT 50
    `);

    console.log(`Tìm thấy ${employees.length} nhân viên`);

    const months = [
      { year: 2026, month: 3 },
      { year: 2026, month: 4 },
      { year: 2026, month: 5 },
    ];

    let totalPayroll = 0;
    let totalAttendance = 0;

    for (const emp of employees) {
      const baseSalary = getBaseSalary(emp.role_code);
      console.log(`\nXử lý: ${emp.full_name} (${emp.role_code || 'employee'}) - lương: ${baseSalary.toLocaleString('vi-VN')}đ`);

      for (const { year, month } of months) {
        const monthYear = `${year}-${String(month).padStart(2, '0')}`;
        const workdays = getWorkdays(year, month);
        const totalWorkDays = workdays.length;

        // Tạo payroll trước để lấy id
        const payrollStatus = month < 5 ? 'paid' : (month === 5 ? 'approved' : 'draft');
        const allowance = rand(500000, 2000000);
        const deduction = Math.round(baseSalary * 0.105); // BHXH 10.5%

        // Estimate net salary (sẽ cập nhật sau khi có actual work days)
        const estimatedNet = baseSalary + allowance - deduction;

        const { rows: payrollRows } = await client.query(
          `INSERT INTO payroll
            (employee_id, month_year, base_salary_snapshot, total_work_days,
             total_allowance, total_deduction, net_salary, status)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
           ON CONFLICT DO NOTHING
           RETURNING id`,
          [emp.employee_id, monthYear, baseSalary, totalWorkDays, allowance, deduction, estimatedNet, payrollStatus]
        );

        const payrollId = payrollRows[0]?.id;
        if (!payrollId) {
          console.log(`  Tháng ${monthYear}: bỏ qua (đã có dữ liệu)`);
          continue;
        }
        totalPayroll++;

        // Tạo attendance
        const { workDays } = await seedAttendanceMonth(client, emp.employee_id, year, month, payrollId);
        totalAttendance += workDays;

        // Cập nhật payroll với số ngày thực tế
        const actualNetSalary = Math.round((baseSalary / totalWorkDays) * workDays + allowance - deduction);
        await client.query(
          `UPDATE payroll SET total_work_days = $1, net_salary = $2 WHERE id = $3`,
          [workDays, actualNetSalary, payrollId]
        );

        console.log(`  Tháng ${monthYear}: ${workDays}/${totalWorkDays} ngày làm - lương thực: ${actualNetSalary.toLocaleString('vi-VN')}đ`);
      }
    }

    console.log(`\n✅ Hoàn thành!`);
    console.log(`   - Payroll records: ${totalPayroll}`);
    console.log(`   - Attendance records: ${totalAttendance}`);
  } catch (err) {
    console.error('Lỗi:', err.message);
    throw err;
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch(console.error);
