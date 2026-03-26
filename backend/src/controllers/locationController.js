const db = require('../config/database');

// ==========================================================
// 1. LẤY DANH SÁCH CHI NHÁNH (Đã sửa lại cú pháp JOIN)
// ==========================================================
const getLocations = async (req, res) => {
  try {
    const query = `
  SELECT 
    b.id AS id, 
    b.branch_code, 
    b.branch_name, 
    b.address, 
    b.is_active, 
    b.allowed_ips,
    w.id AS work_location_id, 
    w.location_name,
    w.location_type AS type, 
    w.latitude, 
    w.longitude, 
    w.radius_meters
  FROM branch b
  INNER JOIN work_location w ON w.branch_id = b.id
  ORDER BY b.id ASC;
`;
    const locations = await db.query(query, { type: db.QueryTypes.SELECT });
    res.status(200).json({ success: true, data: locations });
  } catch (error) {
    console.error("Lỗi getLocations:", error);
    res.status(500).json({ success: false, message: "Lỗi máy chủ nội bộ" });
  }
};

// ==========================================================
// 2. THÊM MỚI (Tạo Branch trước -> Lấy ID -> Tạo Bản đồ sau)
// ==========================================================
const createLocation = async (req, res) => {
  const { location_name, location_type, address, latitude, longitude, radius_meters, allowed_ips, is_active } = req.body;
  const transaction = await db.transaction();

  try {
    const ipPostgresFormat = '{' + (allowed_ips || []).join(',') + '}';
    const branchCode = 'CN_' + Math.floor(Math.random() * 10000); 

    // 1. LƯU VÀO BẢNG BRANCH TRƯỚC (Vì nó là cha)
    const [newBranch] = await db.query(`
      INSERT INTO branch (branch_code, branch_name, address, is_active, allowed_ips) 
      VALUES (:code, :name, :address, :is_active, :ipString::text[]) RETURNING id
    `, { 
      replacements: { 
        code: branchCode, 
        name: location_name, 
        address: address || 'Chưa cập nhật', 
        is_active: is_active ?? true, 
        ipString: ipPostgresFormat 
      }, 
      transaction 
    });

    const branchId = newBranch[0].id;

    // 2. LƯU VÀO BẢNG WORK_LOCATION (Gắn branch_id vào)
    await db.query(`
      INSERT INTO work_location (location_name, location_type, latitude, longitude, radius_meters, branch_id) 
      VALUES (:name, :type, :latitude, :longitude, :radius_meters, :branchId)
    `, { 
      replacements: { 
        name: location_name, 
        type: location_type || 'branch', 
        latitude, 
        longitude, 
        radius_meters, 
        branchId 
      }, 
      transaction 
    });

    await transaction.commit();
    res.status(201).json({ success: true, data: { id: branchId } });
  } catch (error) {
    await transaction.rollback();
    console.error("LỖI SQL KHI TẠO CHI NHÁNH:", error);
    res.status(500).json({ success: false, message: 'Lỗi lưu dữ liệu: ' + error.message });
  }
};

// ==========================================================
// 3. CẬP NHẬT (Update Branch -> Update/Insert Work Location)
// ==========================================================
const updateLocationSettings = async (req, res) => {
  const branchId = req.params.id || req.params.branch_id || req.params.branchId || req.params.locationId || req.body.id;
  
  if (!branchId) {
    return res.status(400).json({ success: false, message: "Thiếu ID chi nhánh để cập nhật!" });
  }

  const { location_name, location_type, address, latitude, longitude, radius_meters, allowed_ips, is_active } = req.body;
  const transaction = await db.transaction();

  try {
    // 1. XỬ LÝ IP: Nếu không gửi lên thì gán null, để COALESCE tự hiểu là giữ nguyên mảng cũ
    const ipPostgresFormat = allowed_ips !== undefined ? '{' + allowed_ips.join(',') + '}' : null;

    // 2. CẬP NHẬT BẢNG CHI NHÁNH (Dùng COALESCE để giữ giá trị cũ nếu param là null)
    await db.query(`
      UPDATE branch 
      SET branch_name = COALESCE(:name, branch_name), 
          address = COALESCE(:address, address), 
          allowed_ips = COALESCE(:ipString::text[], allowed_ips), 
          is_active = COALESCE(:is_active, is_active)
      WHERE id = :branchId
    `, {
      replacements: { 
        // Toán tử !== undefined giúp phân biệt: Có gửi lên (dù là "" hay false) thì lấy, không gửi thì ép bằng null
        name: location_name !== undefined ? location_name : null, 
        address: address !== undefined ? address : null, 
        ipString: ipPostgresFormat, 
        is_active: is_active !== undefined ? is_active : null, 
        branchId: branchId 
      }, 
      transaction
    });

    // 3. XỬ LÝ BẢNG TỌA ĐỘ (work_location)
    const [existingLoc] = await db.query(`SELECT id FROM work_location WHERE branch_id = :branchId LIMIT 1`, {
      replacements: { branchId: branchId }, type: db.QueryTypes.SELECT, transaction
    });

    if (existingLoc) {
      // Nếu ĐÃ CÓ tọa độ -> UPDATE (Cũng dùng COALESCE để giữ tọa độ cũ nếu người dùng không sửa)
      await db.query(`
        UPDATE work_location 
        SET location_name = COALESCE(:name, location_name), 
            location_type = COALESCE(:type, location_type), 
            latitude = COALESCE(:latitude, latitude), 
            longitude = COALESCE(:longitude, longitude), 
            radius_meters = COALESCE(:radius_meters, radius_meters) 
        WHERE branch_id = :branchId
      `, { 
        replacements: { 
          name: location_name !== undefined ? location_name : null, 
          type: location_type !== undefined ? location_type : null, 
          latitude: latitude !== undefined ? latitude : null, 
          longitude: longitude !== undefined ? longitude : null, 
          radius_meters: radius_meters !== undefined ? radius_meters : null, 
          branchId: branchId 
        }, transaction 
      });
    } else {
      // Nếu CHƯA CÓ tọa độ -> Bắt buộc phải tạo mới (INSERT)
      await db.query(`
        INSERT INTO work_location (location_name, location_type, latitude, longitude, radius_meters, branch_id) 
        VALUES (:name, :type, :latitude, :longitude, :radius_meters, :branchId)
      `, { 
        replacements: { 
          name: location_name || 'Chi nhánh mới', 
          type: location_type || 'branch', 
          latitude: latitude !== undefined ? latitude : null, 
          longitude: longitude !== undefined ? longitude : null, 
          radius_meters: radius_meters !== undefined ? radius_meters : null, 
          branchId: branchId 
        }, transaction 
      });
    }

    await transaction.commit();
    res.status(200).json({ success: true, message: "Cập nhật thành công, đã giữ lại các dữ liệu không thay đổi!" });

  } catch (error) {
    await transaction.rollback();
    console.error("LỖI SQL KHI CẬP NHẬT CHI NHÁNH:", error);
    res.status(500).json({ success: false, message: "Lỗi lưu dữ liệu: " + error.message });
  }
};
const deleteWorkLocation = async (req, res) => {
  const branchId = req.params.id || req.params.branch_id;

  if (!branchId) {
    return res.status(400).json({ success: false, message: "Thiếu ID chi nhánh!" });
  }

  try {
    // Chỉ xóa record trong bảng work_location, không đụng chạm đến bảng branch
    await db.query(`DELETE FROM work_location WHERE branch_id = :branchId`, {
      replacements: { branchId }
    });

    res.status(200).json({ success: true, message: "Đã xóa cấu hình định vị của chi nhánh này!" });
  } catch (error) {
    console.error("LỖI SQL KHI XÓA TỌA ĐỘ:", error);
    res.status(500).json({ success: false, message: "Lỗi khi xóa dữ liệu: " + error.message });
  }
};

module.exports = { getLocations, createLocation, updateLocationSettings, deleteWorkLocation };