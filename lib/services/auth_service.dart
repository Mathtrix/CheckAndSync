import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthService {
  static const String baseUrl = 'https://checkandsync-backend.onrender.com/api/auth';
  static final _storage = FlutterSecureStorage();

  static Future<List<Map<String, dynamic>>?> fetchLists() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/lists'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['lists']);
    } else {
      print('❌ Fetch lists failed: ${response.body}');
      return null;
    }
  }

  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'user': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Registration failed'};
      }
    } catch (e) {
      print('❌ Register error: $e');
      return {'success': false, 'error': 'Network or server error'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await saveToken(data['token']);
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
        };
      } else {
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      print('❌ Login error: $e');
      return {'success': false, 'error': 'Network or server error'};
    }
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  static Future<void> logout(BuildContext context) async {
    await clearToken();
    context.go('/login');
  }

  static Future<bool> syncLists(List<Map<String, dynamic>> lists) async {
    try {
      final token = await getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/lists/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'lists': lists}),
      );

      if (response.statusCode == 200) {
        print('✅ Sync successful');
        return true;
      } else {
        print('❌ Sync failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Sync error: $e');
      return false;
    }
  }
  
static Future<bool> isPremiumUser() async {
  try {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/status'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isPremium'] == true;
    } else {
      debugPrint('❌ Failed to fetch premium status: ${response.body}');
      return false;
    }
  } catch (e) {
    debugPrint('❌ Exception in isPremiumUser: $e');
    return false;
  }
}

}
