const jwt = require('jsonwebtoken');
const {
  createUser,
  findUserByEmail,
  findUserByUsername,
  validatePassword,
} = require('../models/user.model');

const JWT_SECRET = process.env.JWT_SECRET;

async function register(req, res) {
  const { username, email, password } = req.body;

  if (!username || !email || !password)
    return res.status(400).json({ error: 'All fields are required.' });

  const existingUser = await findUserByUsername(username);
  const existingEmail = await findUserByEmail(email);

  if (existingUser) {
    return res.status(409).json({ error: 'Username already taken.' });
  }
  if (existingEmail) {
    return res.status(409).json({ error: 'Email already registered.' });
  }

  const user = await createUser({ username, email, password });

  res.status(201).json(user);
}

async function login(req, res) {
  const { email, password } = req.body;

  if (!email || !password)
    return res.status(400).json({ error: 'Email and password are required.' });

  const user = await findUserByEmail(email);
  if (!user) return res.status(401).json({ error: 'Invalid credentials.' });

  const isValid = await validatePassword(user, password);
  if (!isValid) return res.status(401).json({ error: 'Invalid credentials.' });

  const token = jwt.sign({ id: user.id }, JWT_SECRET, { expiresIn: '7d' });

  res.json({ token, user: { id: user.id, username: user.username, email: user.email } });
}

module.exports = {
  register,
  login,
};
