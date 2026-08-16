// packages/infinite_scroll_picking_settings/test/src/settings/settings_loader_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/src/picker_visual_settings/picker_visual_settings.dart'
    show PickerVisualSettings;
import 'package:infinite_scroll_picking_settings/src/settings/settings_loader.dart'
    show SettingsLoader;
import 'package:infinite_scroll_picking_settings/src/settings/settings_repository.dart'
    show SettingsRepository;

/// Repository resolving to a canned value, or throwing when [error] is
/// non-null. Save and clear are unreachable from [SettingsLoader].
final class _FakeRepository implements SettingsRepository {
  /// Creates a repository whose [load] resolves to [stored] or throws
  /// [error] when provided.
  _FakeRepository({this.stored, this.error});

  /// Value returned by [load] when [error] is null.
  final PickerVisualSettings? stored;

  /// Error thrown by [load] when non-null.
  final Object? error;

  @override
  Future<PickerVisualSettings?> load() async {
    final failure = error;
    if (failure != null) throw failure;
    return stored;
  }

  @override
  Future<void> save(PickerVisualSettings settings) =>
      throw UnimplementedError();

  @override
  Future<void> clear() => throw UnimplementedError();
}

void main() {
  group('SettingsLoader', () {
    test('seeds the holder with the persisted settings', () async {
      const persisted = PickerVisualSettings(startingIndex: 6);
      final holder = await SettingsLoader.load(
        repository: _FakeRepository(stored: persisted),
      );
      addTearDown(holder.dispose);

      expect(holder.value, persisted);
    });

    test('seeds with defaults when nothing is persisted', () async {
      final holder = await SettingsLoader.load(
        repository: _FakeRepository(),
      );
      addTearDown(holder.dispose);

      expect(holder.value, const PickerVisualSettings());
    });

    test('seeds with defaults and swallows the error when the '
        'repository throws', () async {
      final holder = await SettingsLoader.load(
        repository: _FakeRepository(
          error: const FormatException('corrupt store'),
        ),
      );
      addTearDown(holder.dispose);

      expect(holder.value, const PickerVisualSettings());
    });
  });
}
