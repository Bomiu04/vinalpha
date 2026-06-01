# Hướng dẫn cài đặt VINALPHA HR System

## Yêu cầu
- Node.js >= 18
- PostgreSQL >= 14
- npm

## Các bước cài đặt

### 1. Clone repo
```bash
git clone https://github.com/ngochoi123/HRM---GPS-Tracking.git
cd HRM---GPS-Tracking
```

### 2. Cài đặt Backend
```bash
cd 1_Source_Code/backend
npm install
```
Tạo file `.env` từ mẫu:
```bash
cp .env.example .env
```
Sửa `.env` — điền `DB_PASSWORD` là mật khẩu PostgreSQL của bạn.

### 3. Tạo database
Mở pgAdmin4 hoặc psql, chạy:
```sql
CREATE DATABASE attendance_db;
```
Sau đó restore từ file backup:
```bash
psql -U postgres -d attendance_db -f 1_Source_Code/backup_attendance_db_2026-05-20T21-55-34.sql
```

### 4. Seed dữ liệu mẫu
```bash
cd 1_Source_Code/backend
node seed_contracts.js
node seed_attendance_payroll.js
```

### 5. Cài đặt Frontend
```bash
cd 1_Source_Code/frontend
npm install
```

### 6. Chạy hệ thống

**Terminal 1 — Backend:**
```bash
cd 1_Source_Code/backend
npm run dev
```

**Terminal 2 — Frontend:**
```bash
cd 1_Source_Code/frontend
npm run dev
```

Truy cập: http://localhost:5173

## Tài khoản mặc định
| Vai trò | Username | Mật khẩu |
|---------|----------|-----------|
| Admin | admin | 123456 |
| Giám đốc | ceo | 123456 |
| Quản lý | manager | 123456 |
| Nhân viên | employee | 123456 |
