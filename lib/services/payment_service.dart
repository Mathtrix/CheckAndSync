import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static Future<void> createCheckoutSession() async {
    debugPrint('Step 1: Starting checkout session creation...');
    
    try {
      final url = Uri.parse('https://check-and-sync.onrender.com/api/create-checkout-session');
      final response = await http.post(url);
      debugPrint('Step 2: Got response: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('Step 3: Error response body: ${response.body}');
        throw Exception('Failed to create checkout session: ${response.body}');
      }

      final data = json.decode(response.body);
      final checkoutUrl = data['url'];
      debugPrint('Step 4: Stripe Checkout URL: $checkoutUrl');

      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        debugPrint('Step 5: Launching Stripe URL...');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch Stripe checkout');
      }
    } catch (e) {
      debugPrint('❌ Exception in createCheckoutSession: $e');
      rethrow;
    }
  }
}
