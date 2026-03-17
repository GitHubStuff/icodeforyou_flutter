// lib/src/navigation/app_route.dart

// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';
import 'package:rail_menu/rail_menu.dart';

/// Every top-level route in the app.
///
/// Each value carries its path, rail index, icon, label, and
/// entry transitions — the single source of truth for all.
enum AppRoute {
  landing(
    '/',
    Icons.home,
    'Landing',
  ),
  settings(
    '/settings',
    Icons.settings,
    'Settings',
  ),
  profile(
    '/profile',
    Icons.person,
    'Profile',
  ),
  notifications(
    '/notifications',
    Icons.notifications,
    'Alerts',
  ),
  analytics(
    '/analytics',
    Icons.bar_chart,
    'Analytics',
  ),
  help(
    '/help',
    Icons.help,
    'Help',
  ),
  about(
    '/about',
    Icons.info,
    'About',
  )
  ;

  const AppRoute(
    this.path,
    this.icon,
    this.label, {
    this.transitionFromLeft = RailMenuTransition.slideFromLeft,
    this.transitionFromRight = RailMenuTransition.slideFromRight,
  });

  final String path;
  final IconData icon;
  final String label;
  final RailMenuTransition transitionFromLeft;
  final RailMenuTransition transitionFromRight;
}
