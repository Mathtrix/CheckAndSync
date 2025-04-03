import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static Future<void> createCheckoutSession() async {
    final url = Uri.parse('https://check-and-sync.onrender.com/api/create-checkout-session');
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to create checkout session: ${response.body}');
    }

    final data = json.decode(response.body);
    final checkoutUrl = data['url']; // or 'id' if your server returns the session URL directly

    final uri = Uri.parse(checkoutUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch Stripe checkout');
    }
  }
}
