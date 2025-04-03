import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;



class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _storage = const FlutterSecureStorage();
  String _username = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final username = await _storage.read(key: 'username') ?? 'User';
    final email = await _storage.read(key: 'email') ?? 'user@example.com';
    setState(() {
      _username = username;
      _email = email;
    });
  }

  void _changeUsername() {
    final controller = TextEditingController(text: _username);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter new username'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newUsername = controller.text.trim();
              if (newUsername.isNotEmpty) {
                await _storage.write(key: 'username', value: newUsername);
                setState(() => _username = newUsername);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Username updated successfully')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(hintText: 'Current password'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(hintText: 'New password'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(hintText: 'Confirm new password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newPassword = newPasswordController.text.trim();
              final confirmPassword = confirmPasswordController.text.trim();
              if (newPassword != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully')),
              );
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

Future<void> _upgradeToPremium() async {
  debugPrint('Upgrade button pressed');

  try {
    await PaymentService.createCheckoutSession();

    // Start periodic polling every 5 seconds
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      final premium = await AuthService.isPremiumUser();
      if (premium) {
        timer.cancel();
        setState(() => _isPremium = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 Premium features unlocked!')),
          );
        }
      }
    });
  } catch (e) {
    debugPrint('Error during checkout: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to initiate payment')),
      );
    }
  }
}


  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),
      appBar: AppBar(
        title: const Text('Account Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Account Overview'),
            tiles: [
              SettingsTile(
                title: const Text('Username'),
                value: Text(_username),
                onPressed: (context) => _changeUsername(),
              ),
              SettingsTile(
                title: const Text('Email'),
                value: Text(_email),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Account Actions'),
            tiles: [
              SettingsTile(
                title: const Text('Change Username'),
                leading: const Icon(Icons.person),
                onPressed: (context) => _changeUsername(),
              ),
              SettingsTile(
                title: const Text('Change Password'),
                leading: const Icon(Icons.lock),
                onPressed: (context) => _changePassword(),
              ),
              SettingsTile(
                title: const Text('Upgrade to Premium'),
                leading: const Icon(Icons.star),
                onPressed: (context) async {
                  await _upgradeToPremium();
                },
              ),
              SettingsTile(
                title: const Text('Delete Account'),
                leading: const Icon(Icons.delete),
                onPressed: (context) => _deleteAccount(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
