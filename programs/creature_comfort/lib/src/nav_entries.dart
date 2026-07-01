// startup_demo/lib/src/navigation/nav_entries.dart
// ignore_for_file: always_use_package_imports, public_member_api_docs

import 'package:animated_rail_menu/animated_rail_menu.dart'
    show AnimatedRailMenuEntry;
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'screens/_screens.dart'
    show
        HomePage,
        LoginPage,
        OrientationPage,
        SettingsPage,
        SubscriptionsPage,
        WidgetsPage;

final navEntries = <AnimatedRailMenuEntry>[
  const AnimatedRailMenuEntry(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: 'Home',
    page: HomePage(),
  ),
  const AnimatedRailMenuEntry(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings,
    label: 'Settings',
    page: SettingsPage(),
  ),
  const AnimatedRailMenuEntry(
    icon: Icons.login_outlined,
    activeIcon: Icons.login,
    label: 'Login',
    page: LoginPage(),
  ),
  const AnimatedRailMenuEntry(
    icon: Icons.widgets_outlined,
    activeIcon: Icons.widgets,
    label: 'Widgets',
    page: WidgetsPage(),
  ),
  const AnimatedRailMenuEntry(
    icon: Icons.notifications_outlined,
    activeIcon: Icons.notifications_active,
    label: 'Subscriptions',
    page: SubscriptionsPage(),
  ),
  const AnimatedRailMenuEntry(
    icon: Symbols.exercise,
    activeIcon: Symbols.exercise_rounded,
    label: 'Orientation',
    page: OrientationPage(),
  ),
];
