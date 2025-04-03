const express = require('express');
const router = express.Router();
const stripeController = require('../controllers/stripe.controller');

// Stripe Checkout session creation (web-safe, uses express.json())
router.post('/create-checkout-session', stripeController.createCheckoutSession);

module.exports = router;
