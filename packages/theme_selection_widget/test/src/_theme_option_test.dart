// test/src/_theme_option_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_selection_widget/src/_theme_option.dart';

void main() {
  group('ThemeOption', () {
    test('retains all constructor values', () {
      const option = ThemeOption(
        mode: ThemeMode.dark,
        icon: Icons.dark_mode,
        label: 'Dark',
      );

      expect(option.mode, ThemeMode.dark);
      expect(option.icon, Icons.dark_mode);
      expect(option.label, 'Dark');
    });

    test('light mode variant retains correct values', () {
      const option = ThemeOption(
        mode: ThemeMode.light,
        icon: Icons.light_mode,
        label: 'Light',
      );

      expect(option.mode, ThemeMode.light);
      expect(option.icon, Icons.light_mode);
      expect(option.label, 'Light');
    });

    test('system mode variant retains correct values', () {
      const option = ThemeOption(
        mode: ThemeMode.system,
        icon: Icons.brightness_auto,
        label: 'System',
      );

      expect(option.mode, ThemeMode.system);
      expect(option.icon, Icons.brightness_auto);
      expect(option.label, 'System');
    });
  });
}
