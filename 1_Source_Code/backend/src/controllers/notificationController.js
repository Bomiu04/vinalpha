const sequelize = require('../config/database');
const { QueryTypes } = require('sequelize');
const axios = require('axios');

/** Ãƒâ€žÃ‚ÂÃƒÂ¡Ã‚Â»Ã¢â‚¬Å“ng bÃƒÂ¡Ã‚Â»Ã¢â€žÂ¢ vÃƒÂ¡Ã‚Â»Ã¢â‚¬Âºi .data: mÃƒÂ¡Ã‚ÂºÃ‚Â·c Ãƒâ€žÃ¢â‚¬ËœÃƒÂ¡Ã‚Â»Ã¢â‚¬Â¹nh UI lÃƒÆ’Ã‚Â  'ToÃƒÆ’Ã‚Â n cÃƒÆ’Ã‚Â´ng ty'; DB cÃƒâ€¦Ã‚Â© cÃƒÆ’Ã‚Â³ thÃƒÂ¡Ã‚Â»Ã†â€™ cÃƒÆ’Ã‚Â²n 'TÃƒÂ¡Ã‚ÂºÃ‚Â¥t cÃƒÂ¡Ã‚ÂºÃ‚Â£ nhÃƒÆ’Ã‚Â¢n viÃƒÆ’Ã‚Âªn'. */
function isCompanyWideTarget(target) {
  return getTargetScope(target) === 'company';
}

const TARGET_COMPANY = '\u0054o\u00e0n c\u00f4ng ty';
const TARGET_COMPANY_LEGACY = '\u0054\u1ea5t c\u1ea3 nh\u00e2n vi\u00ean';
const TARGET_DEPARTMENT = 'Ph\u00f2ng ban';
const TARGET_EMPLOYEE = 'C\u00e1 nh\u00e2n';
const STATUS_DRAFT = 'Nh\u00e1p';
const STATUS_SENT = '\u0110\u00e3 g\u1eedi';
const STATUS_EDITED = '\u0110\u00e3 ch\u1ec9nh s\u1eeda';

function normalizeText(value) {
  return String(value || '').normalize('NFC').trim().toLowerCase();
}

function getTargetScope(target) {
  const normalized = normalizeText(target);
  if (!normalized || normalized === normalizeText(TARGET_COMPANY) || normalized === normalizeText(TARGET_COMPANY_LEGACY)) {
    return 'company';
  }
  if (normalized === normalizeText(TARGET_DEPARTMENT)) return 'department';
  if (normalized === normalizeText(TARGET_EMPLOYEE)) return 'employee';
  return 'company';
}

function getPersistedTarget(target) {
  const scope = getTargetScope(target);
  if (scope === 'department') return TARGET_DEPARTMENT;
  if (scope === 'employee') return TARGET_EMPLOYEE;
  return TARGET_COMPANY;
}
async function sendExpoPushIfPossible(notificationId, title, desc) {
  try {
    const fetchTokensQuery = `
      SELECT u.expo_push_token
      FROM user_account u
      JOIN notification_recipient nr ON nr.employee_id = u.employee_id
      WHERE nr.notification_id = :notiId AND u.expo_push_token IS NOT NULL
    `;

    const tokens = await sequelize.query(fetchTokensQuery, {
      replacements: { notiId: notificationId },
      type: QueryTypes.SELECT,
    });

    if (!tokens || tokens.length === 0) return;

    const pushMessages = tokens.map((t) => ({
      to: t.expo_push_token,
      title: title || 'ThÃƒÂ´ng bÃƒÂ¡o mÃ¡Â»â€ºi',
      body: desc || 'BÃ¡ÂºÂ¡n cÃƒÂ³ mÃ¡Â»â„¢t thÃƒÂ´ng bÃƒÂ¡o mÃ¡Â»â€ºi tÃ¡Â»Â« cÃƒÂ´ng ty.',
      sound: 'default',
    }));

    await axios.post('https://exp.host/--/api/v2/push/send', pushMessages, {
      headers: {
        Accept: 'application/json',
        'Accept-encoding': 'gzip, deflate',
        'Content-Type': 'application/json',
      },
    });
  } catch (err) {
    if (err?.original?.code === '42703' || String(err?.message || '').includes('expo_push_token')) {
      console.warn('Skip Expo push: user_account.expo_push_token chÃ†Â°a tÃ¡Â»â€œn tÃ¡ÂºÂ¡i trong schema hiÃ¡Â»â€¡n tÃ¡ÂºÂ¡i.');
      return;
    }
    console.error('Expo Push Error:', err?.response?.data || err?.message || err);
  }
}
const notificationController = {
  // --- Admin: danh sÃƒÆ’Ã‚Â¡ch ---
  getAllNotifications: async (req, res) => {
    try {
      const notifications = await sequelize.query(
        `SELECT * FROM notification ORDER BY created_at DESC`,
        { type: QueryTypes.SELECT }
      );
      res.json(notifications);
    } catch (err) {
      console.error('ÃƒÂ°Ã…Â¸Ã¢â‚¬ÂÃ‚Â¥ LÃƒÂ¡Ã‚Â»Ã¢â‚¬â€i lÃƒÂ¡Ã‚ÂºÃ‚Â¥y thÃƒÆ’Ã‚Â´ng bÃƒÆ’Ã‚Â¡o:', err);
      res.status(500).json({ message: 'LÃƒÂ¡Ã‚Â»Ã¢â‚¬â€i lÃƒÂ¡Ã‚ÂºÃ‚Â¥y danh sÃƒÆ’Ã‚Â¡ch thÃƒÆ’Ã‚Â´ng bÃƒÆ’Ã‚Â¡o' });
    }
  },

  // --- Admin: tÃƒÂ¡Ã‚ÂºÃ‚Â¡o mÃƒÂ¡Ã‚Â»Ã¢â‚¬Âºi (nhÃƒÆ’Ã‚Â¡p / gÃƒÂ¡Ã‚Â»Ã‚Â­i + recipient) ---
  createNotification: async (req, res) => {
    const t = await sequelize.transaction();
    try {
      const {
        title,
        content,
        notification_type,
        target,
        department_id,
        employee_id,
        desc,
        sender_id,
        status,
      } = req.body;

      const finalStatus = status === STATUS_DRAFT ? STATUS_DRAFT : STATUS_SENT;

      if (!title || !String(title).trim()) {
        await t.rollback();
        return res.status(400).json({ message: 'ThiÃƒÂ¡Ã‚ÂºÃ‚Â¿u tiÃƒÆ’Ã‚Âªu Ãƒâ€žÃ¢â‚¬ËœÃƒÂ¡Ã‚Â»Ã‚Â thÃƒÆ’Ã‚Â´ng bÃƒÆ’Ã‚Â¡o' });
      }

      const targDept = department_id
        ? parseInt(String(department_id), 10)
        : null;
      let safeDeptId =
        Number.isFinite(targDept) && targDept > 0 ? targDept : null;
      let safeEmpId = employee_id || null;
      const tgtNorm = getPersistedTarget(target);
      if (getTargetScope(tgtNorm) === 'company') {
        safeDeptId = null;
        safeEmpId = null;
      } else if (getTargetScope(tgtNorm) === 'department') {
        safeEmpId = null;
      }

      const [newNotiRows] = await sequelize.query(
        `INSERT INTO notification (title, content, notification_type, target, "desc", status, sender_id, target_department_id, target_employee_id, created_at) 
         VALUES (:title, :content, :type, :target, :desc, :notiStatus, :sender, :tdept, :temp, NOW()) RETURNING id`,
        {
          replacements: {
            title,
            content,
            type: notification_type || 'info',
            target: tgtNorm,
            desc: desc || '',
            notiStatus: finalStatus,
            sender: sender_id || null,
            tdept: safeDeptId,
            temp: safeEmpId,
          },
          transaction: t,
        }
      );

      const notificationId = newNotiRows?.[0]?.id;
      if (!notificationId) {
        throw new Error('KhÃƒÆ’Ã‚Â´ng lÃƒÂ¡Ã‚ÂºÃ‚Â¥y Ãƒâ€žÃ¢â‚¬ËœÃƒâ€ Ã‚Â°ÃƒÂ¡Ã‚Â»Ã‚Â£c ID thÃƒÆ’Ã‚Â´ng bÃƒÆ’Ã‚Â¡o vÃƒÂ¡Ã‚Â»Ã‚Â«a tÃƒÂ¡Ã‚ÂºÃ‚Â¡o.');
      }

      if (finalStatus !== STATUS_DRAFT) {
        if (isCompanyWideTarget(tgtNorm)) {
          await sequelize.query(
            `INSERT INTO notification_recipient (notification_id, employee_id)
             SELECT :notiId, id FROM employee WHERE status = 'active'`,
            { replacements: { notiId: notificationId }, transaction: t }
          );
        } else if (getTargetScope(tgtNorm) === 'department' && safeDeptId) {
          await sequelize.query(
            `INSERT INTO notification_recipient (notification_id, employee_id)
             SELECT :notiId, e.id FROM employee e 
             JOIN "position" p ON e.position_id = p.id 
             WHERE p.department_id = :deptId AND e.status = 'active'`,
            {
              replacements: { notiId: notificationId, deptId: safeDeptId },
              transaction: t,
            }
          );
        } else if (getTargetScope(tgtNorm) === 'employee' && safeEmpId) {
          await sequelize.query(
            `INSERT INTO notification_recipient (notification_id, employee_id) VALUES (:notiId, :empId)`,
            {
              replacements: { notiId: notificationId, empId: safeEmpId },
              transaction: t,
            }
          );
        }
      }

      await t.commit();

      // === FIRE PUSH NOTIFICATION (BACKGROUND) ===
      if (finalStatus !== 'Nh\u00e1p') {
        sendExpoPushIfPossible(notificationId, title, desc);
      }


      res.status(201).json({ message: 'Gui thong bao thanh cong', id: notificationId });
    } catch (err) {
      await t.rollback();
      console.error('ÃƒÂ°Ã…Â¸Ã¢â‚¬ÂÃ‚Â¥ LÃƒÂ¡Ã‚Â»Ã¢â‚¬â€i tÃƒÂ¡Ã‚ÂºÃ‚Â¡o thÃƒÆ’Ã‚Â´ng bÃƒÆ’Ã‚Â¡o:', err);
      res
        .status(500)
        .json({ message: 'LÃƒÂ¡Ã‚Â»Ã¢â‚¬â€i hÃƒÂ¡Ã‚Â»Ã¢â‚¬Â¡ thÃƒÂ¡Ã‚Â»Ã¢â‚¬Ëœng khi lÃƒâ€ Ã‚Â°u dÃƒÂ¡Ã‚Â»Ã‚Â¯ liÃƒÂ¡Ã‚Â»Ã¢â‚¬Â¡u', error: err.message });
    }
  },

  // --- Admin: cÃƒÂ¡Ã‚ÂºÃ‚Â­p nhÃƒÂ¡Ã‚ÂºÃ‚Â­t ---
  updateNotification: async (req, res) => {
    const t = await sequelize.transaction();
    try {
      const { id } = req.params;
      const {
        title,
        content,
        notification_type,
        target,
        department_id,
        employee_id,
        desc,
        sender_id,
        status,
      } = req.body;

      if (!title || !String(title).trim()) {
        await t.rollback();
        return res.status(400).json({ message: 'ThiÃƒÂ¡Ã‚ÂºÃ‚Â¿u tiÃƒÆ’Ã‚Âªu Ãƒâ€žÃ¢â‚¬ËœÃƒÂ¡Ã‚Â»Ã‚Â thÃƒÆ’Ã‚Â´ng bÃƒÆ’Ã‚Â¡o' });
      }

      const resolvedStatus =
        status === STATUS_DRAFT ? STATUS_DRAFT : status || STATUS_EDITED;

      const uDept = department_id
        ? parseInt(String(department_id), 10)
        : null;
      let uSafeDept =
        Number.isFinite(uDept) && uDept > 0 ? uDept : null;
      let u_safeEmp = employee_id || null;
      const uTgt = getPersistedTarget(target);
      if (isCompanyWideTarget(uTgt)) {
        uSafeDept = null;
        u_safeEmp = null;
      } else if (getTargetScope(uTgt) === 'department') {
        u_safeEmp = null;
      }

      await sequelize.query(
        `UPDATE notification
         SET title = :title,
             content = :content,
             notification_type = :type,
             target = :target,
             "desc" = :desc,
             status = :status,
             sender_id = :sender,
             target_department_id = :tdept,
             target_employee_id = :temp
         WHERE id = :id`,
        {
          replacements: {
            id,
            title,
            content,
            type: notification_type || 'info',
            target: tgtNorm,
            desc: desc || '',
            status: resolvedStatus,
            sender: sender_id || null,
            tdept: uSafeDept,
            temp: u_safeEmp,
          },
          transaction: t,
        }
      );

      await sequelize.query(
        `DELETE FROM notification_recipient WHERE notification_id = :id`,
        { replacements: { id }, transaction: t }
      );

      if (resolvedStatus !== STATUS_DRAFT) {
        if (isCompanyWideTarget(uTgt)) {
          await sequelize.query(
            `INSERT INTO notification_recipient (notification_id, employee_id)
            SELECT :notiId, id FROM employee WHERE status = 'active'`,
            { replacements: { notiId: id }, transaction: t }
          );
        } else if (getTargetScope(uTgt) === 'department' && uSafeDept) {
          await sequelize.query(
            `INSERT INTO notification_recipient (notification_id, employee_id)
             SELECT :notiId, e.id
             FROM employee e
             JOIN "position" p ON e.position_id = p.id
             WHERE p.department_id = :deptId
               AND e.status = 'active'`,
            { replacements: { notiId: id, deptId: uSafeDept }, transaction: t }
          );
        } else if (getTargetScope(uTgt) === 'employee' && u_safeEmp) {
          await sequelize.query(
            `INSERT INTO notification_recipient (notification_id, employee_id)
             VALUES (:notiId, :empId)`,
            { replacements: { notiId: id, empId: u_safeEmp }, transaction: t }
          );
        }
      }

      await t.commit();
      res.json({ message: 'CÃƒÂ¡Ã‚ÂºÃ‚Â­p nhÃƒÂ¡Ã‚ÂºÃ‚Â­t thÃƒÆ’Ã‚Â´ng bÃƒÆ’Ã‚Â¡o thÃƒÆ’Ã‚Â nh cÃƒÆ’Ã‚Â´ng' });
    } catch (err) {
      await t.rollback();
      console.error('ÃƒÂ°Ã…Â¸Ã¢â‚¬ÂÃ‚Â¥ LÃƒÂ¡Ã‚Â»Ã¢â‚¬â€i cÃƒÂ¡Ã‚ÂºÃ‚Â­p nhÃƒÂ¡Ã‚ÂºÃ‚Â­t thÃƒÆ’Ã‚Â´ng bÃƒÆ’Ã‚Â¡o:', err);
      res
        .status(500)
        .json({ message: 'LÃƒÂ¡Ã‚Â»Ã¢â‚¬â€i hÃƒÂ¡Ã‚Â»Ã¢â‚¬Â¡ thÃƒÂ¡Ã‚Â»Ã¢â‚¬Ëœng khi cÃƒÂ¡Ã‚ÂºÃ‚Â­p nhÃƒÂ¡Ã‚ÂºÃ‚Â­t', error: err.message });
    }
  },

  // --- Admin: chi tiÃƒÂ¡Ã‚ÂºÃ‚Â¿t ---
  getNotificationById: async (req, res) => {
    try {
      const [notification] = await sequelize.query(
        `SELECT * FROM notification WHERE id = :id`,
        { replacements: { id: req.params.id }, type: QueryTypes.SELECT }
      );
      if (!notification)
        return res.status(404).json({ message: 'KhÃƒÆ’Ã‚Â´ng tÃƒÆ’Ã‚Â¬m thÃƒÂ¡Ã‚ÂºÃ‚Â¥y thÃƒÆ’Ã‚Â´ng bÃƒÆ’Ã‚Â¡o' });
      res.json(notification);
    } catch (err) {
      res.status(500).json({ message: 'LÃƒÂ¡Ã‚Â»Ã¢â‚¬â€i server' });
    }
  },

  // --- Admin: chi tiÃƒÂ¡Ã‚ÂºÃ‚Â¿t Ãƒâ€žÃ¢â‚¬ËœÃƒÂ¡Ã‚ÂºÃ‚Â§y Ãƒâ€žÃ¢â‚¬ËœÃƒÂ¡Ã‚Â»Ã‚Â§ (ngÃƒâ€ Ã‚Â°ÃƒÂ¡Ã‚Â»Ã‚Âi gÃƒÂ¡Ã‚Â»Ã‚Â­i tÃƒÂ¡Ã‚Â»Ã‚Â« employee, ngÃƒâ€ Ã‚Â°ÃƒÂ¡Ã‚Â»Ã‚Âi nhÃƒÂ¡Ã‚ÂºÃ‚Â­n tÃƒÂ¡Ã‚Â»Ã‚Â« notification_recipient) ---
  getNotificationAdminDetail: async (req, res) => {
    try {
      const { id } = req.params;
      const rows = await sequelize.query(
        `SELECT n.*,
          s.full_name AS sender_full_name,
          s.employee_code AS sender_employee_code,
          s.avatar_url AS sender_avatar_url,
          s.work_email AS sender_work_email,
          te.full_name AS target_emp_full_name,
          te.employee_code AS target_emp_code,
          td.id AS target_dept_row_id,
          td.department_name AS target_dept_name
        FROM notification n
        LEFT JOIN employee s ON n.sender_id = s.id
        LEFT JOIN employee te ON n.target_employee_id = te.id
        LEFT JOIN department td ON n.target_department_id = td.id
        WHERE n.id = :id`,
        { replacements: { id }, type: QueryTypes.SELECT }
      );
      const row = rows[0];
      if (!row)
        return res.status(404).json({ message: 'KhÃƒÆ’Ã‚Â´ng tÃƒÆ’Ã‚Â¬m thÃƒÂ¡Ã‚ÂºÃ‚Â¥y thÃƒÆ’Ã‚Â´ng bÃƒÆ’Ã‚Â¡o' });

      const countRows = await sequelize.query(
        `SELECT COUNT(*)::int AS total FROM notification_recipient WHERE notification_id = :id`,
        { replacements: { id }, type: QueryTypes.SELECT }
      );
      const recipient_count = countRows[0]?.total ?? 0;

      const RECIPIENT_LIMIT = 200;
      const recipients = await sequelize.query(
        `SELECT e.full_name, e.employee_code, d.department_name, d.id AS department_id
        FROM notification_recipient nr
        JOIN employee e ON nr.employee_id = e.id
        LEFT JOIN position p ON e.position_id = p.id
        LEFT JOIN department d ON p.department_id = d.id
        WHERE nr.notification_id = :id
        ORDER BY e.full_name
        LIMIT :lim`,
        {
          replacements: { id, lim: RECIPIENT_LIMIT },
          type: QueryTypes.SELECT,
        }
      );

      const deptRows = await sequelize.query(
        `SELECT DISTINCT d.id, d.department_name
        FROM notification_recipient nr
        JOIN employee e ON nr.employee_id = e.id
        JOIN position p ON e.position_id = p.id
        JOIN department d ON p.department_id = d.id
        WHERE nr.notification_id = :id AND d.department_name IS NOT NULL
        ORDER BY d.department_name`,
        { replacements: { id }, type: QueryTypes.SELECT }
      );
      const department_names = deptRows.map((d) => d.department_name);

      const {
        sender_full_name,
        sender_employee_code,
        sender_avatar_url,
        sender_work_email,
        target_emp_full_name,
        target_emp_code,
        target_dept_row_id,
        target_dept_name,
        ...notification
      } = row;

      const sender = sender_full_name
        ? {
            full_name: sender_full_name,
            employee_code: sender_employee_code,
            avatar_url: sender_avatar_url,
            work_email: sender_work_email,
          }
        : null;

      const target_scope = {
        employee: target_emp_full_name
          ? {
              full_name: target_emp_full_name,
              employee_code: target_emp_code,
            }
          : null,
        department:
          target_dept_name != null
            ? {
                id: target_dept_row_id,
                department_name: target_dept_name,
              }
            : null,
      };

      let department_names_out = department_names;
      if (
        department_names_out.length === 0 &&
        target_scope.department?.department_name
      ) {
        department_names_out = [target_scope.department.department_name];
      }

      res.json({
        notification,
        sender,
        target_scope,
        recipients,
        recipient_count,
        recipients_truncated: recipient_count > recipients.length,
        department_names: department_names_out,
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: 'LÃƒÂ¡Ã‚Â»Ã¢â‚¬â€i lÃƒÂ¡Ã‚ÂºÃ‚Â¥y chi tiÃƒÂ¡Ã‚ÂºÃ‚Â¿t thÃƒÆ’Ã‚Â´ng bÃƒÆ’Ã‚Â¡o' });
    }
  },

  // --- Admin: xÃƒÆ’Ã‚Â³a ---
  deleteNotification: async (req, res) => {
    const t = await sequelize.transaction();
    try {
      const { id } = req.params;
      await sequelize.query(
        `DELETE FROM notification_recipient WHERE notification_id = :id`,
        { replacements: { id }, transaction: t }
      );
      await sequelize.query(`DELETE FROM notification WHERE id = :id`, {
        replacements: { id },
        transaction: t,
      });
      await t.commit();
      res.json({ message: 'Ãƒâ€žÃ‚ÂÃƒÆ’Ã‚Â£ xoÃƒÆ’Ã‚Â¡ thÃƒÆ’Ã‚Â´ng bÃƒÆ’Ã‚Â¡o' });
    } catch (err) {
      await t.rollback();
      res.status(500).json({ message: 'LÃƒÂ¡Ã‚Â»Ã¢â‚¬â€i khi xoÃƒÆ’Ã‚Â¡' });
    }
  },

  // --- NhÃƒÆ’Ã‚Â¢n viÃƒÆ’Ã‚Âªn: chuÃƒÆ’Ã‚Â´ng ---
  getMyBellNotifications: async (req, res) => {
    try {
      const { userId } = req.params;
      const query = `
        SELECT n.id, n.title, n."desc", n.content, n.target, n.status, n.notification_type, n.created_at, nr.is_read
        FROM notification n
        JOIN notification_recipient nr ON n.id = nr.notification_id
        WHERE nr.employee_id = :userId
        ORDER BY n.created_at DESC
      `;
      const [results] = await sequelize.query(query, {
        replacements: { userId },
      });
      res.status(200).json(results);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'LÃƒÂ¡Ã‚Â»Ã¢â‚¬â€i lÃƒÂ¡Ã‚ÂºÃ‚Â¥y chuÃƒÆ’Ã‚Â´ng thÃƒÆ’Ã‚Â´ng bÃƒÆ’Ã‚Â¡o' });
    }
  },

  markAsRead: async (req, res) => {
    try {
      const { notiId } = req.params;
      const { userId } = req.body;
      const query = `
        UPDATE notification_recipient 
        SET is_read = true, read_at = NOW() 
        WHERE notification_id = :notiId AND employee_id = :userId
      `;
      await sequelize.query(query, {
        replacements: { notiId, userId },
      });
      res.status(200).json({ message: 'Ãƒâ€žÃ‚ÂÃƒÆ’Ã‚Â£ cÃƒÂ¡Ã‚ÂºÃ‚Â­p nhÃƒÂ¡Ã‚ÂºÃ‚Â­t trÃƒÂ¡Ã‚ÂºÃ‚Â¡ng thÃƒÆ’Ã‚Â¡i Ãƒâ€žÃ¢â‚¬ËœÃƒÂ¡Ã‚Â»Ã‚Âc thÃƒÆ’Ã‚Â nh cÃƒÆ’Ã‚Â´ng' });
    } catch (error) {
      console.error('=== LÃƒÂ¡Ã‚Â»Ã¢â‚¬â€œI UPDATE Ãƒâ€žÃ‚ÂÃƒÆ’Ã†â€™ Ãƒâ€žÃ‚ÂÃƒÂ¡Ã‚Â»Ã…â€™C ===', error);
      res.status(500).json({ message: 'LÃƒÂ¡Ã‚Â»Ã¢â‚¬â€i cÃƒÂ¡Ã‚ÂºÃ‚Â­p nhÃƒÂ¡Ã‚ÂºÃ‚Â­t', error: error.message });
    }
  },

  markAllAsRead: async (req, res) => {
    try {
      const { userId } = req.params;
      await sequelize.query(
        `
        UPDATE notification_recipient SET is_read = true, read_at = NOW() WHERE employee_id = :userId AND is_read = false
      `,
        { replacements: { userId } }
      );
      res.status(200).json({ message: 'Ãƒâ€žÃ‚ÂÃƒÆ’Ã‚Â£ Ãƒâ€žÃ¢â‚¬ËœÃƒÂ¡Ã‚Â»Ã‚Âc tÃƒÂ¡Ã‚ÂºÃ‚Â¥t cÃƒÂ¡Ã‚ÂºÃ‚Â£' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'LÃƒÂ¡Ã‚Â»Ã¢â‚¬â€i' });
    }
  },
};

module.exports = notificationController;




