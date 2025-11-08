// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'login_screen.dart';

/// Settings screen constants
class _SettingsConstants {
  static const String screenTitle = 'Settings';
  static const double verticalPadding = 16.0;
  static const double sectionSpacing = 32.0;
  static const double indicatorSize = 16.0;

  // Auth status strings
  static const String authStatusTitle = 'Authentication Status';
  static const String loggedInPrefix = 'Logged in as';
  static const String notLoggedIn = 'Not logged in';

  // Sign out strings
  static const String signOutTitle = 'Sign Out';
  static const String confirmTitle = 'Sign Out?';
  static const String confirmMessage = 'Are you sure you want to sign out?';
  static const String cancelButton = 'Cancel';
  static const String confirmButton = 'Sign Out';
  static const String errorPrefix = 'Error signing out: ';
}

/// Settings screen with authentication status
/// Single Responsibility: Display app settings and auth status
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(_SettingsConstants.screenTitle)),
      body: const _SettingsContent(),
    );
  }
}

/// Main settings content
class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        vertical: _SettingsConstants.verticalPadding,
      ),
      children: const [
        _AuthStatusTile(),
        Gap(_SettingsConstants.sectionSpacing),
        _SignOutTile(),
      ],
    );
  }
}

/// Authentication status tile
class _AuthStatusTile extends StatelessWidget {
  const _AuthStatusTile();

  bool get _isAuthenticated => FirebaseAuth.instance.currentUser != null;

  String get _statusText {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email != null) {
      return '${_SettingsConstants.loggedInPrefix} ${user!.email}';
    }
    return _SettingsConstants.notLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _StatusIndicator(isActive: _isAuthenticated),
      title: const Text(_SettingsConstants.authStatusTitle),
      subtitle: Text(_statusText),
    );
  }
}

/// Status indicator light
class _StatusIndicator extends StatelessWidget {
  final bool isActive;

  const _StatusIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _SettingsConstants.indicatorSize,
      height: _SettingsConstants.indicatorSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.green : Colors.red,
      ),
    );
  }
}

/// Sign out tile
class _SignOutTile extends StatelessWidget {
  const _SignOutTile();

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(_SettingsConstants.confirmTitle),
        content: const Text(_SettingsConstants.confirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(_SettingsConstants.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(_SettingsConstants.confirmButton),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _performSignOut(context);
    }
  }

  Future<void> _performSignOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_SettingsConstants.errorPrefix}${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text(_SettingsConstants.signOutTitle),
      enabled: isLoggedIn,
      onTap: isLoggedIn ? () => _confirmSignOut(context) : null,
    );
  }
}
