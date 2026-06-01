const express = require('express');
const router = express.Router();

// ==========================================
// IMPORT CONTROLLERS
// (Import phân tách rõ ràng từng hàm để code gọn hơn)
// ==========================================
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Tự động tạo thư mục uploads nếu chưa tồn tại
const uploadDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Cấu hình Multer chung (cho các file khác nếu có)
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir); 
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'ADMIN-' + uniqueSuffix + path.extname(file.originalname));
  }
});
const upload = multer({ storage: storage });

// Cấu hình Multer riêng cho Avatar
const avatarStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    const dir = path.join(__dirname, '../../uploads/avatars/');
    if (!fs.existsSync(dir)){
        fs.mkdirSync(dir, { recursive: true });
    }
    cb(null, dir);
  },
  filename: function (req, file, cb) {
    const uniqueName = Date.now() + '-' + file.originalname;
    cb(null, uniqueName);
  }
});
const uploadAvatar = multer({ storage: avatarStorage });

const { 
  getAllUsers, 
  createUser, 
  updateUser, 
  getEmployeesWithoutAccount, 
  adminForceResetPassword,
  syncManagerAssignments
} = require('../controllers/AdminController');

const { 
  getLocations, 
  createLocation, 
  updateLocationSettings, 
  deleteWorkLocation,
  getEmployeesByDepartment,
  getWorkLocationsByBranch,
  createLocationAssignment,
  getPositionsByDepartment,
  checkDepartmentManager,
  getBranches,
  getDepartmentsByBranch
} = require('../controllers/locationController');

const authenticateToken = require('../middlewares/authMiddleware');

// Áp dụng Auth Middleware cho toàn bộ route admin
router.use(authenticateToken);

// ==========================================
// QUẢN LÝ USER / NHÂN VIÊN
// Gốc: /api/admin/...
// ==========================================
router.get('/users', getAllUsers); 
router.post('/users', uploadAvatar.single('avatar'), createUser); 
router.put('/users/:id', uploadAvatar.single('avatar'), updateUser);
router.get('/employees-no-account', getEmployeesWithoutAccount);
router.post('/force-reset-password', adminForceResetPassword);
router.post('/sync-managers', syncManagerAssignments); // Đồng bộ direct_manager_id toàn hệ thống

// ==========================================
// QUẢN LÝ CHẤM CÔNG (ADMIN)
// ==========================================
router.get('/attendance', async (req, res) => {
  const db = require('../config/database');
  const { QueryTypes } = require('sequelize');
  try {
    const date = req.query.date || new Date(new Date().getTime() + 7*3600000).toISOString().slice(0,10);
    const rows = await db.query(`
      SELECT
        e.employee_code, e.full_name,
        d.department_name,
        a.check_in_time, a.check_out_time,
        a.status, a.total_work_hours,
        a.attendance_date
      FROM employee e
      LEFT JOIN attendance a ON a.employee_id = e.id AND a.attendance_date = :date
      LEFT JOIN position p ON e.position_id = p.id
      LEFT JOIN department d ON p.department_id = d.id
      WHERE e.status = 'active'
      ORDER BY d.department_name, e.full_name
    `, { replacements: { date }, type: QueryTypes.SELECT });
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ==========================================
// QUẢN LÝ ĐỊA ĐIỂM CHẤM CÔNG (LOCATIONS)
// Gốc: /api/admin/locations
// ==========================================
router.get('/locations', getLocations);
router.post('/locations', createLocation); 
router.put('/locations/:id/settings', updateLocationSettings); 
router.delete('/locations/:id/work-location', deleteWorkLocation);

// ==========================================
// QUẢN LÝ PHÂN CẤP (HIERARCHY) CHO LOCATION
// Gốc: /api/admin/hierarchy
// ==========================================

// Lấy danh sách chi nhánh
router.get('/hierarchy/branches', getBranches);
// Lấy danh sách phòng ban theo chi nhánh
router.get('/hierarchy/departments/:branchId', getDepartmentsByBranch);
// Lấy danh sách nhân viên theo phòng ban
router.get('/hierarchy/employees/:departmentId', getEmployeesByDepartment);
// Lấy danh sách địa điểm làm việc theo chi nhánh
router.get('/hierarchy/work-locations/:branchId', getWorkLocationsByBranch);
// Tạo phân công (Branch/Department/Employee)
router.post('/hierarchy/assignments', createLocationAssignment);

// --- CÁC ROUTE PHỤ TRỢ CHO CASCADING DROPDOWN ---
router.get('/hierarchy/positions/:departmentId', getPositionsByDepartment);
router.get('/hierarchy/departments/:id/manager-check', checkDepartmentManager);

module.exports = router;