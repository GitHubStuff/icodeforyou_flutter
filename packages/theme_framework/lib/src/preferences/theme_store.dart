// packages/theme_framework/lib/src/theme_store.dart

import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

const String _kThemeModeKey = 'theme_mode_unique_key_for_the_framework';

/// Reads the persisted [ThemeMode], defaulting to [ThemeMode.system].
final class ThemeStore {
  /// Creates a [ThemeStore] backed by [_prefs].
  const ThemeStore(this._prefs);

  final SharedPreferences _prefs;

  /// Returns the saved [ThemeMode], or [ThemeMode.system] when the value is
  /// absent or unrecognized. Decodes by [Enum.name], so reordering the enum
  /// never corrupts a stored value.
  ThemeMode read() {
    final stored = _prefs.getString(_kThemeModeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  /// Persists [mode] by its [Enum.name], recoverable via [read].
  Future<void> write(ThemeMode mode) =>
      _prefs.setString(_kThemeModeKey, mode.name);
}
