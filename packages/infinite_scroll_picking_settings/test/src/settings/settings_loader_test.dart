// infinite_scroll_picking_settings/test/src/settings/settings_loader_test.dart

// ignore_for_file: avoid_types_on_closure_parameters

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/infinite_scroll_picking_settings.dart';

class _StubRepo implements SettingsRepository {
  _StubRepo({this.loadResult, this.loadError});

  final PickerVisualSettings? loadResult;
  final Object? loadError;

  @override
  Future<PickerVisualSettings?> load() async {
    if (loadError != null) throw loadError!;
    return loadResult;
  }

  @override
  Future<void> save(PickerVisualSettings settings) async {}

  @override
  Future<void> clear() async {}
}

class _SyncThrowingRepo implements SettingsRepository {
  // Throws synchronously from load() — exercises the catch path when
  // repository.load() itself raises before returning a Future.
  @override
  Future<PickerVisualSettings?> load() {
    throw StateError('synchronous boom');
  }

  @override
  Future<void> save(PickerVisualSettings settings) async {}

  @override
  Future<void> clear() async {}
}

/// Runs [body] with `debugPrint` silenced. Restores the original handler
/// after the body completes, even on failure.
Future<T> _silentDebugPrint<T>(Future<T> Function() body) async {
  final original = debugPrint;
  debugPrint = (String? _, {int? wrapWidth}) {};
  try {
    return await body();
  } finally {
    debugPrint = original;
  }
}

void main() {
  group('SettingsLoader.load', () {
    test('seeds the holder with the loaded settings when present', () async {
      const stored = PickerVisualSettings(startingIndex: 7);
      final holder = await SettingsLoader.load(
        repository: _StubRepo(loadResult: stored),
      );

      expect(holder, isA<SettingsHolder>());
      expect(holder.value, stored);
    });

    test(
      'seeds the holder with defaults when the repo returns null',
      () async {
        final holder = await SettingsLoader.load(
          repository: _StubRepo(),
        );

        expect(holder.value, const PickerVisualSettings());
      },
    );

    test(
      'falls back to defaults when the repo throws asynchronously',
      () async {
        final holder = await _silentDebugPrint(
          () => SettingsLoader.load(
            repository: _StubRepo(loadError: Exception('decode failure')),
          ),
        );

        expect(holder.value, const PickerVisualSettings());
      },
    );

    test(
      'falls back to defaults when the repo throws synchronously',
      () async {
        final holder = await _silentDebugPrint(
          () => SettingsLoader.load(
            repository: _SyncThrowingRepo(),
          ),
        );

        expect(holder.value, const PickerVisualSettings());
      },
    );
  });
}
