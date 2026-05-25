// infinite_scroll_picking_settings/lib/src/settings/settings_loader.dart

// ignore_for_file: comment_references, always_use_package_imports

import 'dart:async' show FutureOr;

import 'package:flutter/foundation.dart' show debugPrint;

import '../picker_visual_settings/picker_visual_settings.dart';
import 'settings_holder.dart';
import 'settings_repository.dart';

/// Eager startup loader for the app-wide [SettingsHolder].
///
/// Call [load] once during app bootstrap (before `runApp`) to read persisted
/// settings from the supplied [SettingsRepository] and return a seeded
/// [SettingsHolder]. Wrap your app with `SettingsScope(holder: holder, ...)`
/// so every picker can read the current settings from first frame.
///
/// Failure modes are handled silently and fall back to defaults so a
/// corrupted or unreadable store never blocks app startup:
///
/// - Repository returns `null` (no settings persisted yet — first launch)
///   → seeds with [PickerVisualSettings.new] defaults.
/// - Repository throws (decode error, I/O failure, schema drift)
///   → logs via [debugPrint], seeds with defaults, swallows the error.
///
/// Callers needing custom error handling (telemetry, user-visible recovery
/// UI, forced reset) should call [SettingsRepository.load] directly and
/// construct the holder themselves.
abstract final class SettingsLoader {
  /// Reads persisted settings via [repository] and returns a [SettingsHolder]
  /// seeded with the loaded value, or [PickerVisualSettings.new] defaults if
  /// nothing is persisted or the load fails.
  ///
  /// [repository.load] may be sync or async — both are awaited via
  /// [FutureOr] so callers can pass any [SettingsRepository] shape.
  static Future<SettingsHolder> load({
    required SettingsRepository repository,
  }) async {
    final loaded = await _safeLoad(repository);
    return SettingsHolder(loaded ?? const PickerVisualSettings());
  }

  static Future<PickerVisualSettings?> _safeLoad(
    SettingsRepository repository,
  ) async {
    try {
      // Reads better.
      // ignore: unnecessary_nullable_for_final_variable_declarations
      final FutureOr<PickerVisualSettings?> result = repository.load();
      return await Future.value(result);
    }
    // ignore: avoid_catches_without_on_clauses
    catch (error, stackTrace) {
      debugPrint(
        'SettingsLoader: repository.load() failed, falling back to '
        'defaults. Error: $error\n$stackTrace',
      );
      return null;
    }
  }
}
