require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const authRoutes = require('./routes/auth.routes');
const listRoutes = require('./routes/list.routes');
const stripeRoutes = require('./routes/stripe.routes');
const paymentRoutes = require('./routes/payment.routes');

const app = express();

// ✅ Middleware
app.use(cors());
app.use(helmet());
app.use(morgan('dev'));
app.use(express.json()); // 👈 This enables parsing of JSON in req.body


// ✅ Routes
app.use('/api/auth', authRoutes);
app.use('/api/lists', listRoutes);
app.use('/api', stripeRoutes); // ✅ mounts the /api/create-checkout-session route
app.use('/api', paymentRoutes);

// ✅ Root route
app.get('/', (req, res) => {
  res.send('CheckAndSync.com API is running.');
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

module.exports = app;


