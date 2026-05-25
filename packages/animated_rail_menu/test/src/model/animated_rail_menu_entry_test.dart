// animated_rail_menu/test/src/model/animated_rail_menu_entry_test.dart

// ignore_for_file: prefer_const_constructors

import 'package:animated_rail_menu/src/model/animated_rail_menu_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedRailMenuEntry', () {
    const icon = Icons.home_outlined;
    const activeIcon = Icons.home;
    const label = 'Home';
    const page = SizedBox.shrink();

    test('constructs with all required fields', () {
      final entry = AnimatedRailMenuEntry(
        icon: icon,
        activeIcon: activeIcon,
        label: label,
        page: page,
      );

      expect(entry.icon, icon);
      expect(entry.activeIcon, activeIcon);
      expect(entry.label, label);
      expect(entry.page, page);
    });

    test('preserves distinct icon and activeIcon references', () {
      final entry = AnimatedRailMenuEntry(
        icon: icon,
        activeIcon: activeIcon,
        label: label,
        page: page,
      );

      expect(entry.icon, isNot(entry.activeIcon));
    });
  });
}
