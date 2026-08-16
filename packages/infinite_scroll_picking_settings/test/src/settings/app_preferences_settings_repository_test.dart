// packages/infinite_scroll_picking_settings/test/src/settings/app_preferences_settings_repository_test.dart

import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:app_preferences/app_preferences.dart'
    show AbstractPreferencesInterface;
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/src/picker_visual_settings/picker_visual_settings.dart'
    show PickerVisualSettings;
import 'package:infinite_scroll_picking_settings/src/settings/app_preferences_settings_repository.dart'
    show AppPreferencesSettingsRepository;

/// In-memory string store faking only the three interface members the
/// repository touches: [getString], [setString], and [remove].
final class _FakePreferences extends Fake
    implements AbstractPreferencesInterface {
  /// Backing store keyed by preference key.
  final Map<String, String> store = {};

  @override
  Future<String?> getString(String key) async => store[key];

  @override
  Future<void> setString(String key, String value) async {
    store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    store.remove(key);
  }
}

/// Non-default settings used across the save/load round-trip tests.
const _kSettings = PickerVisualSettings(
  startingIndex: 4,
  frameBorderRadius: 2,
);

void main() {
  group('AppPreferencesSettingsRepository', () {
    test('defaultStorageKey is the documented constant', () {
      expect(
        AppPreferencesSettingsRepository.defaultStorageKey,
        'InfiniteScrollPicking',
      );
    });

    test('load returns null when the key is missing', () async {
      final repository = AppPreferencesSettingsRepository(
        _FakePreferences(),
      );
      expect(await repository.load(), isNull);
    });

    test('load returns null when the stored string is empty', () async {
      final prefs = _FakePreferences()
        ..store[AppPreferencesSettingsRepository.defaultStorageKey] = '';
      final repository = AppPreferencesSettingsRepository(prefs);

      expect(await repository.load(), isNull);
    });

    test('save encodes JSON under the default key; load decodes it back',
        () async {
      final prefs = _FakePreferences();
      final repository = AppPreferencesSettingsRepository(prefs);

      await repository.save(_kSettings);

      final raw = prefs
          .store[AppPreferencesSettingsRepository.defaultStorageKey];
      expect(raw, isNotNull);
      expect(jsonDecode(raw!), isA<Map<String, dynamic>>());
      expect(await repository.load(), _kSettings);
    });

    test('a custom storageKey namespaces the stored value', () async {
      final prefs = _FakePreferences();
      final repository = AppPreferencesSettingsRepository(
        prefs,
        storageKey: 'mySpace.pickerVisuals',
      );

      await repository.save(_kSettings);

      expect(prefs.store.keys, ['mySpace.pickerVisuals']);
      expect(await repository.load(), _kSettings);
    });

    test('load throws FormatException when the JSON is not a map',
        () async {
      final prefs = _FakePreferences()
        ..store[AppPreferencesSettingsRepository.defaultStorageKey] =
            jsonEncode([1, 2, 3]);
      final repository = AppPreferencesSettingsRepository(prefs);

      expect(
        repository.load(),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('expected Map<String, dynamic>'),
          ),
        ),
      );
    });

    test('load rethrows schema mismatches from fromJson', () async {
      final prefs = _FakePreferences()
        ..store[AppPreferencesSettingsRepository.defaultStorageKey] =
            jsonEncode({'startingIndex': 'not-a-number'});
      final repository = AppPreferencesSettingsRepository(prefs);

      expect(repository.load(), throwsA(isA<TypeError>()));
    });

    test('clear removes the key so load returns null again', () async {
      final prefs = _FakePreferences();
      final repository = AppPreferencesSettingsRepository(prefs);
      await repository.save(_kSettings);

      await repository.clear();

      expect(prefs.store, isEmpty);
      expect(await repository.load(), isNull);
    });
  });
}
