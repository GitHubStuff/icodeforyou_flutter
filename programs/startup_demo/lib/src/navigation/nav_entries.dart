// startup_demo/lib/src/navigation/nav_entries.dart
// ignore_for_file: public_member_api_docs

import 'package:animated_rail_menu/animated_rail_menu.dart'
    show AnimatedRailMenuEntry;
import 'package:flutter/material.dart';
import 'package:startup_demo/src/pages/fader_page.dart' show FaderPage;
import 'package:startup_demo/src/pages/pages.dart';

const navEntries = <AnimatedRailMenuEntry>[
  AnimatedRailMenuEntry(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: 'Landing',
    page: LandingPage(),
  ),
  AnimatedRailMenuEntry(
    icon: Icons.lightbulb_outline_sharp,
    activeIcon: Icons.lightbulb,
    label: 'Demo',
    page: DemoPage(),
  ),
  AnimatedRailMenuEntry(
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart,
    label: 'Analytics',
    page: AnalyticsPage(),
  ),
  AnimatedRailMenuEntry(
    icon: Icons.fastfood_sharp,
    activeIcon: Icons.fastfood,
    label: 'Fade',
    page: FaderPage(),
  ),
  AnimatedRailMenuEntry(
    icon: Icons.storage_outlined,
    activeIcon: Icons.storage,
    label: 'Database',
    page: DatabasePage(),
  ),
  AnimatedRailMenuEntry(
    icon: Icons.info_outline,
    activeIcon: Icons.info,
    label: 'About',
    page: AboutPage(),
  ),
  AnimatedRailMenuEntry(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings,
    label: 'Settings',
    page: SettingsPage(),
  ),
  AnimatedRailMenuEntry(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Profile',
    page: ProfilePage(),
  ),
  AnimatedRailMenuEntry(
    icon: Icons.notifications_outlined,
    activeIcon: Icons.notifications,
    label: 'Alerts',
    page: NotificationsPage(),
  ),
  AnimatedRailMenuEntry(
    icon: Icons.help_outline,
    activeIcon: Icons.help,
    label: 'Help',
    page: HelpPage(),
  ),
];
