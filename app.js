require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const authRoutes = require('./routes/auth.routes');
const listRoutes = require('./routes/list.routes');
const stripeRoutes = require('./routes/stripe.routes');
const paymentRoutes = require('./routes/payment.routes');
const stripeController = require('./controllers/stripe.controller');

const app = express();

// ✅ Middleware
app.use(cors());
app.use(helmet());
app.use(morgan('dev'));

// ✅ Stripe webhook: must use raw body BEFORE express.json
app.post('/api/webhook', express.raw({ type: 'application/json' }), stripeController.handleWebhook);

// ✅ Standard JSON parsing for all other routes
app.use(express.json());

// ✅ Routes
app.use('/api/auth', authRoutes);
app.use('/api/lists', listRoutes);
app.use('/api', stripeRoutes); // mounts /api/create-checkout-session
app.use('/api', paymentRoutes);

// ✅ Root route
app.get('/', (req, res) => {
  res.send('CheckAndSync.com API is running.');
});

// ✅ Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

module.exports = app;
