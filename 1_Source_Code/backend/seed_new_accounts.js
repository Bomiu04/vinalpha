/**
 * Seed tài khoản mới cho hệ thống Vinalpha
 * Chạy: node seed_new_accounts.js
 */
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');

const pool = new Pool({
  host: 'localhost', port: 5432,
  user: 'postgres', password: '123456',
  database: 'attendance_db',
});

const DEFAULT_PASSWORD = '123456';

const accounts = [
  // ADMIN
  { username: 'lethithuytrang', fullName: 'Lê Thị Thúy Trang', role: 'admin',    email: 'thuytrang.admin@vinalpha.vn',  phone: '0901000001' },
  // DIRECTOR
  { username: 'lethuytrang',    fullName: 'Lê Thúy Trang',      role: 'director', email: 'thuytrang.ceo@vinalpha.vn',    phone: '0901000002' },
  // MANAGERS
  { username: 'nguyenvanhung',  fullName: 'Nguyễn Văn Hùng',    role: 'manager',  email: 'hung.manager@vinalpha.vn',     phone: '0902000001' },
  { username: 'tranthihong',    fullName: 'Trần Thị Hồng',      role: 'manager',  email: 'hong.manager@vinalpha.vn',     phone: '0902000002' },
  { username: 'phanbaochau',    fullName: 'Phan Thị Bảo Châu',  role: 'manager',  email: 'baochau.manager@vinalpha.vn',  phone: '0902000003' },
  // EMPLOYEES
  { username: 'vothibich',      fullName: 'Võ Thị Bích',        role: 'employee', email: 'bich.nv@vinalpha.vn',          phone: '0903000001' },
  { username: 'nguyenducanh',   fullName: 'Nguyễn Đức Anh',     role: 'employee', email: 'ducanh.nv@vinalpha.vn',        phone: '0903000002' },
  { username: 'tranthilanhanh', fullName: 'Trần Thị Lan Anh',   role: 'employee', email: 'lananh.nv@vinalpha.vn',        phone: '0903000003' },
  { username: 'leminhtuan',     fullName: 'Lê Minh Tuấn',       role: 'employee', email: 'minhtuan.nv@vinalpha.vn',      phone: '0903000004' },
  { username: 'phamthimylinh',  fullName: 'Phạm Thị Mỹ Linh',  role: 'employee', email: 'mylinh.nv@vinalpha.vn',        phone: '0903000005' },
  { username: 'buithanhung',    fullName: 'Bùi Thanh Tùng',     role: 'employee', email: 'thanhtung.nv@vinalpha.vn',     phone: '0903000006' },
  { username: 'lyvannam',       fullName: 'Lý Văn Nam',         role: 'employee', email: 'vannam.nv@vinalpha.vn',        phone: '0903000007' },
  { username: 'dinhvanphuc',    fullName: 'Đinh Văn Phúc',      role: 'employee', email: 'vanphuc.nv@vinalpha.vn',       phone: '0903000008' },
  { username: 'vuthithurang',   fullName: 'Vũ Thị Thu Trang',   role: 'employee', email: 'thutrang.nv@vinalpha.vn',      phone: '0903000009' },
  { username: 'hoangthingocbich', fullName: 'Hoàng Thị Ngọc Bích', role: 'employee', email: 'ngocbich.nv@vinalpha.vn',  phone: '0903000010' },
];

async function main() {
  const client = await pool.connect();
  try {
    console.log('🔄 Xóa dữ liệu cũ...');
    await client.query('TRUNCATE TABLE attendance, payroll, contract, user_account, employee RESTART IDENTITY CASCADE');
    console.log('✅ Đã xóa dữ liệu cũ\n');

    const passwordHash = await bcrypt.hash(DEFAULT_PASSWORD, 10);
    console.log(`🔐 Password mặc định: ${DEFAULT_PASSWORD}\n`);

    for (const acc of accounts) {
      // Tạo employee
      const empCode = 'EMP-' + Math.floor(100000 + Math.random() * 900000);
      const { rows: empRows } = await client.query(
        `INSERT INTO employee (employee_code, full_name, work_email, phone_number, join_date, status)
         VALUES ($1, $2, $3, $4, CURRENT_DATE, 'active') RETURNING id`,
        [empCode, acc.fullName, acc.email, acc.phone]
      );
      const employeeId = empRows[0].id;

      // Tạo user_account
      await client.query(
        `INSERT INTO user_account (employee_id, username, password_hash, role_code, status)
         VALUES ($1, $2, $3, $4, 'active')`,
        [employeeId, acc.username, passwordHash, acc.role]
      );

      console.log(`✅ ${acc.role.padEnd(8)} | ${acc.username.padEnd(20)} | ${acc.fullName}`);
    }

    console.log(`\n🎉 Hoàn thành! Tạo ${accounts.length} tài khoản`);
    console.log(`\n📋 Danh sách đăng nhập:`);
    console.log(`${'Username'.padEnd(22)} | ${'Role'.padEnd(8)} | Password`);
    console.log('-'.repeat(45));
    accounts.forEach(a => {
      console.log(`${a.username.padEnd(22)} | ${a.role.padEnd(8)} | ${DEFAULT_PASSWORD}`);
    });

  } catch (err) {
    console.error('❌ Lỗi:', err.message);
    throw err;
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch(console.error);
