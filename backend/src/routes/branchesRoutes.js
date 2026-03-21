const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { QueryTypes } = require('sequelize');

router.get('/', async (req, res) => {
  try {
    const branches = await db.query(
      `
      SELECT id, branch_name 
      FROM branch
      WHERE is_active = true
      ORDER BY branch_name;
      `,
      { type: QueryTypes.SELECT }
    );

    res.json(branches);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi lấy chi nhánh' });
  }
});

module.exports = router;