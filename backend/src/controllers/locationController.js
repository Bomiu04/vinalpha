const db = require('../config/database');

// 1. LẤY DANH SÁCH CHI NHÁNH & CẤU HÌNH GPS
const getLocations = async (req, res) => {
  try {
    const query = `
      SELECT 
        b.id AS branch_id, 
        b.branch_code, 
        b.branch_name, 
        b.address, 
        b.is_active, 
        b.allowed_ips,
        w.id AS work_location_id, 
        w.latitude, 
        w.longitude, 
        w.radius_meters
      FROM branch b
      LEFT JOIN work_location w ON b.work_location_id = w.id
      ORDER BY b.id ASC;
    `;
    const locations = await db.query(query, { type: db.QueryTypes.SELECT });
    res.status(200).json({ success: true, data: locations });
  } catch (error) {
    console.error("Lỗi lấy danh sách địa điểm:", error);
    res.status(500).json({ success: false, message: "Lỗi máy chủ nội bộ" });
  }
};

// 2. CẬP NHẬT CẤU HÌNH GPS & WIFI CHO CHI NHÁNH
const updateLocationSettings = async (req, res) => {
  const { branchId } = req.params;
  const { latitude, longitude, radius_meters, allowed_ips, is_active } = req.body;

  // Bắt đầu Transaction để đảm bảo an toàn cho cả 2 bảng
  const transaction = await db.transaction();

  try {
    // 1. Lấy thông tin chi nhánh hiện tại
    const [branch] = await db.query(`SELECT work_location_id, branch_name FROM branch WHERE id = :branchId`, {
      replacements: { branchId },
      type: db.QueryTypes.SELECT,
      transaction
    });

    if (!branch) {
      await transaction.rollback();
      return res.status(404).json({ success: false, message: "Không tìm thấy chi nhánh này!" });
    }

    let workLocationId = branch.work_location_id;

    // 2. Xử lý phần GPS (Bảng work_location)
    if (latitude && longitude && radius_meters) {
      if (workLocationId) {
        // Đã có tọa độ -> Cập nhật
        await db.query(`
          UPDATE work_location 
          SET latitude = :latitude, longitude = :longitude, radius_meters = :radius_meters 
          WHERE id = :workLocationId
        `, { replacements: { latitude, longitude, radius_meters, workLocationId }, transaction });
      } else {
        // Chưa có tọa độ -> Tạo mới và gắn ID vào chi nhánh
        const [newLoc] = await db.query(`
          INSERT INTO work_location (location_name, location_type, latitude, longitude, radius_meters) 
          VALUES (:name, 'branch', :latitude, :longitude, :radius_meters) RETURNING id
        `, { replacements: { name: branch.branch_name, latitude, longitude, radius_meters }, transaction });
        
        workLocationId = newLoc[0].id;
      }
    }

    // 3. Cập nhật bảng Branch (Wifi IP, Trạng thái, và gắn work_location_id nếu mới tạo)
    await db.query(`
      UPDATE branch 
      SET allowed_ips = ARRAY[:allowed_ips]::TEXT[], 
          is_active = :is_active,
          work_location_id = :workLocationId
      WHERE id = :branchId
    `, {
      replacements: { allowed_ips: allowed_ips || [], is_active, workLocationId, branchId },
      transaction
    });

    await transaction.commit();
    res.status(200).json({ success: true, message: "Cập nhật cấu hình thành công!" });

  } catch (error) {
    await transaction.rollback();
    console.error("Lỗi cập nhật cấu hình:", error);
    res.status(500).json({ success: false, message: "Lỗi lưu dữ liệu" });
  }
};

module.exports = { getLocations, updateLocationSettings };