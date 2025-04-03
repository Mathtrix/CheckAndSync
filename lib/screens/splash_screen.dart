import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final isAuthenticated = await _checkAuthState();

    if (isAuthenticated) {
      final lists = await AuthService.fetchLists();
      if (lists != null) {
        final box = Hive.box('lists');
        await box.put('lists', lists);
      }
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  Future<bool> _checkAuthState() async {
    final token = await AuthService.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0B0F2F), // dark navy blue
      body: Center(
        child: Text(
          'CheckAndSync.com',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFF8E1), // cream white
          ),
        ),
      ),
    );
  }
}