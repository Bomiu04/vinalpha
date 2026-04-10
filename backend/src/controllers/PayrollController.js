const db = require('../config/database');

const formatTime = (value) => {
    if (!value) return null;
    const date = new Date(value);
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return `${hours}:${minutes}`;
};

const formatHours = (value) => {
    if (!value || Number.isNaN(Number(value))) return '0.00';
    return Number(value).toFixed(2);
};

const calculatePayroll = async (req, res) => {
    const { monthYear, departmentId } = req.query;
    let tx;

    try {
        tx = await db.transaction();
        let empQuery = `
            SELECT e.id, e.employee_code, e.full_name, c.base_salary, d.department_name
            FROM employee e 
            JOIN contract c ON e.id = c.employee_id 
            JOIN position p ON e.position_id = p.id
            JOIN department d ON p.department_id = d.id
            WHERE c.is_active = true AND e.status = 'active'
        `;
        
        const replacements = {};
        if (departmentId) {
            empQuery += ` AND d.id = :deptId`;
            replacements.deptId = departmentId;
        }

        const employees = await db.query(empQuery, {
            replacements,
            type: db.QueryTypes.SELECT,
            transaction: tx
        });

        const results = [];
        for (const emp of employees) {
            const attendanceRows = await db.query(
                `SELECT
                    attendance_date,
                    check_in_time,
                    check_out_time,
                    status,
                    total_work_hours
                 FROM attendance
                 WHERE employee_id = :id
                   AND to_char(attendance_date, 'MM-YYYY') = :my`,
                {
                    replacements: { id: emp.id, my: monthYear },
                    type: db.QueryTypes.SELECT,
                    transaction: tx
                }
            );

            const decisions = await db.query(
                `SELECT decision_type, SUM(amount) as total FROM hr_decision 
                 WHERE employee_id = :id AND to_char(issue_date, 'MM-YYYY') = :my 
                 GROUP BY decision_type`,
                { replacements: { id: emp.id, my: monthYear }, type: db.QueryTypes.SELECT, transaction: tx }
            );

            const overtimeRows = await db.query(
                `SELECT
                    ot_date,
                    SUM(EXTRACT(EPOCH FROM (end_time - start_time))/3600) AS ot_hours
                 FROM overtime_request
                 WHERE employee_id = :id
                   AND to_char(ot_date, 'MM-YYYY') = :my
                   AND status = 'approved'
                 GROUP BY ot_date`,
                {
                    replacements: { id: emp.id, my: monthYear },
                    type: db.QueryTypes.SELECT,
                    transaction: tx
                }
            );

            let reward = 0, discipline = 0;
            decisions.forEach(d => {
                if (d.decision_type === 'reward') reward = parseFloat(d.total);
                if (d.decision_type === 'discipline') discipline = parseFloat(d.total);
            });

            const otHours = overtimeRows.reduce(
                (sum, row) => sum + parseFloat(row.ot_hours || 0),
                0
            );

            const attendanceByDay = new Map();
            attendanceRows.forEach((row) => {
                const day = String(new Date(row.attendance_date).getDate()).padStart(2, '0');
                attendanceByDay.set(day, row);
            });

            const overtimeByDay = new Map();
            overtimeRows.forEach((row) => {
                const day = String(new Date(row.ot_date).getDate()).padStart(2, '0');
                overtimeByDay.set(day, parseFloat(row.ot_hours || 0));
            });

            const [month, year] = monthYear.split('-');
            const now = new Date();
            const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

            const attendanceDetail = Array.from({ length: 26 }, (_, index) => {
                const day = String(index + 1).padStart(2, '0');
                const row = attendanceByDay.get(day);
                const dateOfDay = new Date(Number(year), Number(month) - 1, index + 1);
                const isFuture = dateOfDay > today;

                if (row) {
                    const workHours = parseFloat(row.total_work_hours || 0);
                    const workDays = Math.min(workHours / 8, 1);

                    return {
                        day,
                        checkIn: formatTime(row.check_in_time),
                        checkOut: formatTime(row.check_out_time),
                        hours: formatHours(workHours),
                        cong: Number.isFinite(workDays) ? Number(workDays.toFixed(2)) : 0,
                        ot: formatHours(overtimeByDay.get(day) || 0),
                        status: row.status || 'on_time'
                    };
                }

                return {
                    day,
                    checkIn: null,
                    checkOut: null,
                    hours: null,
                    cong: null,
                    ot: null,
                    status: isFuture ? 'future' : 'absent'
                };
            });

            const days = attendanceDetail.reduce((sum, row) => {
                if (typeof row.cong === 'number') return sum + row.cong;
                return sum;
            }, 0);

            // 1. THU NHẬP THÁNG = Lương cơ bản
            const base = parseFloat(emp.base_salary || 0);
            const overtimeMoney = otHours * (base / 22 / 8) * 1.5;
            const actualSalary = base;

            // 2. TÍNH BẢO HIỂM (Tính theo Lương CB / Thu Nhập Tháng)
            const compInsurance = {
                bhxh: base * 0.175,
                bhyt: base * 0.03,
                bhtn: base * 0.01,
                total: base * 0.215 // Tổng DN Đóng BH
            };
            const empInsurance = {
                bhxh: base * 0.08,
                bhyt: base * 0.015,
                bhtn: base * 0.01,
                total: base * 0.105 // Tổng NLĐ Đóng BH
            };

            // 3. THỰC NHẬN THÁNG = Lương cơ bản - BH NLĐ - Kỷ luật + Thưởng
            const incomeAfterIns = actualSalary - empInsurance.total - discipline + reward;

            // 4. CHI PHÍ TIỀN LƯƠNG = Thu Nhập Tháng + Tổng DN Đóng BH
            const companyCost = actualSalary + compInsurance.total;

            // Thực nhận dùng cùng logic với Thu nhập sau BH ở bảng tổng hợp
            const netSalary = incomeAfterIns;
            const totalAllowance = reward + overtimeMoney;
            const totalDeduction = empInsurance.total + discipline;

            const [payrollRow] = await db.query(
                `INSERT INTO payroll (
                    employee_id,
                    month_year,
                    base_salary_snapshot,
                    total_work_days,
                    total_allowance,
                    total_deduction,
                    net_salary,
                    status
                )
                VALUES (
                    :employeeId,
                    :monthYear,
                    :baseSalary,
                    :totalWorkDays,
                    :totalAllowance,
                    :totalDeduction,
                    :netSalary,
                    'draft'
                )
                ON CONFLICT (employee_id, month_year)
                DO UPDATE SET
                    base_salary_snapshot = EXCLUDED.base_salary_snapshot,
                    total_work_days = EXCLUDED.total_work_days,
                    total_allowance = EXCLUDED.total_allowance,
                    total_deduction = EXCLUDED.total_deduction,
                    net_salary = EXCLUDED.net_salary
                RETURNING id`,
                {
                    replacements: {
                        employeeId: emp.id,
                        monthYear,
                        baseSalary: base,
                        totalWorkDays: days,
                        totalAllowance,
                        totalDeduction,
                        netSalary
                    },
                    type: db.QueryTypes.SELECT,
                    transaction: tx
                }
            );

            await db.query(
                `UPDATE hr_decision
                 SET payroll_id = :payrollId
                 WHERE employee_id = :employeeId
                   AND to_char(issue_date, 'MM-YYYY') = :monthYear`,
                {
                    replacements: {
                        payrollId: payrollRow.id,
                        employeeId: emp.id,
                        monthYear
                    },
                    transaction: tx
                }
            );

            results.push({
                employee_code: emp.employee_code,
                full_name: emp.full_name,
                department_name: emp.department_name,
                base_salary: base, 
                actual_salary: actualSalary, 
                total_work_days: days,
                overtime: overtimeMoney,
                discipline: discipline,
                reward: reward,
                compInsurance,
                empInsurance,
                income_after_insurance: incomeAfterIns,
                company_cost: companyCost,
                net_salary: netSalary,
                attendance_detail: attendanceDetail
            });
        }
        await tx.commit();
        res.json({ success: true, data: results });
    } catch (error) { 
        if (tx) await tx.rollback();
        res.status(500).json({ success: false, error: error.message }); 
    }
};

module.exports = { calculatePayroll };