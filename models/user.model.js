const db = require('../config/db');
const bcryptjs = require('bcryptjs');

const SALT_ROUNDS = 12;

async function createUser({ username, email, password }) {
  const hashed = await bcryptjs.hash(password, SALT_ROUNDS);
  const result = await db.query(
    `INSERT INTO users (username, email, password_hash)
     VALUES (?, ?, ?)`,
    [username, email, hashed]
  );
  const [user] = await db.query(
    `SELECT id, username, email FROM users WHERE email = ?`,
    [email]
  );
  return user;
}

async function findUserByEmail(email) {
  const result = await db.query(
    `SELECT * FROM users WHERE email = ?`,
    [email]
  );
  return result.length > 0 ? result[0] : null;
}

async function findUserByUsername(username) {
  const result = await db.query(
    `SELECT * FROM users WHERE username = ?`,
    [username]
  );
  return result.length > 0 ? result[0] : null;
}

async function validatePassword(user, inputPassword) {
  return bcryptjs.compare(inputPassword, user.password_hash);
}

module.exports = {
  createUser,
  findUserByEmail,
  findUserByUsername,
  validatePassword,
};
