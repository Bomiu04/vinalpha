const express = require('express');
const cors = require('cors');
const db = require('./config/database');
require('dotenv').config();

const app = express();

// ================= MIDDLEWARE =================
app.use(cors());

app.use(express.json({ limit: '100mb' }));
app.use(express.urlencoded({ 
  limit: '100mb', 
  extended: true, 
  parameterLimit: 100000 
}));

// ================= IMPORT ROUTES =================
const authRoutes = require('./routes/authRoutes');
const adminRoutes = require('./routes/adminRoutes');          // sửa tên
const directorRoutes = require('./routes/directorRoutes');    // ✅ thêm mới
const employeeRoutes = require('./routes/employeeRoutes');    // sửa tên
const managementRoutes = require('./routes/managementRoutes');
const notificationRoutes = require('./routes/notificationRoutes');

// ================= USE ROUTES =================
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/director', directorRoutes);   // ✅ giám đốc

app.use('/api/employees', employeeRoutes);  // sửa cho chuẩn REST
app.use('/api/manager', managementRoutes);
app.use('/api/notifications', notificationRoutes);
app.use(express.json());
// ================= TEST ROUTE =================
app.get('/', (req, res) => {
  res.send('🚀 API GPS Attendance đang hoạt động...');
});

// ================= GLOBAL ERROR HANDLER =================
app.use((err, req, res, next) => {
  console.error('🔥 GLOBAL ERROR:', err);
  res.status(500).json({
    message: 'Lỗi server',
    error: err.message
  });
});

// ================= CONNECT DB =================
db.authenticate()
  .then(() => console.log('✅ Kết nối Database thành công!'))
  .catch(err => console.error('❌ Lỗi kết nối Database:', err));

// ================= START SERVER =================
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});