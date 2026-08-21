// packages/infinite_scroll_picking_settings/lib/src/settings/settings_loader.dart

import 'dart:async' show FutureOr;

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:infinite_scroll_picking_settings/infinite_scroll_picking_settings.dart'
    show PickerVisualSettings, SettingsHolder, SettingsRepository;

/// Sink for [SettingsLoader] diagnostics.
///
/// Production defaults to [debugPrint] gated behind [kDebugMode]; tests
/// inject a silent or recording sink so passing tests stay quiet and the
/// fallback log becomes assertable.
typedef SettingsLoaderLog = void Function(String message);

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
///   → logs via [SettingsLoaderLog] (default: [debugPrint] in debug mode
///     only), seeds with defaults, swallows the error.
///
/// Callers needing custom error handling (telemetry, user-visible recovery
/// UI, forced reset) should call [SettingsRepository.load] directly and
/// construct the holder themselves.
abstract final class SettingsLoader {
  /// Reads persisted settings via [repository] and returns a
  /// [SettingsHolder] seeded with the loaded value, or
  /// [PickerVisualSettings.new] defaults if nothing is persisted or the
  /// load fails.
  ///
  /// [repository.load] may be sync or async — both are awaited via
  /// [FutureOr] so callers can pass any [SettingsRepository] shape.
  ///
  /// [log] receives the diagnostic message when the repository throws.
  /// When `null`, falls back to [debugPrint] in debug mode and silence in
  /// release mode. Inject a custom sink for telemetry or to keep test
  /// output silent.
  static Future<SettingsHolder> load({
    required SettingsRepository repository,
    SettingsLoaderLog? log,
  }) async {
    final loaded = await _safeLoad(repository, log ?? _defaultLog);
    return SettingsHolder(loaded ?? const PickerVisualSettings());
  }

  static void _defaultLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  static Future<PickerVisualSettings?> _safeLoad(
    SettingsRepository repository,
    SettingsLoaderLog log,
  ) async {
    try {
      // Reads better.
      // ignore: unnecessary_nullable_for_final_variable_declarations
      final FutureOr<PickerVisualSettings?> result = repository.load();
      return await Future.value(result);
      // Startup must survive any failure shape; intentional blanket catch.
      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      log(
        'SettingsLoader: repository.load() failed, falling back to '
        'defaults. Error: $error\n$stackTrace',
      );
      return null;
    }
  }
}
