// infinite_scroll_picking_settings/lib/src/settings/settings_repository.dart

// ignore_for_file: always_use_package_imports

import '../picker_visual_settings/picker_visual_settings.dart';

/// Persistence boundary for the picker's visual settings.
///
/// The settings cubit depends only on this interface; concrete
/// implementations (shared_preferences, Hive, a file, an HTTP service, an
/// in-memory fake for tests) live elsewhere and are wired in via the
/// service locator. This is the DIP seam that keeps the settings layer
/// free of any storage-technology choice.
///
/// Implementations should treat the visual settings as a single atomic
/// preference. Splitting `wheel` and the surrounding frame fields into
/// separate keys risks torn state when one half saves and the other
/// fails — both go together or neither does.
abstract interface class SettingsRepository {
  /// Loads the persisted settings, or `null` if none have been saved yet.
  /// A `null` return signals "no preference on disk — fall back to the
  /// default `PickerVisualSettings()`."
  ///
  /// Implementations should throw on genuine I/O failures (corrupt JSON,
  /// permission denied, etc.) so the cubit can surface a `SettingsError`
  /// state. Returning `null` for "missing" and throwing for "broken"
  /// keeps the two cases distinguishable upstream.
  Future<PickerVisualSettings?> load();

  /// Persists [settings], overwriting any previous value. Atomic with
  /// respect to a single visual-settings preference — implementations
  /// must not leave the store in a half-written state if the underlying
  /// medium fails mid-write.
  Future<void> save(PickerVisualSettings settings);

  /// Removes any persisted settings. After this completes, [load] returns
  /// `null` until the next [save].
  Future<void> clear();
}
