// theme_manager/test/src/cubit/material_theme_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_manager/src/cubit/material_theme.dart';

void main() {
  group('MaterialTheme constructor', () {
    test('applies defaults when no arguments are provided', () {
      final theme = MaterialTheme();

      expect(theme.mode, ThemeMode.dark);
      expect(theme.dark.brightness, Brightness.dark);
      expect(theme.dark.useMaterial3, isTrue);
      expect(theme.light.brightness, Brightness.light);
      expect(theme.light.useMaterial3, isTrue);
    });

    test('uses provided values when supplied', () {
      final customDark = ThemeData.dark();
      final customLight = ThemeData.light();
      final theme = MaterialTheme(
        mode: ThemeMode.light,
        dark: customDark,
        light: customLight,
      );

      expect(theme.mode, ThemeMode.light);
      expect(theme.dark, same(customDark));
      expect(theme.light, same(customLight));
    });
  });

  group('MaterialTheme.copyWith', () {
    test('returns an identical instance when no overrides are provided', () {
      final original = MaterialTheme();
      final copy = original.copyWith();

      expect(copy.mode, original.mode);
      expect(copy.dark, same(original.dark));
      expect(copy.light, same(original.light));
    });

    test('overrides mode only', () {
      final original = MaterialTheme();
      final copy = original.copyWith(mode: ThemeMode.light);

      expect(copy.mode, ThemeMode.light);
      expect(copy.dark, same(original.dark));
      expect(copy.light, same(original.light));
    });

    test('overrides dark only', () {
      final original = MaterialTheme();
      final newDark = ThemeData.dark();
      final copy = original.copyWith(dark: newDark);

      expect(copy.mode, original.mode);
      expect(copy.dark, same(newDark));
      expect(copy.light, same(original.light));
    });

    test('overrides light only', () {
      final original = MaterialTheme();
      final newLight = ThemeData.light();
      final copy = original.copyWith(light: newLight);

      expect(copy.mode, original.mode);
      expect(copy.dark, same(original.dark));
      expect(copy.light, same(newLight));
    });

    test('overrides all fields at once', () {
      final original = MaterialTheme();
      final newDark = ThemeData.dark();
      final newLight = ThemeData.light();
      final copy = original.copyWith(
        mode: ThemeMode.system,
        dark: newDark,
        light: newLight,
      );

      expect(copy.mode, ThemeMode.system);
      expect(copy.dark, same(newDark));
      expect(copy.light, same(newLight));
    });
  });
}
