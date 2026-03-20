const express = require('express');
const router = express.Router();
const adminController = require('../controllers/AdminController');

// API lấy danh sách người dùng: GET /api/admin/users
router.get('/users', adminController.getAllUsers);

module.exports = router;