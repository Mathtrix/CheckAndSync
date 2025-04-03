const express = require('express');
const router = express.Router();
const { getLists, syncLists } = require('../controllers/list.controller');
const authenticate = require('../middleware/auth.middleware');

router.get('/', authenticate, getLists);
router.post('/sync', authenticate, syncLists);

module.exports = router;
