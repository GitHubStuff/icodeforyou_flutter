// packages/theme_framework/lib/src/preferences/shared_preferences_theme_storage.dart

import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_framework/src/preferences/theme_storage_abstract.dart';

const String _kThemeModeKey = 'theme_framework.theme_mode';

/// A [ThemeStorageAbstract] backed by `shared_preferences`.
///
/// Suitable for a non-sensitive display preference. The storage key is private
/// to this adapter, so no caller can come to depend on it.
/// _prefs is passed as a parameter because it created with an awat
final class SharedPreferencesThemeStorage implements ThemeStorageAbstract {
  /// Creates a [SharedPreferencesThemeStorage] backed by [prefs].
  const SharedPreferencesThemeStorage(this._prefs);

  final SharedPreferences _prefs;

  /// Returns the persisted [ThemeMode], or `null` when nothing valid is stored.
  ///
  /// Decodes by [Enum.name], so reordering [ThemeMode] never corrupts a value
  /// written by an earlier build. An absent key, and a name no longer present
  /// in [ThemeMode.values], both decode to `null`.
  @override
  Future<ThemeMode?> read() async {
    final stored = _prefs.getString(_kThemeModeKey);

    for (final mode in ThemeMode.values) {
      if (mode.name == stored) return mode;
    }
    return null;
  }

  /// Persists [mode] by its [Enum.name], recoverable via [read].
  @override
  Future<void> write(ThemeMode mode) async {
    await _prefs.setString(_kThemeModeKey, mode.name);
  }
}
