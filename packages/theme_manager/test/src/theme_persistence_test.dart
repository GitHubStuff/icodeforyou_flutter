// theme_manager/test/src/theme_mode/theme_persistence_test.dart

import 'package:app_preferences/app_preferences.dart' show MockPreferences;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_manager/theme_manager.dart' show ThemePersistence;

void main() {
  // Same key the production class uses; kept private there, so we
  // duplicate the literal here to verify the wire format. If the key
  // changes in production, this test must be updated deliberately.
  const persistedKey = 'theme_mode-317293440000';

  group('ThemePersistence', () {
    late MockPreferences mockPreferences;

    setUp(() {
      mockPreferences = MockPreferences();
    });

    group('create', () {
      test(
        'returns a ThemePersistence wrapping the given preferences',
        () async {
          final persistence = await ThemePersistence.create(mockPreferences);

          expect(persistence, isA<ThemePersistence>());
        },
      );
    });

    group('load', () {
      test('returns ThemeMode.dark when no value is persisted', () async {
        final persistence = await ThemePersistence.create(mockPreferences);

        expect(await persistence.load(), ThemeMode.dark);
      });

      test('returns ThemeMode.light when "light" is persisted', () async {
        await mockPreferences.setString(persistedKey, ThemeMode.light.name);
        final persistence = await ThemePersistence.create(mockPreferences);

        expect(await persistence.load(), ThemeMode.light);
      });

      test('returns ThemeMode.dark when "dark" is persisted', () async {
        await mockPreferences.setString(persistedKey, ThemeMode.dark.name);
        final persistence = await ThemePersistence.create(mockPreferences);

        expect(await persistence.load(), ThemeMode.dark);
      });

      test('returns ThemeMode.system when "system" is persisted', () async {
        await mockPreferences.setString(persistedKey, ThemeMode.system.name);
        final persistence = await ThemePersistence.create(mockPreferences);

        expect(await persistence.load(), ThemeMode.system);
      });

      test('returns ThemeMode.dark when stored value is unknown', () async {
        await mockPreferences.setString(persistedKey, 'not_a_real_mode');
        final persistence = await ThemePersistence.create(mockPreferences);

        expect(await persistence.load(), ThemeMode.dark);
      });
    });

    group('save', () {
      test('writes ThemeMode.light by name under the persisted key', () async {
        final persistence = await ThemePersistence.create(mockPreferences);

        await persistence.save(ThemeMode.light);

        expect(mockPreferences.peek(persistedKey), ThemeMode.light.name);
      });

      test('writes ThemeMode.dark by name under the persisted key', () async {
        final persistence = await ThemePersistence.create(mockPreferences);

        await persistence.save(ThemeMode.dark);

        expect(mockPreferences.peek(persistedKey), ThemeMode.dark.name);
      });

      test('writes ThemeMode.system by name under the persisted key', () async {
        final persistence = await ThemePersistence.create(mockPreferences);

        await persistence.save(ThemeMode.system);

        expect(mockPreferences.peek(persistedKey), ThemeMode.system.name);
      });

      test('overwrites a previously saved value', () async {
        final persistence = await ThemePersistence.create(mockPreferences);

        await persistence.save(ThemeMode.light);
        await persistence.save(ThemeMode.system);

        expect(mockPreferences.peek(persistedKey), ThemeMode.system.name);
      });
    });

    group('round-trip', () {
      test('save then load returns the same ThemeMode', () async {
        final persistence = await ThemePersistence.create(mockPreferences);

        for (final mode in ThemeMode.values) {
          await persistence.save(mode);
          expect(await persistence.load(), mode);
        }
      });
    });
  });
}
