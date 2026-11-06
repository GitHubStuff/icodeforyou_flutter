// packages/theme_mode_cubit/test/src/theme_mode_storage_test.dart

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferencesAsync;
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:theme_mode_cubit/src/theme_mode_storage.dart'
    show ThemeModeStorage;

class MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Registers the default in-memory platform implementation for unit tests
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  const testKey = 'theme_framework.theme_mode';

  group('ThemeModeStorage', () {
    late MockSharedPreferencesAsync mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferencesAsync();
    });

    test(
      'instantiates with default SharedPreferencesAsync when prefs is null',
      () {
        final storage = ThemeModeStorage();
        expect(storage, isA<ThemeModeStorage>());
      },
    );

    group('read', () {
      test(
        'returns decoded ThemeMode when key contains a valid enum name',
        () async {
          when(() => mockPrefs.getString(testKey))
              .thenAnswer((_) async => ThemeMode.dark.name);

          final storage = ThemeModeStorage(prefs: mockPrefs);
          final result = await storage.read();

          expect(result, equals(ThemeMode.dark));
          verify(() => mockPrefs.getString(testKey)).called(1);
        },
      );

      test('returns ThemeMode.system when key is absent (null)', () async {
        when(() => mockPrefs.getString(testKey)).thenAnswer((_) async => null);

        final storage = ThemeModeStorage(prefs: mockPrefs);
        final result = await storage.read();

        expect(result, equals(ThemeMode.system));
        verify(() => mockPrefs.getString(testKey)).called(1);
      });

      test(
        'returns ThemeMode.system when key contains an unknown string',
        () async {
          when(() => mockPrefs.getString(testKey))
              .thenAnswer((_) async => 'non_existent_mode');

          final storage = ThemeModeStorage(prefs: mockPrefs);
          final result = await storage.read();

          expect(result, equals(ThemeMode.system));
          verify(() => mockPrefs.getString(testKey)).called(1);
        },
      );
    });

    group('write', () {
      test('persists enum name to shared preferences', () async {
        when(() => mockPrefs.setString(testKey, ThemeMode.light.name))
            .thenAnswer((_) async {});

        final storage = ThemeModeStorage(prefs: mockPrefs);
        await storage.write(ThemeMode.light);

        verify(() => mockPrefs.setString(testKey, ThemeMode.light.name))
            .called(1);
      });
    });
  });
}
