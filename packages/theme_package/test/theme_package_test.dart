// test/theme_package_test.dart

// ignore_for_file: lines_longer_than_80_chars, document_ignores, inference_failure_on_instance_creation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:theme_package/theme_package.dart';

void main() {
  const validDbName = 'test_db_1234567890ab';

  setUp(ThemePackage.reset);

  group('ThemePackage', () {
    group('isInitialized', () {
      test('returns false before initialization', () {
        expect(ThemePackage.isInitialized, isFalse);
      });

      test('returns true after initialization', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        expect(ThemePackage.isInitialized, isTrue);
      });
    });

    group('initialize', () {
      test('returns Right(unit) on successful initialization', () async {
        final result = await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        expect(result, const Right(unit));
      });

      test('returns Right(unit) when already initialized', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        final result = await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        expect(result, const Right(unit));
      });

      test(
        'throws ArgumentError for databaseName less than 20 characters',
        () async {
          expect(
            () =>
                ThemePackage.initialize(databaseName: 'short', inMemory: true),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('must be exactly 20 characters'),
              ),
            ),
          );
        },
      );

      test(
        'throws ArgumentError for databaseName more than 20 characters',
        () async {
          expect(
            () => ThemePackage.initialize(
              databaseName: 'this_is_way_too_long_for_database_name',
              inMemory: true,
            ),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('must be exactly 20 characters'),
              ),
            ),
          );
        },
      );

      test(
        'throws ArgumentError for databaseName with invalid characters',
        () async {
          expect(
            () => ThemePackage.initialize(
              databaseName: 'invalid@name!here#xx',
              inMemory: true,
            ),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('invalid characters'),
              ),
            ),
          );
        },
      );

      test(
        'accepts databaseName with valid characters (letters, numbers, underscore, hyphen)',
        () async {
          final result = await ThemePackage.initialize(
            databaseName: 'valid_db-name_123456',
            inMemory: true,
          );

          expect(result, const Right(unit));
        },
      );

      test('returns Right when testDatasourceInitializer succeeds', () async {
        ThemePackage.testDatasourceInitializer = () async {
          return const Right(unit);
        };

        final result = await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        expect(result, const Right(unit));
        expect(ThemePackage.isInitialized, isTrue);
      });

      test('returns Left when datasource initialization fails', () async {
        ThemePackage.testDatasourceInitializer = () async {
          return const Left(
            ThemeError.initializationFailed('Test error: datasource failed'),
          );
        };

        final result = await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        expect(result.isLeft(), isTrue);
        result.match(
          (error) => expect(error.toString(), contains('Test error')),
          (_) => fail('Expected Left'),
        );
      });

      test(
        'returns Left when exception is thrown during initialization',
        () async {
          ThemePackage.testDatasourceInitializer = () async {
            throw Exception('Unexpected failure');
          };

          final result = await ThemePackage.initialize(
            databaseName: validDbName,
            inMemory: true,
          );

          expect(result.isLeft(), isTrue);
          result.match(
            (error) => expect(error.toString(), contains('Unexpected failure')),
            (_) => fail('Expected Left'),
          );
        },
      );

      test(
        'returns Left when Hive initialization fails with invalid path',
        () async {
          // Use a path that cannot be written to
          final result = await ThemePackage.initialize(
            databaseName: validDbName,
            customPath: '/nonexistent/readonly/path',
          );

          expect(result.isLeft(), isTrue);
          result.match(
            (error) => expect(error, isA<ThemeError>()),
            (_) => fail('Expected Left from Hive failure'),
          );
        },
      );
    });

    group('currentTheme', () {
      test('throws StateError when not initialized', () {
        expect(
          () => ThemePackage.currentTheme,
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('has not been initialized'),
            ),
          ),
        );
      });

      test(
        'returns ThemeMode.system by default after initialization',
        () async {
          await ThemePackage.initialize(
            databaseName: validDbName,
            inMemory: true,
          );

          expect(ThemePackage.currentTheme, ThemeMode.system);
        },
      );
    });

    group('getTheme', () {
      test('throws StateError when not initialized', () {
        expect(
          ThemePackage.getTheme,
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('has not been initialized'),
            ),
          ),
        );
      });

      test(
        'returns ThemeMode.system by default after initialization',
        () async {
          await ThemePackage.initialize(
            databaseName: validDbName,
            inMemory: true,
          );

          expect(ThemePackage.getTheme(), ThemeMode.system);
        },
      );
    });

    group('setTheme', () {
      test('throws StateError when not initialized', () {
        expect(
          () => ThemePackage.setTheme(ThemeMode.dark),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('has not been initialized'),
            ),
          ),
        );
      });

      test('sets theme to dark and persists it', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        final result = await ThemePackage.setTheme(ThemeMode.dark);

        expect(result, const Right(unit));
        expect(ThemePackage.currentTheme, ThemeMode.dark);
        expect(ThemePackage.getTheme(), ThemeMode.dark);
      });

      test('sets theme to light and persists it', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        final result = await ThemePackage.setTheme(ThemeMode.light);

        expect(result, const Right(unit));
        expect(ThemePackage.currentTheme, ThemeMode.light);
        expect(ThemePackage.getTheme(), ThemeMode.light);
      });

      test('sets theme to system and persists it', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        // First set to dark
        await ThemePackage.setTheme(ThemeMode.dark);

        // Then set back to system
        final result = await ThemePackage.setTheme(ThemeMode.system);

        expect(result, const Right(unit));
        expect(ThemePackage.currentTheme, ThemeMode.system);
        expect(ThemePackage.getTheme(), ThemeMode.system);
      });

      test('returns Left when persistence fails', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        ThemePackage.forceSetThemeFailure = true;

        final result = await ThemePackage.setTheme(ThemeMode.dark);

        expect(result.isLeft(), isTrue);
        result.match(
          (error) => expect(error.toString(), contains('Forced test failure')),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('reset', () {
      test('resets initialized state', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        expect(ThemePackage.isInitialized, isTrue);

        ThemePackage.reset();

        expect(ThemePackage.isInitialized, isFalse);
      });

      test('allows re-initialization after reset', () async {
        await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        ThemePackage.reset();

        final result = await ThemePackage.initialize(
          databaseName: validDbName,
          inMemory: true,
        );

        expect(result, const Right(unit));
        expect(ThemePackage.isInitialized, isTrue);
      });
    });
  });
}
