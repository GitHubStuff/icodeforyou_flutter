// packages/theme_framework/lib/src/storage/theme_mode_storage.dart

import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferencesAsync;
import 'package:theme_mode_cubit/src/theme_mode_storage_abstract.dart'
    show ThemeModeStorageAbstract;

/// Preference key. Private so no caller can come to depend on it.
const String _kThemeModeKey = 'theme_framework.theme_mode';

/// Returned by [ThemeModeStorage.read] when nothing valid is stored.
const ThemeMode _kFirstLaunchThemeMode = ThemeMode.system;

/// A [ThemeModeStorageAbstract] backed by `shared_preferences`.
///
/// Uses [SharedPreferencesAsync], so construction is synchronous and
/// nothing has to be awaited before the storage exists.
final class ThemeModeStorage implements ThemeModeStorageAbstract {
  /// Creates a [ThemeModeStorage].
  ///
  /// [prefs] exists for tests; production callers omit it.
  ThemeModeStorage({SharedPreferencesAsync? prefs})
    : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  /// Returns the persisted [ThemeMode], or [ThemeMode.system] when nothing
  /// valid is stored.
  ///
  /// Decodes by [Enum.name], so reordering [ThemeMode] never corrupts a
  /// value written by an earlier build. An absent key, and a name no longer
  /// present in [ThemeMode.values], both yield the first-launch default.
  @override
  Future<ThemeMode> read() async {
    final stored = await _prefs.getString(_kThemeModeKey);
    return ThemeMode.values.asNameMap()[stored] ?? _kFirstLaunchThemeMode;
  }

  /// Persists [newMode] by its [Enum.name], recoverable via [read].
  @override
  Future<void> write(ThemeMode newMode) =>
      _prefs.setString(_kThemeModeKey, newMode.name);
}
