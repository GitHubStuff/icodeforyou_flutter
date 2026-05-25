// app_preferences_service/test/src/app_preferences_descriptor_test.dart
import 'dart:io';

import 'package:app_preferences/app_preferences.dart' show HiveInitMode;
import 'package:app_preferences_service/app_preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppPreferencesDescriptor', () {
    group('common', () {
      test('exposes empty dependencies', () {
        const descriptor = AppPreferencesDescriptor.platform();
        expect(descriptor.dependencies, isEmpty);
      });

      test('exposes a 500ms timeout', () {
        const descriptor = AppPreferencesDescriptor.platform();
        expect(descriptor.timeout, const Duration(milliseconds: 500));
      });

      test('uses the default service name when none is provided', () {
        const descriptor = AppPreferencesDescriptor.platform();
        expect(descriptor.name, 'AppPreferences');
      });

      test('honors a custom service name', () {
        const descriptor = AppPreferencesDescriptor.platform(
          serviceName: 'CustomPrefs',
        );
        expect(descriptor.name, 'CustomPrefs');
      });
    });

    group('hive backend', () {
      late Directory tempDir;

      setUp(() async {
        tempDir = await Directory.systemTemp.createTemp('app_prefs_hive_test_');
      });

      tearDown(() async {
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      });

      test('builds an AppPreferences from a custom Hive path', () async {
        final descriptor = AppPreferencesDescriptor.hive(
          boxName: 'test_box',
          initMode: HiveInitMode.custom,
          customPath: tempDir.path,
        );

        final prefs = await descriptor.builder();

        expect(prefs, isA<AppPreferences>());
      });
    });

    group('mock backend', () {
      test('builds an AppPreferences with no initial values', () async {
        const descriptor = AppPreferencesDescriptor.mock();

        final prefs = await descriptor.builder();

        expect(prefs, isA<AppPreferences>());
      });

      test('builds an AppPreferences seeded with initialValues', () async {
        const descriptor = AppPreferencesDescriptor.mock(
          initialValues: {'theme': 'dark', 'launchCount': 3},
        );

        final prefs = await descriptor.builder();

        expect(prefs, isA<AppPreferences>());
      });

      test('honors a custom service name on the mock variant', () {
        const descriptor = AppPreferencesDescriptor.mock(
          serviceName: 'TestPrefs',
        );
        expect(descriptor.name, 'TestPrefs');
      });
    });
  });
}
