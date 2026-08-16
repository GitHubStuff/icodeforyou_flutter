// packages/infinite_scroll_picking_settings/test/src/settings/settings_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/src/picker_visual_settings/picker_visual_settings.dart'
    show PickerVisualSettings;
import 'package:infinite_scroll_picking_settings/src/settings/settings_repository.dart'
    show SettingsRepository;

/// Minimal in-memory implementation exercising the interface contract:
/// `null` for "never saved", the saved value after [save], and `null`
/// again after [clear].
final class _InMemorySettingsRepository implements SettingsRepository {
  PickerVisualSettings? _stored;

  @override
  Future<PickerVisualSettings?> load() async => _stored;

  @override
  Future<void> save(PickerVisualSettings settings) async {
    _stored = settings;
  }

  @override
  Future<void> clear() async {
    _stored = null;
  }
}

void main() {
  group('SettingsRepository contract', () {
    test('load returns null before anything is saved', () async {
      final repository = _InMemorySettingsRepository();
      expect(await repository.load(), isNull);
    });

    test('load returns the last saved settings atomically', () async {
      final repository = _InMemorySettingsRepository();
      const settings = PickerVisualSettings(startingIndex: 3);

      await repository.save(settings);

      expect(await repository.load(), settings);
    });

    test('save overwrites the previous value', () async {
      final repository = _InMemorySettingsRepository();
      await repository.save(const PickerVisualSettings(startingIndex: 1));
      await repository.save(const PickerVisualSettings(startingIndex: 2));

      expect(
        await repository.load(),
        const PickerVisualSettings(startingIndex: 2),
      );
    });

    test('clear makes load return null until the next save', () async {
      final repository = _InMemorySettingsRepository();
      await repository.save(const PickerVisualSettings());

      await repository.clear();

      expect(await repository.load(), isNull);
    });
  });
}
