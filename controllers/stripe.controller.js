const Stripe = require('stripe');
const stripe = Stripe(process.env.STRIPE_SECRET_KEY);
const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;
const User = require('../models/user.model'); // Adjust path if necessary
const db = require('../config/db');

exports.createCheckoutSession = async (req, res) => {
  try {
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      mode: 'subscription',
      line_items: [
        {
          price: 'price_1R4bcvGVMTfRB3LAU1iw4AxO', // Replace with your actual Stripe Price ID
          quantity: 1,
        },
      ],
      success_url: 'https://example.com/success',
      cancel_url: 'https://example.com/cancel',
    });

    res.json({ url: session.url });
  } catch (error) {
    console.error('Error creating checkout session:', error);
    res.status(500).json({ error: error.message });
  }
};

const handleCheckoutSessionCompleted = async (session) => {
  const customerId = session.customer;

  try {
    const [result] = await db.query(
      'UPDATE users SET isPremium = TRUE WHERE stripeCustomerId = ?',
      [customerId]
    );

    if (result.affectedRows > 0) {
      console.log(`✅ Upgraded user with Stripe customer ID ${customerId} to premium`);
    } else {
      console.warn(`⚠️ No user found for Stripe customer ID ${customerId}`);
    }
  } catch (error) {
    console.error('❌ Error updating premium status:', error);
  }
};

exports.handleWebhook = async (req, res) => {
  const sig = req.headers['stripe-signature'];

  let event;
  try {
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
  } catch (err) {
    console.error('❌ Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  switch (event.type) {
    case 'checkout.session.completed':
      console.log('📬 Received checkout.session.completed');
      await handleCheckoutSessionCompleted(event.data.object);
      break;

    case 'customer.subscription.created':
      console.log('📬 Received customer.subscription.created');
      const subscription = event.data.object;
      console.log('📦 Subscription created:', subscription);
      break;

    default:
      console.log(`⚠️ Unhandled event type ${event.type}`);
  }

  res.json({ received: true });
};
