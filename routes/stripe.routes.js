const express = require('express');
const router = express.Router();
const stripeController = require('../controllers/stripe.controller');

// Use express.json() globally (already done in app.js)
router.post('/create-checkout-session', stripeController.createCheckoutSession);

// Stripe webhook — use raw body parser here for signature verification
router.post(
  '/webhook',
  express.raw({ type: 'application/json' }),
  stripeController.handleWebhook
);

module.exports = router;