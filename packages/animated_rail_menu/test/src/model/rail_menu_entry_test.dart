// test/src/model/rail_menu_entry_test.dart

import 'package:animated_rail_menu/src/model/rail_menu_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RailMenuEntry', () {
    test('exposes icon, activeIcon, label and page', () {
      const entry = RailMenuEntry(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        page: SizedBox.shrink(),
      );
      expect(entry.icon, Icons.home_outlined);
      expect(entry.activeIcon, Icons.home);
      expect(entry.label, 'Home');
      expect(entry.page, isA<SizedBox>());
    });

    test('runtime instantiation hits constructor', () {
      final entry = RailMenuEntry(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Settings',
        page: const SizedBox.shrink(),
      );
      expect(entry.label, 'Settings');
    });
  });
}
