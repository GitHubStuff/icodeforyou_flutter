// ignore_for_file: public_member_api_docs

import 'package:animated_rail_menu/animated_rail_menu.dart';
import 'package:flutter/material.dart';
import 'package:startup_demo/src/pages/pages.dart';

const navEntries = <RailMenuEntry>[
  RailMenuEntry(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: 'Landing',
    page: LandingPage(),
  ),
  RailMenuEntry(
    icon: Icons.lightbulb_outline_sharp,
    activeIcon: Icons.lightbulb,
    label: 'Demo',
    page: DemoPage(),
  ),
  RailMenuEntry(
    icon: Icons.info_outline,
    activeIcon: Icons.info,
    label: 'About',
    page: AboutPage(),
  ),
  RailMenuEntry(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings,
    label: 'Settings',
    page: SettingsPage(),
  ),
  RailMenuEntry(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Profile',
    page: ProfilePage(),
  ),
  RailMenuEntry(
    icon: Icons.notifications_outlined,
    activeIcon: Icons.notifications,
    label: 'Alerts',
    page: NotificationsPage(),
  ),
  RailMenuEntry(
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart,
    label: 'Analytics',
    page: AnalyticsPage(),
  ),
  RailMenuEntry(
    icon: Icons.help_outline,
    activeIcon: Icons.help,
    label: 'Help',
    page: HelpPage(),
  ),
];
