const express = require('express');
const router = express.Router();
const locationController = require('../controllers/locationController');

// Lấy danh sách chi nhánh và cấu hình
router.get('/', locationController.getLocations);

// Cập nhật cấu hình cho 1 chi nhánh (ID nằm trên URL)
router.put('/:branchId/settings', locationController.updateLocationSettings);

module.exports = router;