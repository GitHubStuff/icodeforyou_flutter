// animated_rail_menu/lib/src/model/animated_rail_menu_entry.dart

import 'package:flutter/widgets.dart';

/// A single entry in an [AnimatedRailMenuEntry].
///
/// Combines the navigation item appearance with the page it presents.
///
/// ```dart
/// AnimatedRailMenuEntry(
///   icon: Icons.home_outlined,
///   activeIcon: Icons.home,
///   label: 'Home',
///   page: const HomePage(),
/// )
/// ```
class AnimatedRailMenuEntry {
  /// Creates an [AnimatedRailMenuEntry].
  const AnimatedRailMenuEntry({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.page,
  });

  /// The icon displayed when this entry is inactive.
  final IconData icon;

  /// The icon displayed when this entry is active.
  final IconData activeIcon;

  /// The label displayed below the icon.
  final String label;

  /// The page displayed when this entry is active.
  final Widget page;
}
