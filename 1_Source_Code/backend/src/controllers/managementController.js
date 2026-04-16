
const db = require('../config/database'); 
const bcrypt = require('bcrypt');
const { sendAccountEmail } = require('../services/emailService');

const getEmployees = async (req, res) => {
  try {

    const query = `
      SELECT 
        e.id, 
        e.employee_code AS code, 
        e.full_name AS name, 
        e.work_email AS email, 
        p.position_name AS position, 
        d.department_name AS department, 
        e.status 
      FROM employee e
      LEFT JOIN position p ON e.position_id = p.id
      LEFT JOIN department d ON p.department_id = d.id
      ORDER BY e.created_at DESC;
    `;

    // 2. Thá»±c thi query báº±ng Sequelize
    const employees = await db.query(query, {
      type: db.QueryTypes.SELECT
    });

    // 3. Format láº¡i data cho chuáº©n vá»›i Frontend cáº§n
    const formattedData = employees.map(emp => {
      let statusText = 'KhÃ´ng xÃ¡c Ä‘á»‹nh';
      if (emp.status === 'active') statusText = 'Äang lÃ m viá»‡c';
      else if (emp.status === 'on_leave') statusText = 'Nghá»‰ phÃ©p/Thai sáº£n';
      else if (emp.status === 'inactive') statusText = 'ÄÃ£ nghá»‰ viá»‡c';

      return {
        id: emp.id,
        code: emp.code || 'ChÆ°a cáº­p nháº­t',
        name: emp.name,
        email: emp.email || 'ChÆ°a cáº­p nháº­t',
        position: emp.position || 'ChÆ°a phÃ¢n bá»•',
        department: emp.department || 'ChÆ°a phÃ¢n bá»•',
        status: emp.status,
        statusText: statusText
      };
    });

    // 4. Tráº£ káº¿t quáº£ vá» cho Frontend
    res.status(200).json(formattedData);

  } catch (error) {
    console.error('Lá»—i API getEmployees:', error);
    res.status(500).json({ success: false, message: 'Lá»—i Server khi láº¥y danh sÃ¡ch nhÃ¢n viÃªn' });
  }
};

const getEmployeeById = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Query JOIN 4 báº£ng: employee, position, department, user_account
    const query = `
      SELECT 
        e.*, 
        e.address AS current_address,
        p.position_name AS position_title, 
        d.department_name AS department_title,
        u.username,
        u.role_code,
        u.last_login
      FROM employee e
      LEFT JOIN position p ON e.position_id = p.id
      LEFT JOIN department d ON p.department_id = d.id
      LEFT JOIN user_account u ON u.employee_id = e.id
      WHERE e.id = :id
    `;

    const result = await db.query(query, {
      replacements: { id: id },
      type: db.QueryTypes.SELECT
    });

    if (result.length === 0) {
      return res.status(404).json({ success: false, message: 'KhÃ´ng tÃ¬m tháº¥y nhÃ¢n viÃªn' });
    }

    // Format láº¡i tráº¡ng thÃ¡i
    const emp = result[0];
    let statusText = 'KhÃ´ng xÃ¡c Ä‘á»‹nh';
    if (emp.status === 'active') statusText = 'Äang lÃ m viá»‡c';
    else if (emp.status === 'on_leave') statusText = 'Nghá»‰ phÃ©p/Thai sáº£n';
    else if (emp.status === 'inactive') statusText = 'ÄÃ£ nghá»‰ viá»‡c';
    
    emp.statusText = statusText;

    res.status(200).json(emp);

  } catch (error) {
    console.error('Lá»—i API getEmployeeById:', error);
    res.status(500).json({ success: false, message: 'Lá»—i Server' });
  }
};

const updateEmployee = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Láº¥y FULL dá»¯ liá»‡u tá»« form Frontend gá»­i lÃªn (LÆ°u Ã½: FE Ä‘ang gá»­i lÃªn lÃ  current_address)
    const { 
      full_name, phone_number, personal_email, current_address, 
      identity_card_number, date_of_birth, gender, 
      bank_account_number, bank_name, status,
      work_email, position_id, department_id, join_date, direct_manager_id
    } = req.body;

    // CÃ¢u lá»‡nh Update SQL (Sá»­ dá»¥ng Ä‘Ãºng cá»™t address cá»§a DB)
    const updateQuery = `
      UPDATE employee
      SET full_name = :full_name,
          phone_number = :phone_number,
          personal_email = :personal_email,
          address = :address, 
          identity_card_number = :identity_card_number,
          date_of_birth = :date_of_birth,
          gender = :gender,
          bank_account_number = :bank_account_number,
          bank_name = :bank_name,
          status = :status,
          work_email = :work_email,
          position_id = :position_id,
          join_date = :join_date,
          direct_manager_id = :direct_manager_id,
          updated_at = NOW()
      WHERE id = :id
    `;

    await db.query(updateQuery, {
      replacements: { 
        id: id, 
        full_name: full_name || null, 
        phone_number: phone_number || null, 
        personal_email: personal_email || null, 
        
        // ðŸ‘‰ CHá»ˆNH Láº I CHá»– NÃ€Y: GÃ¡n giÃ¡ trá»‹ tá»« current_address (FE) vÃ o cá»™t address (DB)
        address: current_address || null,  
        
        identity_card_number: identity_card_number || null, 
        date_of_birth: date_of_birth || null, 
        gender: (gender !== undefined && gender !== '') ? gender : null, 
        bank_account_number: bank_account_number || null, 
        bank_name: bank_name || null, 
        status: status || 'active',
        work_email: work_email || null,
        position_id: position_id || null, 
        join_date: join_date || null,
        direct_manager_id: direct_manager_id || null
      },
      type: db.QueryTypes.UPDATE
    });

    res.status(200).json({ success: true, message: 'Cáº­p nháº­t há»“ sÆ¡ thÃ nh cÃ´ng!' });

  } catch (error) {
    console.error('Lá»—i API updateEmployee:', error);
    res.status(500).json({ success: false, message: 'Lá»—i Server khi cáº­p nháº­t' });
  }
};
// API láº¥y danh sÃ¡ch PhÃ²ng ban, Chá»©c vá»¥ vÃ  Quáº£n lÃ½ Ä‘á»ƒ Ä‘Æ°a vÃ o Combobox
const getFormOptions = async (req, res) => {
  try {
    // 1. Láº¥y danh sÃ¡ch PhÃ²ng ban
    const departments = await db.query(
      "SELECT id, department_name FROM department ORDER BY department_name", 
      { type: db.QueryTypes.SELECT }
    );

    // 2. Láº¥y danh sÃ¡ch Chá»©c vá»¥
    const positions = await db.query(
      "SELECT id, position_name, department_id FROM position ORDER BY position_name", 
      { type: db.QueryTypes.SELECT }
    );

    // 3. Láº¥y danh sÃ¡ch NhÃ¢n viÃªn (JOIN position Ä‘á»ƒ biáº¿t há» thuá»™c PhÃ²ng ban nÃ o)
    const managers = await db.query(
      `SELECT e.id, e.full_name, p.department_id 
       FROM employee e
       LEFT JOIN position p ON e.position_id = p.id
       WHERE e.status = 'active' 
       ORDER BY e.full_name`, 
      { type: db.QueryTypes.SELECT }
    );

    res.status(200).json({ departments, positions, managers });
  } catch (error) {
    console.error('Lá»—i API getFormOptions:', error);
    res.status(500).json({ success: false, message: 'Lá»—i Server khi táº£i dá»¯ liá»‡u form' });
  }
};
const createEmployee = async (req, res) => {
  const t = await db.transaction();

  try {
    const { 
      full_name, phone_number, personal_email, address, 
      identity_card_number, date_of_birth, gender, 
      bank_account_number, bank_name, status,
      work_email, position_id, join_date, direct_manager_id, // ðŸ‘‰ ÄÃ£ xÃ³a department_id á»Ÿ Ä‘Ã¢y
      username, password, send_email 
    } = req.body;

    const randomSuffix = Math.floor(1000 + Math.random() * 9000);
    const employee_code = `NV-${new Date().getFullYear()}-${randomSuffix}`;

    // ðŸ‘‰ ÄÃ£ xÃ³a hoÃ n toÃ n department_id khá»i cÃ¢u Query
    const insertEmpQuery = `
      INSERT INTO employee (
        employee_code, full_name, phone_number, personal_email, address, 
        identity_card_number, date_of_birth, gender, bank_account_number, bank_name, 
        status, work_email, position_id, join_date, direct_manager_id
      ) VALUES (
        :employee_code, :full_name, :phone_number, :personal_email, :address, 
        :identity_card_number, :date_of_birth, :gender, :bank_account_number, :bank_name, 
        :status, :work_email, :position_id, :join_date, :direct_manager_id
      ) RETURNING id;
    `;

    const empResult = await db.query(insertEmpQuery, {
      replacements: {
        employee_code, full_name, 
        phone_number: phone_number || null, 
        personal_email: personal_email || null, 
        address: address || null,
        identity_card_number: identity_card_number || null, 
        date_of_birth: date_of_birth || null, 
        gender: (gender !== undefined && gender !== '') ? gender : null, 
        bank_account_number: bank_account_number || null, 
        bank_name: bank_name || null, 
        status: status || 'active',
        work_email: work_email || null,
        position_id: position_id || null, 
  
        join_date: join_date || null,
        direct_manager_id: direct_manager_id || null
      },
      type: db.QueryTypes.INSERT,
      transaction: t
    });

    const newEmployeeId = empResult[0][0].id;

    const saltRounds = 10;
    const password_hash = await bcrypt.hash(password, saltRounds);

    const insertUserQuery = `
      INSERT INTO user_account (
        employee_id, username, password_hash, role_code, require_pass_change
      ) VALUES (
        :employee_id, :username, :password_hash, 'employee', true
      )
    `;

    await db.query(insertUserQuery, {
      replacements: {
        employee_id: newEmployeeId,
        username: username,
        password_hash: password_hash
      },
      type: db.QueryTypes.INSERT,
      transaction: t
    });

    // ==========================================
    // 4. Má»ŒI THá»¨ THÃ€NH CÃ”NG -> GHI VÃ€O DATABASE
    // ==========================================
    await t.commit();

    // ==========================================
    // 5. SAU KHI GHI XONG Má»šI Báº®T Äáº¦U Gá»¬I EMAIL
    // ==========================================
if (send_email === true || send_email === 'true') {
      try {
        const targetEmail = personal_email || work_email || username; // Dá»± phÃ²ng trÆ°á»ng há»£p user khÃ´ng nháº­p email cÃ¡ nhÃ¢n

        await sendAccountEmail(
          targetEmail, 
          full_name, 
          username, 
          password
        );
        
        console.log(`ÄÃ£ gá»­i email cáº¥p tÃ i khoáº£n tá»›i: ${targetEmail}`);
        
        return res.status(201).json({ success: true, message: 'ThÃªm nhÃ¢n viÃªn vÃ  gá»­i email cáº¥p tÃ i khoáº£n thÃ nh cÃ´ng!' });
      } catch (emailError) {
        console.error('Lá»—i gá»­i email:', emailError);
        // Tráº£ vá» 201 vÃ¬ DB Ä‘Ã£ ghi thÃ nh cÃ´ng, chá»‰ bÃ¡o lá»—i pháº§n mail
        return res.status(201).json({ 
          success: true, 
          message: 'ÄÃ£ thÃªm nhÃ¢n viÃªn thÃ nh cÃ´ng, nhÆ°ng cáº¥u hÃ¬nh gá»­i Email Ä‘ang bá»‹ lá»—i. Vui lÃ²ng cáº¥p láº¡i pass sau.' 
        });
      }
    }

    // Náº¿u khÃ´ng tick Ã´ gá»­i mail
    return res.status(201).json({ success: true, message: 'ThÃªm nhÃ¢n viÃªn vÃ  cáº¥p tÃ i khoáº£n thÃ nh cÃ´ng!' });

  } catch (error) {
    // Chá»‰ Rollback khi lá»—i CÆ  Sá»ž Dá»® LIá»†U
    try {
        await t.rollback();
    } catch (rbError) {
        console.error('Lá»—i rollback:', rbError);
    }
    
    console.error('Lá»—i API createEmployee:', error);
    if (error.original && error.original.code === '23505') {
      return res.status(400).json({ success: false, message: 'Email/Username nÃ y Ä‘Ã£ tá»“n táº¡i trong há»‡ thá»‘ng!' });
    }
    res.status(500).json({ success: false, message: 'Lá»—i Server khi thÃªm nhÃ¢n viÃªn' });
  }
};
const deleteEmployee = async (req, res) => {
  const t = await db.transaction();

  try {
    const { id } = req.params;

    const emp = await db.query('SELECT id FROM employee WHERE id = :id', {
      replacements: { id },
      type: db.QueryTypes.SELECT,
      transaction: t
    });

    if (emp.length === 0) {
      await t.rollback();
      return res.status(404).json({ success: false, message: 'KhÃ´ng tÃ¬m tháº¥y nhÃ¢n viÃªn' });
    }

    // Bá» tham chiáº¿u tá»›i nhÃ¢n viÃªn (trÃ¡nh RESTRICT khi xÃ³a)
    await db.query('UPDATE department SET manager_id = NULL WHERE manager_id = :id', {
      replacements: { id },
      transaction: t
    });
    await db.query('UPDATE employee SET direct_manager_id = NULL WHERE direct_manager_id = :id', {
      replacements: { id },
      transaction: t
    });
    await db.query('UPDATE leave_request SET approver_id = NULL WHERE approver_id = :id', {
      replacements: { id },
      transaction: t
    });

    // CÃ¡c báº£ng FK tá»›i employee thÆ°á»ng lÃ  ON DELETE RESTRICT â€” xÃ³a trÆ°á»›c khi xÃ³a employee
    await db.query('DELETE FROM attendance WHERE employee_id = :id', {
      replacements: { id },
      transaction: t
    });
    await db.query('DELETE FROM hr_decision WHERE employee_id = :id', {
      replacements: { id },
      transaction: t
    });
    await db.query('DELETE FROM leave_request WHERE employee_id = :id', {
      replacements: { id },
      transaction: t
    });
    await db.query('DELETE FROM overtime_request WHERE employee_id = :id', {
      replacements: { id },
      transaction: t
    });
    await db.query('DELETE FROM contract WHERE employee_id = :id', {
      replacements: { id },
      transaction: t
    });
    await db.query('DELETE FROM payroll WHERE employee_id = :id', {
      replacements: { id },
      transaction: t
    });

    await db.query('DELETE FROM user_account WHERE employee_id = :id', {
      replacements: { id },
      transaction: t
    });

    await db.query('DELETE FROM employee WHERE id = :id', {
      replacements: { id },
      transaction: t
    });

    await t.commit();
    res.status(200).json({ success: true, message: 'XÃ³a nhÃ¢n viÃªn thÃ nh cÃ´ng' });
  } catch (error) {
    await t.rollback();
    console.error('Lá»—i API deleteEmployee:', error);
    const pgCode = error.original?.code || error.parent?.code;
    const msg = String(error.original?.message || error.message || '');
    if (pgCode === '23503' || msg.includes('foreign key') || msg.includes('violates foreign key')) {
      return res.status(409).json({
        success: false,
        message:
          'KhÃ´ng thá»ƒ xÃ³a nhÃ¢n viÃªn vÃ¬ váº«n cÃ²n dá»¯ liá»‡u liÃªn quan trong há»‡ thá»‘ng. Vui lÃ²ng thá»­ láº¡i hoáº·c liÃªn há»‡ quáº£n trá»‹.'
      });
    }
    res.status(500).json({ success: false, message: 'Lá»—i Server khi xÃ³a nhÃ¢n viÃªn' });
  }
};

const getPresentEmployees = async (req, res) => {
  try {
const query = `
      SELECT 
        e.full_name, 
        e.phone_number, 
        a.check_in_time, 
        a.check_in_latitude, 
        a.check_in_longitude, 
        wl.location_name
      FROM employee e
      JOIN attendance a ON e.id = a.employee_id
      LEFT JOIN work_location wl ON a.work_location_id = wl.id
      WHERE a.attendance_date = CURRENT_DATE
    `;

    const employees = await db.query(query, {
      type: db.QueryTypes.SELECT
    });

    res.status(200).json(employees);
  } catch (error) {
    console.error('Lá»—i API getPresentEmployees:', error);
    res.status(500).json({ success: false, message: 'Lá»—i Server khi táº£i dá»¯ liá»‡u hiá»‡n diá»‡n' });
  }
};

const getAbsentEmployees = async (req, res) => {
  try {
    // LÆ°u Ã½: Äá»•i tÃªn báº£ng 'leave_request' vÃ  'attendance' cho khá»›p vá»›i database
const query = `
      SELECT 
        e.full_name, 
        e.phone_number, 
        lr.status AS leave_status
      FROM employee e
      LEFT JOIN leave_request lr 
        ON e.id = lr.employee_id 
        AND CURRENT_DATE >= DATE(lr.start_datetime) 
        AND CURRENT_DATE <= DATE(lr.end_datetime)
      WHERE e.status = 'active' 
        AND e.id NOT IN (
          SELECT employee_id 
          FROM attendance
          WHERE attendance_date = CURRENT_DATE
        )
    `;

    const employees = await db.query(query, {
      type: db.QueryTypes.SELECT
    });

    res.status(200).json(employees);
  } catch (error) {
    console.error('Lá»—i API getAbsentEmployees:', error);
    res.status(500).json({ success: false, message: 'Lá»—i Server khi táº£i dá»¯ liá»‡u váº¯ng máº·t' });
  }
};
const getChangesSummary = async (req, res) => {
  try {
    const { month } = req.query; // yyyy-MM

    const query = `
      SELECT
  (SELECT COUNT(*) 
   FROM employee 
   WHERE join_date <= TO_DATE(:month, 'YYYY-MM')
     AND (status = 'active' OR TO_CHAR(updated_at, 'YYYY-MM') > :month)
  ) AS total,

  (SELECT COUNT(*) 
   FROM employee 
   WHERE TO_CHAR(join_date, 'YYYY-MM') = :month
  ) AS new_employees,

  (SELECT COUNT(*) 
   FROM employee 
   WHERE status = 'inactive'
     AND TO_CHAR(updated_at, 'YYYY-MM') = :month
  ) AS leave_employees
    `;

    const result = await db.query(query, {
      replacements: { month },
      type: db.QueryTypes.SELECT
    });

    res.status(200).json(result[0]);

  } catch (error) {
    console.error('Lá»—i getChangesSummary:', error);
    res.status(500).json({ message: 'Lá»—i server' });
  }
};
const getChangesList = async (req, res) => {
  try {
    const { month } = req.query;

    const query = `
      SELECT 
        e.id AS employee_id,
        e.full_name,
        d.department_name,
        'Gia nháº­p' AS type,
        e.join_date AS date
      FROM employee e
      LEFT JOIN position p ON e.position_id = p.id
      LEFT JOIN department d ON p.department_id = d.id
      WHERE TO_CHAR(e.join_date, 'YYYY-MM') = :month

      UNION ALL

      SELECT 
        e.id AS employee_id,
        e.full_name,
        d.department_name,
        'Nghá»‰ viá»‡c' AS type,
        e.updated_at AS date
      FROM employee e
      LEFT JOIN position p ON e.position_id = p.id
      LEFT JOIN department d ON p.department_id = d.id
      WHERE e.status = 'inactive'
        AND TO_CHAR(e.updated_at, 'YYYY-MM') = :month

      UNION ALL

      SELECT 
        e.id AS employee_id,
        e.full_name,
        d.department_name,
        'Nghá»‰ phÃ©p' AS type,
        lr.start_datetime AS date
      FROM leave_request lr
      JOIN employee e ON e.id = lr.employee_id
      LEFT JOIN position p ON e.position_id = p.id
      LEFT JOIN department d ON p.department_id = d.id
      WHERE lr.status = 'approved'
        AND TO_CHAR(lr.start_datetime, 'YYYY-MM') = :month

      ORDER BY date DESC;
    `;

    const result = await db.query(query, {
      replacements: { month },
      type: db.QueryTypes.SELECT
    });

    res.status(200).json(result);

  } catch (error) {
    console.error('Lá»—i getChangesList:', error);
    res.status(500).json({ message: 'Lá»—i server' });
  }
};
const getTenureStats = async (req, res) => {
  try {
    const query = `
      SELECT 
        CASE 
          WHEN AGE(CURRENT_DATE, join_date) < INTERVAL '1 year' THEN 'fresher'
          WHEN AGE(CURRENT_DATE, join_date) < INTERVAL '3 years' THEN 'junior'
          WHEN AGE(CURRENT_DATE, join_date) < INTERVAL '5 years' THEN 'mid'
          ELSE 'senior'
        END AS level,
        COUNT(*) as count
      FROM employee
      WHERE status = 'active' AND join_date IS NOT NULL
      GROUP BY level
    `;

    const result = await db.query(query, {
      type: db.QueryTypes.SELECT
    });

    // ðŸ‘‰ format láº¡i cho frontend dá»… dÃ¹ng
    const data = {
      fresher: 0,
      junior: 0,
      mid: 0,
      senior: 0
    };

    let total = 0;

    result.forEach(item => {
      data[item.level] = Number(item.count);
      total += Number(item.count);
    });

    // ðŸ‘‰ convert sang %
    const percentData = {
      fresher: total ? Math.round((data.fresher / total) * 100) : 0,
      junior: total ? Math.round((data.junior / total) * 100) : 0,
      mid: total ? Math.round((data.mid / total) * 100) : 0,
      senior: total ? Math.round((data.senior / total) * 100) : 0
    };

    res.status(200).json(percentData);

  } catch (error) {
    console.error('Lá»—i getTenureStats:', error);
    res.status(500).json({ message: 'Lá»—i server' });
  }
};
//phÃª duyá»‡t
const getApprovalRequests = async (req, res) => {
  try {
    const { id } = req.params;

    // ðŸ”µ LEAVE REQUEST
    const leaveQuery = `
      SELECT 
    lr.id,
    lr.employee_id,
    e.full_name AS employee_name,
    approver.full_name AS approver_name,

    p.position_name,
    d.department_name,

    'leave' AS type,
    lr.leave_type,
    lr.start_datetime,
    lr.end_datetime,
    lr.reason,
    lr.status,
    lr.created_at

  FROM leave_request lr
  JOIN employee e ON lr.employee_id = e.id
  LEFT JOIN employee approver ON lr.approver_id = approver.id

  LEFT JOIN position p ON e.position_id = p.id
  LEFT JOIN department d ON p.department_id = d.id

  WHERE lr.approver_id = :id
  AND lr.status = 'pending'
    `;

    // ðŸŸ  OVERTIME REQUEST
    const otQuery = `
      SELECT 
    ot.id,
    ot.employee_id,
    e.full_name AS employee_name,
    approver.full_name AS approver_name,

    p.position_name,
    d.department_name,

    'overtime' AS type,
    NULL AS leave_type,
    ot.ot_date AS start_datetime,
    ot.ot_date AS end_datetime,
    ot.reason,
    ot.status,
    ot.created_at,
    ot.start_time,
    ot.end_time

  FROM overtime_request ot
  JOIN employee e ON ot.employee_id = e.id
  LEFT JOIN employee approver ON ot.approver_id = approver.id

  LEFT JOIN position p ON e.position_id = p.id
  LEFT JOIN department d ON p.department_id = d.id

  WHERE ot.approver_id = :id
  AND ot.status = 'pending'
    `;

    const [leaveRows] = await db.query(leaveQuery, {
      replacements: { id }
    });

    const [otRows] = await db.query(otQuery, {
      replacements: { id }
    });

    // ðŸ”¥ Gá»™p láº¡i
    const combined = [...leaveRows, ...otRows].sort(
      (a, b) => new Date(b.created_at) - new Date(a.created_at)
    );

    res.json(combined);

  } catch (error) {
    console.error("âŒ getApprovalRequests error:", error);
    res.status(500).json({ message: "Lá»—i server" });
  }
};

const updateApprovalStatus = async (req, res) => {
  try {
    const { type, id } = req.params;
    const { status } = req.body; // approved | rejected

    if (!['approved', 'rejected'].includes(status)) {
      return res.status(400).json({ message: 'Tráº¡ng thÃ¡i khÃ´ng há»£p lá»‡' });
    }

    let query = '';

    // ðŸŸ¢ ÄÆ¡n nghá»‰ phÃ©p
    if (type === 'leave') {
      query = `
        UPDATE leave_request
        SET status = :status,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = :id
        RETURNING *;
      `;
    }

    // ðŸŸ  ÄÆ¡n tÄƒng ca
    else if (type === 'overtime') {
      query = `
        UPDATE overtime_request
        SET status = :status,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = :id
        RETURNING *;
      `;
    }

    else {
      return res.status(400).json({ message: 'Type khÃ´ng há»£p lá»‡' });
    }

    const [result] = await db.query(query, {
      replacements: { id, status }
    });

    res.json({
      message: 'Cáº­p nháº­t thÃ nh cÃ´ng',
      data: result[0]
    });

  } catch (error) {
    console.error("âŒ updateApprovalStatus:", error);
    res.status(500).json({ message: "Lá»—i server" });
  }
};
const getApprovalHistory = async (req, res) => {
  try {
    const { id } = req.params;

    const query = `
      SELECT * FROM (
      SELECT 
        lr.id,
        lr.employee_id,
        e.full_name AS employee_name,
        'leave' AS type,
        lr.status,
        lr.updated_at   
      FROM leave_request lr
      JOIN employee e ON lr.employee_id = e.id
      WHERE lr.approver_id = :id
      AND lr.status = 'approved'

      UNION ALL

      SELECT 
        ot.id,
        ot.employee_id,
        e.full_name AS employee_name,
        'overtime' AS type,
        ot.status,
        ot.updated_at   
      FROM overtime_request ot
      JOIN employee e ON ot.employee_id = e.id
      WHERE ot.approver_id = :id
      AND ot.status = 'approved'
    ) t
    ORDER BY updated_at DESC
    `;

    const [rows] = await db.query(query, {
      replacements: { id }
    });

    res.json(rows);

  } catch (error) {
    console.error("âŒ getApprovalHistory:", error);
    res.status(500).json({ message: error.message });
  }
};

const getAttendanceStats = async (req, res) => {
  try {
    let monthParam = req.query.month ? String(req.query.month) : '';
    if (monthParam && !/^\d{4}-\d{2}$/.test(String(monthParam))) {
      return res.status(400).json({ message: 'Tham sá»‘ month (YYYY-MM) khÃ´ng há»£p lá»‡' });
    }

    if (!monthParam) {
      const latestMonthRow = await db.query(
        `
        SELECT TO_CHAR(MAX(attendance_date), 'YYYY-MM') AS latest_month
        FROM attendance
        `,
        { type: db.QueryTypes.SELECT }
      );

      monthParam = latestMonthRow[0]?.latest_month || new Date().toISOString().slice(0, 7);
    }

    const [y, m] = monthParam.split('-').map((n) => parseInt(n, 10));
    const curStart = new Date(Date.UTC(y, m - 1, 1));
    const curEnd = new Date(Date.UTC(y, m, 1));
    const prevStart = new Date(Date.UTC(y, m - 2, 1));
    const prevEnd = curStart;

    const curStartStr = curStart.toISOString().slice(0, 10);
    const curEndStr = curEnd.toISOString().slice(0, 10);
    const prevStartStr = prevStart.toISOString().slice(0, 10);
    const prevEndStr = prevEnd.toISOString().slice(0, 10);

    const attendanceAgg = await db.query(
      `
      SELECT
        COALESCE(SUM(CASE WHEN a.attendance_date >= :cur_start AND a.attendance_date < :cur_end
          THEN COALESCE(a.total_work_hours, 0) ELSE 0 END), 0)::float AS work_hours_cur,
        COALESCE(SUM(CASE WHEN a.attendance_date >= :prev_start AND a.attendance_date < :prev_end
          THEN COALESCE(a.total_work_hours, 0) ELSE 0 END), 0)::float AS work_hours_prev,
        COALESCE(SUM(CASE WHEN a.attendance_date >= :cur_start AND a.attendance_date < :cur_end
            AND a.status IN ('late', 'early_leave') THEN 1 ELSE 0 END), 0)::int AS late_early_cur,
        COALESCE(SUM(CASE WHEN a.attendance_date >= :prev_start AND a.attendance_date < :prev_end
            AND a.status IN ('late', 'early_leave') THEN 1 ELSE 0 END), 0)::int AS late_early_prev
      FROM attendance a
      JOIN employee e ON e.id = a.employee_id AND e.status = 'active'
      `,
      {
        replacements: {
          cur_start: curStartStr,
          cur_end: curEndStr,
          prev_start: prevStartStr,
          prev_end: prevEndStr,
        },
        type: db.QueryTypes.SELECT,
      }
    );

    const leaveRows = await db.query(
      `
      SELECT
        COALESCE(SUM(
          GREATEST(0,
            (LEAST(DATE(lr.end_datetime), (:cur_end::date - INTERVAL '1 day')::date)
             - GREATEST(DATE(lr.start_datetime), :cur_start::date) + 1)
          )
        ), 0)::int AS leave_days_cur
      FROM leave_request lr
      WHERE lr.status = 'approved'
        AND lr.start_datetime < :cur_end
        AND lr.end_datetime > :cur_start
      `,
      {
        replacements: { cur_start: curStartStr, cur_end: curEndStr },
        type: db.QueryTypes.SELECT,
      }
    );

    const leaveRowsPrev = await db.query(
      `
      SELECT
        COALESCE(SUM(
          GREATEST(0,
            (LEAST(DATE(lr.end_datetime), (:prev_end::date - INTERVAL '1 day')::date)
             - GREATEST(DATE(lr.start_datetime), :prev_start::date) + 1)
          )
        ), 0)::int AS leave_days_prev
      FROM leave_request lr
      WHERE lr.status = 'approved'
        AND lr.start_datetime < :prev_end
        AND lr.end_datetime > :prev_start
      `,
      {
        replacements: { prev_start: prevStartStr, prev_end: prevEndStr },
        type: db.QueryTypes.SELECT,
      }
    );

    const otAgg = await db.query(
      `
      SELECT
        COALESCE(SUM(EXTRACT(EPOCH FROM (o.end_time - o.start_time)) / 3600.0), 0)::float AS ot_cur
      FROM overtime_request o
      WHERE o.status = 'approved'
        AND o.ot_date >= :cur_start AND o.ot_date < :cur_end
      `,
      {
        replacements: { cur_start: curStartStr, cur_end: curEndStr },
        type: db.QueryTypes.SELECT,
      }
    );

    const otAggPrev = await db.query(
      `
      SELECT
        COALESCE(SUM(EXTRACT(EPOCH FROM (o.end_time - o.start_time)) / 3600.0), 0)::float AS ot_prev
      FROM overtime_request o
      WHERE o.status = 'approved'
        AND o.ot_date >= :prev_start AND o.ot_date < :prev_end
      `,
      {
        replacements: { prev_start: prevStartStr, prev_end: prevEndStr },
        type: db.QueryTypes.SELECT,
      }
    );

    const tolRow = await db.query(
      `SELECT COALESCE((SELECT config_value::int FROM system_config WHERE config_key = 'DEFAULT_LATE_TOLERANCE'), 15) AS tol`,
      { type: db.QueryTypes.SELECT }
    );
    const tolMin = tolRow[0]?.tol ?? 15;

    const deptRows = await db.query(
      `
      SELECT
        d.id AS department_id,
        d.department_name,
        COUNT(*) FILTER (WHERE a.status IN ('late', 'early_leave'))::int AS incident_count
      FROM department d
      JOIN "position" p ON p.department_id = d.id
      JOIN employee e ON e.position_id = p.id AND e.status = 'active'
      LEFT JOIN attendance a ON a.employee_id = e.id
        AND a.attendance_date >= :cur_start AND a.attendance_date < :cur_end
      GROUP BY d.id, d.department_name
      HAVING COUNT(*) FILTER (WHERE a.status IN ('late', 'early_leave')) > 0
      ORDER BY incident_count DESC
      `,
      {
        replacements: { cur_start: curStartStr, cur_end: curEndStr },
        type: db.QueryTypes.SELECT,
      }
    );

    const totalDeptIncidents = deptRows.reduce((s, r) => s + Number(r.incident_count || 0), 0);
    const barColors = ['red', 'orange', 'blue', 'emerald', 'violet'];
    const departmentChart = deptRows.map((row, idx) => ({
      department: row.department_name,
      count: Number(row.incident_count),
      percentage:
        totalDeptIncidents > 0
          ? Math.round((Number(row.incident_count) / totalDeptIncidents) * 1000) / 10
          : 0,
      color: barColors[idx % barColors.length],
    }));

    const attentionRows = await db.query(
      `
      SELECT
        e.id,
        e.employee_code,
        e.full_name,
        e.avatar_url,
        d.id AS department_id,
        d.department_name,
        COALESCE(SUM(CASE WHEN a.status = 'late' THEN 1 ELSE 0 END), 0)::int AS late_count,
        COALESCE(SUM(
          CASE
            WHEN a.status = 'late' AND a.check_in_time IS NOT NULL THEN
              CASE
                WHEN (a.check_in_time AT TIME ZONE 'Asia/Ho_Chi_Minh')::time
                  BETWEEN TIME '07:30' AND TIME '11:30'
                THEN GREATEST(0,
                  EXTRACT(EPOCH FROM (
                    (a.check_in_time AT TIME ZONE 'Asia/Ho_Chi_Minh')::time
                    - (TIME '07:30' + (interval '1 minute' * :tol_min))
                  )) / 60.0
                )
                WHEN (a.check_in_time AT TIME ZONE 'Asia/Ho_Chi_Minh')::time
                  BETWEEN TIME '13:00' AND TIME '17:00'
                THEN GREATEST(0,
                  EXTRACT(EPOCH FROM (
                    (a.check_in_time AT TIME ZONE 'Asia/Ho_Chi_Minh')::time
                    - (TIME '13:00' + (interval '1 minute' * :tol_min))
                  )) / 60.0
                )
                ELSE 0
              END
            ELSE 0
          END
        ), 0)::float AS total_late_minutes
      FROM employee e
      JOIN "position" p ON e.position_id = p.id
      JOIN department d ON p.department_id = d.id
      LEFT JOIN attendance a ON a.employee_id = e.id
        AND a.attendance_date >= :cur_start AND a.attendance_date < :cur_end
      WHERE e.status = 'active'
      GROUP BY e.id, e.employee_code, e.full_name, e.avatar_url, d.id, d.department_name
      HAVING COALESCE(SUM(CASE WHEN a.status = 'late' THEN 1 ELSE 0 END), 0) > 0
      ORDER BY late_count DESC, total_late_minutes DESC
      LIMIT 50
      `,
      {
        replacements: { cur_start: curStartStr, cur_end: curEndStr, tol_min: tolMin },
        type: db.QueryTypes.SELECT,
      }
    );

    const attentionEmployees = attentionRows.map((row) => {
      const lateCount = Number(row.late_count);
      const totalLateMinutes = Math.round(Number(row.total_late_minutes));
      const actionType = lateCount >= 7 || totalLateMinutes >= 180 ? 'warning' : 'remind';
      return {
        id: row.id,
        employeeCode: row.employee_code,
        name: row.full_name,
        avatarUrl: row.avatar_url,
        departmentId: row.department_id,
        dept: row.department_name,
        lateCount,
        totalLateMinutes,
        actionType,
      };
    });

    const pct = (cur, prev) => {
      const c = Number(cur);
      const p = Number(prev);
      if (p === 0) return c > 0 ? 100 : 0;
      return Math.round(((c - p) / p) * 1000) / 10;
    };

    const att = attendanceAgg[0] || {};
    const leaveCur = leaveRows[0]?.leave_days_cur ?? 0;
    const leavePrev = leaveRowsPrev[0]?.leave_days_prev ?? 0;
    const otCur = otAgg[0]?.ot_cur ?? 0;
    const otPrev = otAggPrev[0]?.ot_prev ?? 0;

    res.status(200).json({
      month: monthParam,
      summary: {
        totalWorkHours: {
          value: Math.round(Number(att.work_hours_cur || 0) * 10) / 10,
          changePct: pct(att.work_hours_cur, att.work_hours_prev),
          label: 'Tá»•ng giá» cÃ´ng thá»±c táº¿',
          unit: 'giá»',
        },
        lateEarly: {
          value: Number(att.late_early_cur || 0),
          changePct: pct(att.late_early_cur, att.late_early_prev),
          label: 'Äi trá»… / Vá» sá»›m',
          unit: 'lÆ°á»£t',
          tone: Number(att.late_early_cur || 0) > Number(att.late_early_prev || 0) ? 'alarming' : 'neutral',
        },
        leaveAbsence: {
          value: Number(leaveCur),
          changePct: pct(leaveCur, leavePrev),
          label: 'Nghá»‰ phÃ©p / Váº¯ng máº·t',
          unit: 'ngÃ y',
          tone: leaveCur <= leavePrev ? 'stable' : 'neutral',
        },
        overtime: {
          value: Math.round(Number(otCur) * 10) / 10,
          changePct: pct(otCur, otPrev),
          label: 'LÃ m thÃªm giá» (OT)',
          unit: 'giá»',
        },
      },
      departmentLateness: departmentChart,
      attentionEmployees,
    });
  } catch (error) {
    console.error('Lá»—i getAttendanceStats:', error);
    res.status(500).json({ message: 'Lá»—i server khi táº£i thá»‘ng kÃª cháº¥m cÃ´ng' });
  }
};
module.exports = {
  getEmployees,
  getEmployeeById,
  updateEmployee,
  getFormOptions ,
  createEmployee,
  deleteEmployee,
  getPresentEmployees,
  getAbsentEmployees,
  getChangesSummary,
  getChangesList,
  getTenureStats,
  getApprovalRequests,
  updateApprovalStatus,
  getApprovalHistory,
  getAttendanceStats,
};




