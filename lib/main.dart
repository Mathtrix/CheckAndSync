import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/account_settings_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/list_entries_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter();

  await Hive.openBox('lists');
  Stripe.publishableKey = 'pk_test_51R38PcGVMTfRB3LA4QHNrpUxy0xoneyEE12qRlE9mORTgsVro3OtGGUdMQKFNe01az2E55XvQjZexfnToD6xJcEp001VgjxlNV';

  runApp(const CheckAndSyncApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const AccountSettingsScreen()),
  ],
);

class CheckAndSyncApp extends StatelessWidget {
  const CheckAndSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CheckAndSync.com',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0A1A2F),
        scaffoldBackgroundColor: const Color(0xFF0A1A2F),
        cardColor: const Color(0xFFFFFDE7),
      ),
      routerConfig: _router,
    );
  }
}
