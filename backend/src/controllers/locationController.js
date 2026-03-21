const db = require('../config/database');

// 1. LẤY DANH SÁCH CHI NHÁNH
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
        w.location_type AS type, -- Lấy loại địa điểm
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
    res.status(500).json({ success: false, message: "Lỗi máy chủ nội bộ" });
  }
};

// 2. THÊM MỚI (Tách biệt rõ ràng 2 bảng)
const createLocation = async (req, res) => {
  const { location_name, location_type, address, latitude, longitude, radius_meters, allowed_ips, is_active } = req.body;
  const transaction = await db.transaction();

  try {
    // 1. Lưu vào bảng work_location (Chỉ chứa GPS & Type)
    const [newLoc] = await db.query(`
      INSERT INTO work_location (location_name, location_type, latitude, longitude, radius_meters) 
      VALUES (:name, :type, :latitude, :longitude, :radius_meters) RETURNING id
    `, { 
      replacements: { name: location_name, type: location_type || 'branch', latitude, longitude, radius_meters }, 
      transaction 
    });

    // 2. Lưu vào bảng branch (Chứa Hành chính, IP, Address)
    const branchCode = 'CN_' + Math.floor(Math.random() * 10000); 
    const [newBranch] = await db.query(`
      INSERT INTO branch (branch_code, branch_name, address, is_active, allowed_ips, work_location_id) 
      VALUES (:code, :name, :address, :is_active, ARRAY[:allowed_ips]::TEXT[], :workLocId) RETURNING id
    `, { 
      replacements: { 
        code: branchCode, name: location_name, address: address || 'Chưa cập nhật', 
        is_active, allowed_ips: allowed_ips || [], workLocId: newLoc[0].id 
      }, 
      transaction 
    });

    await transaction.commit();
    res.status(201).json({ success: true, data: { id: newBranch[0].id } });
  } catch (error) {
    await transaction.rollback();
    res.status(500).json({ success: false, message: 'Lỗi lưu dữ liệu' });
  }
};

// 3. CẬP NHẬT (Tách biệt rõ ràng 2 bảng)
const updateLocationSettings = async (req, res) => {
  const branchId = req.params.id;
  const { location_name, location_type, address, latitude, longitude, radius_meters, allowed_ips, is_active } = req.body;
  const transaction = await db.transaction();

  try {
    // 1. Tìm xem chi nhánh này đã từng có dữ liệu bản đồ (work_location_id) chưa?
    const [branch] = await db.query(`SELECT work_location_id FROM branch WHERE id = :branchId`, {
      replacements: { branchId }, type: db.QueryTypes.SELECT, transaction
    });

    if (!branch) throw new Error("Không tìm thấy chi nhánh");

    let workLocId = branch.work_location_id;

    // 2. XỬ LÝ BẢNG BẢN ĐỒ (work_location)
    if (workLocId) {
      // Nếu ĐÃ CÓ tọa độ trước đó -> Cập nhật (UPDATE)
      await db.query(`
        UPDATE work_location 
        SET location_name = :name, location_type = :type, latitude = :latitude, longitude = :longitude, radius_meters = :radius_meters 
        WHERE id = :workLocId
      `, { replacements: { name: location_name, type: location_type || 'branch', latitude, longitude, radius_meters, workLocId }, transaction });
    } else {
      // Nếu CHƯA CÓ tọa độ bao giờ -> Tạo mới (INSERT) và lấy ID
      const [newLoc] = await db.query(`
        INSERT INTO work_location (location_name, location_type, latitude, longitude, radius_meters) 
        VALUES (:name, :type, :latitude, :longitude, :radius_meters) RETURNING id
      `, { replacements: { name: location_name, type: location_type || 'branch', latitude, longitude, radius_meters }, transaction });
      workLocId = newLoc[0].id;
    }

    // 3. XỬ LÝ BẢNG CHI NHÁNH (branch) VÀ LƯU IP WIFI VÀO ĐÚNG BẢNG NÀY
    // Format mảng IP của JS thành chuỗi mảng của PostgreSQL (Ví dụ: "{192.168.1.1, 10.0.0.1}")
    // Cách này giúp DB không bao giờ bị lỗi sập (kể cả khi không có IP nào)
    const ipPostgresFormat = '{' + (allowed_ips || []).join(',') + '}';

    await db.query(`
      UPDATE branch 
      SET branch_name = :name, 
          address = :address, 
          allowed_ips = :ipString::text[], -- Ép kiểu chuẩn xác mảng Text của Postgres
          is_active = :is_active,
          work_location_id = :workLocId    -- Gắn nối ID bản đồ vào chi nhánh
      WHERE id = :branchId
    `, {
      replacements: { 
        name: location_name, 
        address: address || '', 
        ipString: ipPostgresFormat, 
        is_active, 
        workLocId,
        branchId 
      }, transaction
    });

    // Nếu mọi thứ trơn tru thì lưu vào DB
    await transaction.commit();
    res.status(200).json({ success: true, message: "Cập nhật thành công!" });

  } catch (error) {
    // Nếu có bất kỳ lỗi gì, hoàn tác (hủy) toàn bộ quá trình, không làm hỏng dữ liệu cũ
    await transaction.rollback();
    console.error("LỖI SQL KHI CẬP NHẬT CHI NHÁNH:", error); // In lỗi rõ ràng ra console Nodejs
    res.status(500).json({ success: false, message: "Lỗi lưu dữ liệu: " + error.message });
  }
};

module.exports = { getLocations, createLocation, updateLocationSettings };