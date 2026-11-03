// packages/theme_mode_cubit/lib/src/theme_mode_storage_abstract.dart

import 'package:flutter/material.dart' show ThemeMode;

/// Abstract interface for persisting and retrieving the application's [ThemeMode].
///
/// Implement this class to store theme preferences in backends such as
/// `shared_preferences`, `hive`, or secure storage.
abstract class ThemeModeStorageAbstract {
  /// Reads the persisted [ThemeMode] from storage.
  ///
  /// Returns the saved [ThemeMode], or a fallback value if no preference
  /// has been saved yet.
  Future<ThemeMode> read();

  /// Persists the selected [newMode] to storage.
  ///
  /// Completes when the write operation has succeeded.
  Future<void> write(ThemeMode newMode);
}
