// test/src/datasource_test.dart

import 'package:fpdart/fpdart.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_package/theme_package.dart';

void main() {
  const validDbName = 'test_db_1234567890ab';

  setUp(() {
    ThemePackage.reset();
  });

  group('ThemeLocalDatasource (via ThemePackage)', () {
    group('inMemory mode', () {
      test('initializes successfully with inMemory true', () async {
        final result = await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        expect(result, const Right<dynamic, Unit>(unit));
      });

      test('getThemeMode returns system by default', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        expect(ThemePackage.getTheme(), ThemeMode.system);
      });

      test('setThemeMode persists value in memory', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        await ThemePackage.setTheme(ThemeMode.dark);

        expect(ThemePackage.getTheme(), ThemeMode.dark);
      });

      test('multiple setThemeMode calls update value correctly', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        await ThemePackage.setTheme(ThemeMode.dark);
        expect(ThemePackage.getTheme(), ThemeMode.dark);

        await ThemePackage.setTheme(ThemeMode.light);
        expect(ThemePackage.getTheme(), ThemeMode.light);

        await ThemePackage.setTheme(ThemeMode.system);
        expect(ThemePackage.getTheme(), ThemeMode.system);
      });
    });

    group('customPath mode', () {
      test('accepts customPath parameter', () async {
        final result = await ThemePackage.initialize(
          databaseName: validDbName,
          customPath: '/tmp/test_theme_db',
          inMemory: true, // Using inMemory to avoid actual file system
        );

        expect(result, const Right<dynamic, Unit>(unit));
      });

      test('accepts subDirectory parameter', () async {
        final result = await ThemePackage.initialize(
          databaseName: validDbName,
          subDirectory: 'custom_db_folder',
          inMemory: true,
        );

        expect(result, const Right(unit));
      });
    });
  });
}
