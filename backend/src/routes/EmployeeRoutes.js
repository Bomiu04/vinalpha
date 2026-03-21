const express = require('express');
const router = express.Router();
const employeeController = require('../controllers/EmployeeController');

// API lấy thông tin dashboard nhân viên
router.get('/Dashboard/:id', employeeController.getDashboard);

module.exports = router;