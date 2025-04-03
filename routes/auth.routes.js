const express = require('express');
const router = express.Router();
const { register, login } = require('../controllers/auth.controller');
const db = require('../config/db');
const authenticate = require('../middleware/auth.middleware');

// Register a new user
router.post('/register', register);

// Login and return JWT token
router.post('/login', login);

// Check if the user is premium
router.get('/status', authenticate, async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT isPremium FROM users WHERE id = ?',
      [req.user.id]
    );

    if (rows.length > 0) {
      res.json({ isPremium: rows[0].isPremium });
    } else {
      res.status(404).json({ error: 'User not found' });
    }
  } catch (error) {
    console.error('Error fetching premium status:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
