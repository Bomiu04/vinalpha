const express = require('express');
const router = express.Router();
const { getAllUsers, createUser, updateUser } = require('../controllers/AdminController');
const adminController = require('../controllers/AdminController');
const locationController = require('../controllers/locationController');
router.get('/users', getAllUsers); 
router.post('/users', createUser); 
router.put('/users/:id', updateUser);
router.get('/employees-no-account', adminController.getEmployeesWithoutAccount);
router.get('/locations', locationController.getLocations);
router.put('/locations/:branchId/settings', locationController.updateLocationSettings);
router.post('/locations', locationController.createLocation); // Thêm route này để tạo mới chi nhánh và cấu hình GPS

module.exports = router;