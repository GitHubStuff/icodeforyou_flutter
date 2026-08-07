// packages/theme_framework/lib/src/preferences/theme_storage_abstract.dart

import 'package:flutter/material.dart' show ThemeMode;

/// Persists the user's selected [ThemeMode] across app launches.
///
/// Implement this to back the theme on any device store — `shared_preferences`,
/// `flutter_secure_storage`, Hive, Drift, or a remote profile. Consumers depend
/// on this type only; they never name a plugin.
///
/// Both members are asynchronous so backends that require real I/O satisfy the
/// contract without widening it.
///
/// Implementations must not throw, and must not substitute a default. [read]
/// reports only what is on the device; deciding what to show in its absence
/// belongs to the caller, because the framework uses two different defaults —
/// [ThemeMode.dark] while the splash is up, [ThemeMode.system] on a first
/// launch — and a storage returning either one could not serve the other.
abstract interface class ThemeStorageAbstract {
  /// Returns the persisted [ThemeMode], or `null` when nothing valid is stored.
  ///
  /// `null` covers both a first launch and a stored value that no longer maps
  /// to a [ThemeMode].
  Future<ThemeMode?> read();

  /// Persists [mode] so a subsequent [read] returns it.
  Future<void> write(ThemeMode mode);
}
