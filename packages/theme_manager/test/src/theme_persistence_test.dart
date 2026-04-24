// test/src/theme_persistence_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart'
    show InMemorySharedPreferencesAsync;
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart'
    show SharedPreferencesAsyncPlatform;
import 'package:theme_manager/src/theme_persistence.dart' show ThemePersistence;

void main() {
  group('ThemePersistence', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    test('create returns a ThemePersistence instance', () async {
      final persistence = await ThemePersistence.create();
      expect(persistence, isA<ThemePersistence>());
    });

    test('load returns ThemeMode.dark when no value persisted', () async {
      final persistence = await ThemePersistence.create();
      expect(persistence.load(), ThemeMode.dark);
    });

    test('load returns ThemeMode.light after saving light', () async {
      final persistence = await ThemePersistence.create();
      await persistence.save(ThemeMode.light);
      expect(persistence.load(), ThemeMode.light);
    });

    test('load returns ThemeMode.dark after saving dark', () async {
      final persistence = await ThemePersistence.create();
      await persistence.save(ThemeMode.dark);
      expect(persistence.load(), ThemeMode.dark);
    });

    test('load returns ThemeMode.system after saving system', () async {
      final persistence = await ThemePersistence.create();
      await persistence.save(ThemeMode.system);
      expect(persistence.load(), ThemeMode.system);
    });

    test('load returns ThemeMode.dark for unknown persisted value', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData(
            {'flutter.theme_mode': 'unknown_value'},
          );
      final persistence = await ThemePersistence.create();
      expect(persistence.load(), ThemeMode.dark);
    });
  });
}
