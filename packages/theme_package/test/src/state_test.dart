// test/src/state_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_package/theme_package.dart';

void main() {
  const validDbName = 'test_db_1234567890ab';

  setUp(ThemePackage.reset);

  group('ThemeState (via ThemePackage)', () {
    test('initial state has ThemeMode.system', () async {
      await ThemePackage.initialize(
        databaseName: validDbName,
        inMemory: true,
      );

      expect(ThemePackage.currentTheme, ThemeMode.system);
    });

    test('state updates when theme is changed to dark', () async {
      await ThemePackage.initialize(
        databaseName: validDbName,
        inMemory: true,
      );

      await ThemePackage.setTheme(ThemeMode.dark);

      expect(ThemePackage.currentTheme, ThemeMode.dark);
    });

    test('state updates when theme is changed to light', () async {
      await ThemePackage.initialize(
        databaseName: validDbName,
        inMemory: true,
      );

      await ThemePackage.setTheme(ThemeMode.light);

      expect(ThemePackage.currentTheme, ThemeMode.light);
    });

    test('state updates correctly through multiple changes', () async {
      await ThemePackage.initialize(
        databaseName: validDbName,
        inMemory: true,
      );

      expect(ThemePackage.currentTheme, ThemeMode.system);

      await ThemePackage.setTheme(ThemeMode.dark);
      expect(ThemePackage.currentTheme, ThemeMode.dark);

      await ThemePackage.setTheme(ThemeMode.light);
      expect(ThemePackage.currentTheme, ThemeMode.light);

      await ThemePackage.setTheme(ThemeMode.system);
      expect(ThemePackage.currentTheme, ThemeMode.system);
    });
  });
}
