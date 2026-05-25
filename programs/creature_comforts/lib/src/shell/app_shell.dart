// programs/creature_comforts/lib/src/shell/app_shell.dart
import 'dart:async';

import 'package:animated_rail_menu/animated_rail_menu.dart';
import 'package:app_preferences_service/app_preferences_service.dart';
import 'package:creature_comforts/src/auth/auth_user.dart';
import 'package:creature_comforts/src/edit/edit_screen.dart';
import 'package:creature_comforts/src/home/home_screen.dart';
import 'package:creature_comforts/src/notifications/notifications_screen.dart';
import 'package:creature_comforts/src/profile/profile_screen.dart';
import 'package:creature_comforts/src/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:service_locator/service_locator.dart';

/// Storage key for the "user has decided about notification permission" flag.
///
/// `false` (or absent) means the user has never been prompted — the shell
/// auto-lands on the Notifications tab and shows the 8-second nudge.
/// `true` means the user has answered the prompt at least once (yes or no);
/// the shell respects their choice and lands on Home.
const _kNotificationsDecidedKey = 'notifications_permission_decided';

/// Hosts the five-tab navigation rail for the signed-in app.
///
/// Builds the rail entries (Home, Edit, Notifications, Profile, Settings),
/// resolves the initial tab from the persisted "notifications decided"
/// flag, and surfaces the 8-second nudge snackbar when the user hasn't
/// yet answered the OS notification prompt.
///
/// Entered only via [Authenticated] — the parent `_AuthGate` filters on
/// auth state, so this widget can assume a live signed-in session.
class AppShell extends StatefulWidget {
  const AppShell({required this.user, super.key});

  /// The signed-in user, threaded through to the Profile tab.
  final AuthUser user;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  /// `null` while the prefs read is in flight; an int once resolved.
  int? _initialIndex;
  bool _shouldNudge = false;

  static const _homeIndex = 0;
  static const _notificationsIndex = 2;

  @override
  void initState() {
    super.initState();
    unawaited(_resolveInitialTab());
  }

  Future<void> _resolveInitialTab() async {
    final prefs = ServiceRegistry.R
        .getSync<AppPreferences>('AppPreferences')
        .prefs;
    final decided = await prefs.getBool(_kNotificationsDecidedKey) ?? false;
    if (!mounted) return;
    setState(() {
      _initialIndex = decided ? _homeIndex : _notificationsIndex;
      _shouldNudge = !decided;
    });
    if (_shouldNudge) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Take a moment to set notifications'),
            duration: Duration(seconds: 8),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = _initialIndex;
    if (initial == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AnimatedRailMenu(
      direction: RailDirection.adaptive,
      defaultIndex: initial,
      entries: [
        const AnimatedRailMenuEntry(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
          page: HomeScreen(),
        ),
        const AnimatedRailMenuEntry(
          icon: Icons.edit_outlined,
          activeIcon: Icons.edit,
          label: 'Edit',
          page: EditScreen(),
        ),
        const AnimatedRailMenuEntry(
          icon: Icons.notifications_outlined,
          activeIcon: Icons.notifications,
          label: 'Notifications',
          page: NotificationsScreen(),
        ),
        AnimatedRailMenuEntry(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
          page: ProfileScreen(user: widget.user),
        ),
        const AnimatedRailMenuEntry(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'Settings',
          page: SettingsScreen(),
        ),
      ],
    );
  }
}
