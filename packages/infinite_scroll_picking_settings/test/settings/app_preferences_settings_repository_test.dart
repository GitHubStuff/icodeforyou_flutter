// infinite_scroll_picking_settings/test/settings/app_preferences_settings_repository_test.dart

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:app_preferences/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/infinite_scroll_picking_settings.dart';
import 'package:mocktail/mocktail.dart';

class _ThrowingPreferences extends Mock implements AbstractPreferencesInterface {}

void main() {
  group('AppPreferencesSettingsRepository', () {
    late MockPreferences prefs;
    late AppPreferencesSettingsRepository repo;

    setUp(() {
      prefs = MockPreferences();
      repo = AppPreferencesSettingsRepository(prefs);
    });

    group('storage key', () {
      test('defaults to InfiniteScrollPicking', () {
        expect(
          AppPreferencesSettingsRepository.defaultStorageKey,
          'InfiniteScrollPicking',
        );
        expect(repo.storageKey, 'InfiniteScrollPicking');
      });

      test('honours a custom key on the constructor', () async {
        const customKey = 'myApp.pickerVisuals';
        final custom = AppPreferencesSettingsRepository(
          prefs,
          storageKey: customKey,
        );
        await custom.save(const PickerVisualSettings());
        expect(await prefs.contains(customKey), isTrue);
        expect(await prefs.contains('InfiniteScrollPicking'), isFalse);
      });
    });

    group('load', () {
      test('returns null when key is absent (first launch)', () async {
        expect(await repo.load(), isNull);
      });

      test('returns null when key is present but empty', () async {
        await prefs.setString(repo.storageKey, '');
        expect(await repo.load(), isNull);
      });

      test('round-trips a saved settings object', () async {
        const original = PickerVisualSettings(
          wheel: WheelSettings(wheelHeight: 60, magnification: 1.5),
          startingIndex: 7,
          frameBorderRadius: 16,
        );
        await repo.save(original);
        expect(await repo.load(), equals(original));
      });

      test('throws FormatException when stored JSON is not parseable', () async {
        await prefs.setString(repo.storageKey, '{not valid json');
        expect(repo.load(), throwsA(isA<FormatException>()));
      });

      test('throws FormatException when stored JSON is not an object', () async {
        await prefs.setString(repo.storageKey, '"a string"');
        expect(repo.load(), throwsA(isA<FormatException>()));
      });

      test('throws FormatException on numeric top-level JSON', () async {
        await prefs.setString(repo.storageKey, '42');
        expect(repo.load(), throwsA(isA<FormatException>()));
      });
    });

    group('save', () {
      test('writes JSON-encoded settings under the storage key', () async {
        const settings = PickerVisualSettings(startingIndex: 3);
        await repo.save(settings);
        final raw = await prefs.getString(repo.storageKey);
        expect(raw, isNotNull);
        expect(jsonDecode(raw!), equals(settings.toJson()));
      });

      test('overwrites a previous value', () async {
        await repo.save(const PickerVisualSettings(startingIndex: 1));
        await repo.save(const PickerVisualSettings(startingIndex: 9));
        final loaded = await repo.load();
        expect(loaded?.startingIndex, 9);
      });

      test('propagates errors from the underlying store', () async {
        final throwing = _ThrowingPreferences();
        when(() => throwing.setString(any(), any())).thenThrow(
          StateError('disk full'),
        );
        final brokenRepo = AppPreferencesSettingsRepository(throwing);
        expect(
          () => brokenRepo.save(const PickerVisualSettings()),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('clear', () {
      test('removes a previously saved value', () async {
        await repo.save(const PickerVisualSettings(startingIndex: 4));
        await repo.clear();
        expect(await prefs.contains(repo.storageKey), isFalse);
        expect(await repo.load(), isNull);
      });

      test('is a no-op when no value is present', () async {
        await repo.clear();
        expect(await repo.load(), isNull);
      });
    });

    group('serialization shape', () {
      test('encoded payload is valid JSON', () async {
        await repo.save(const PickerVisualSettings());
        final raw = await prefs.getString(repo.storageKey);
        expect(() => jsonDecode(raw!), returnsNormally);
      });

      test('encoded payload matches PickerVisualSettings.toJson', () async {
        const settings = PickerVisualSettings(
          wheel: WheelSettings(itemExtent: 32),
          startingIndex: 2,
        );
        await repo.save(settings);
        final raw = await prefs.getString(repo.storageKey);
        expect(raw, equals(jsonEncode(settings.toJson())));
      });
    });
  });
}
