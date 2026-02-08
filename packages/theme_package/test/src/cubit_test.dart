// test/src/cubit_test.dart

import 'package:fpdart/fpdart.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_package/theme_package.dart';

void main() {
  const validDbName = 'test_db_1234567890ab';

  setUp(() {
    ThemePackage.reset();
  });

  group('ThemeCubit (via ThemePackage)', () {
    group('initial state', () {
      test('has ThemeMode.system when no persisted value', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        expect(ThemePackage.currentTheme, ThemeMode.system);
      });
    });

    group('setTheme', () {
      test('emits new state with ThemeMode.dark', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        final result = await ThemePackage.setTheme(ThemeMode.dark);

        expect(result, const Right(unit));
        expect(ThemePackage.currentTheme, ThemeMode.dark);
      });

      test('emits new state with ThemeMode.light', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        final result = await ThemePackage.setTheme(ThemeMode.light);

        expect(result, const Right(unit));
        expect(ThemePackage.currentTheme, ThemeMode.light);
      });

      test('emits new state with ThemeMode.system', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        // First change to dark
        await ThemePackage.setTheme(ThemeMode.dark);
        expect(ThemePackage.currentTheme, ThemeMode.dark);

        // Then change to system
        final result = await ThemePackage.setTheme(ThemeMode.system);

        expect(result, const Right(unit));
        expect(ThemePackage.currentTheme, ThemeMode.system);
      });

      test('persists theme change to datasource', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        await ThemePackage.setTheme(ThemeMode.dark);

        // Both currentTheme (from cubit state) and getTheme (from datasource) should match
        expect(ThemePackage.currentTheme, ThemeMode.dark);
        expect(ThemePackage.getTheme(), ThemeMode.dark);
      });

      test('handles rapid theme changes', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        // Rapid changes
        await ThemePackage.setTheme(ThemeMode.dark);
        await ThemePackage.setTheme(ThemeMode.light);
        await ThemePackage.setTheme(ThemeMode.system);
        await ThemePackage.setTheme(ThemeMode.dark);
        await ThemePackage.setTheme(ThemeMode.light);

        expect(ThemePackage.currentTheme, ThemeMode.light);
        expect(ThemePackage.getTheme(), ThemeMode.light);
      });
    });
  });
}
