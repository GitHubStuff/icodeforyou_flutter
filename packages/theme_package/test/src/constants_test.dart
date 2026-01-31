// test/src/constants_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_package/theme_package.dart';

void main() {
  const validDbName = 'test_db_1234567890ab';

  setUp(() {
    ThemePackage.reset();
  });

  group('ThemeConstants (via ThemePackage)', () {
    group('stringToThemeMode', () {
      test('defaults to system when no value stored', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        // Fresh initialization should default to system
        expect(ThemePackage.getTheme(), ThemeMode.system);
      });

      test('converts system string to ThemeMode.system', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        await ThemePackage.setTheme(ThemeMode.system);
        expect(ThemePackage.getTheme(), ThemeMode.system);
      });

      test('converts light string to ThemeMode.light', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        await ThemePackage.setTheme(ThemeMode.light);
        expect(ThemePackage.getTheme(), ThemeMode.light);
      });

      test('converts dark string to ThemeMode.dark', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        await ThemePackage.setTheme(ThemeMode.dark);
        expect(ThemePackage.getTheme(), ThemeMode.dark);
      });
    });

    group('themeModeToString', () {
      test('persists ThemeMode.system correctly', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        await ThemePackage.setTheme(ThemeMode.dark);
        await ThemePackage.setTheme(ThemeMode.system);

        expect(ThemePackage.getTheme(), ThemeMode.system);
      });

      test('persists ThemeMode.light correctly', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        await ThemePackage.setTheme(ThemeMode.light);

        expect(ThemePackage.getTheme(), ThemeMode.light);
      });

      test('persists ThemeMode.dark correctly', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        await ThemePackage.setTheme(ThemeMode.dark);

        expect(ThemePackage.getTheme(), ThemeMode.dark);
      });
    });
  });
}
