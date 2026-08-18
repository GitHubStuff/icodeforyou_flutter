// packages/theme_framework/test/src/preferences/shared_preferences_theme_storage_test.dart

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_framework/theme_framework.dart' show SharedPreferencesThemeStorage;

void main() {
  const kThemeModeKey = 'theme_framework.theme_mode';

  group('SharedPreferencesThemeStorage', () {
    test('read returns null when no value is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = SharedPreferencesThemeStorage(prefs);

      final result = await storage.read();

      expect(result, isNull);
    });

    test(
      'read returns the correct ThemeMode when a valid name is stored',
      () async {
        // Seed the mock storage with 'dark'
        SharedPreferences.setMockInitialValues({
          kThemeModeKey: ThemeMode.dark.name,
        });
        final prefs = await SharedPreferences.getInstance();
        final storage = SharedPreferencesThemeStorage(prefs);

        final result = await storage.read();

        expect(result, ThemeMode.dark);
      },
    );

    test(
      'read returns null when an unknown or invalid string is stored',
      () async {
        // Seed the mock storage with a string that does not exist in ThemeMode.values
        SharedPreferences.setMockInitialValues({
          kThemeModeKey: 'super_dark_mode',
        });
        final prefs = await SharedPreferences.getInstance();
        final storage = SharedPreferencesThemeStorage(prefs);

        final result = await storage.read();

        expect(result, isNull);
      },
    );

    test('write correctly persists the ThemeMode as a string', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = SharedPreferencesThemeStorage(prefs);

      await storage.write(ThemeMode.light);

      // Verify the storage adapter successfully wrote the enum's name
      expect(prefs.getString(kThemeModeKey), ThemeMode.light.name);
    });
  });
}
