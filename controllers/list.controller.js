const db = require('../config/db');

// GET /api/lists
exports.getLists = async (req, res) => {
  const userId = req.user.id;

  try {
    const [lists] = await db.query('SELECT * FROM lists WHERE user_id = ?', [userId]);

    for (const list of lists) {
      const [entries] = await db.query('SELECT * FROM entries WHERE list_id = ?', [list.id]);
      list.entries = entries;
    }

    res.json({ success: true, lists });
  } catch (err) {
    console.error('Error fetching lists:', err);
    res.status(500).json({ success: false, error: 'Failed to load lists' });
  }
};

// POST /api/lists/sync
exports.syncLists = async (req, res) => {
  const userId = req.user.id;
  const lists = req.body.lists;

  if (!Array.isArray(lists)) {
    return res.status(400).json({ success: false, error: 'Invalid data format' });
  }

  const connection = await db.getConnection();
  await connection.beginTransaction();

  try {
    await connection.query('DELETE FROM entries WHERE list_id IN (SELECT id FROM lists WHERE user_id = ?)', [userId]);
    await connection.query('DELETE FROM lists WHERE user_id = ?', [userId]);

    for (const [position, list] of lists.entries()) {
      await connection.query(
        'INSERT INTO lists (id, user_id, title, position) VALUES (?, ?, ?, ?)',
        [list.id, userId, list.title, position]
      );

      for (const [entryIndex, entry] of list.entries.entries()) {
        await connection.query(
          'INSERT INTO entries (id, list_id, text, checked, position) VALUES (?, ?, ?, ?, ?)',
          [entry.id, list.id, entry.text, entry.checked ? 1 : 0, entryIndex]
        );
      }
    }

    await connection.commit();
    connection.release();

    res.json({ success: true });
  } catch (err) {
    await connection.rollback();
    connection.release();
    console.error('Error syncing lists:', err);
    res.status(500).json({ success: false, error: 'Sync failed' });
  }
};
