// ignore_for_file: comment_references

import 'package:app_preferences/app_preferences.dart'
    show AbstractPreferencesInterface;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferencesWithCache;
import 'package:theme_manager/src/theme_mode/theme_persistence_abstract.dart'
    show ThemePersistenceAbstract;

/// [SharedPreferencesWithCache]-backed implementation of
/// [ThemePersistenceAbstract].
///
/// Stores the selected [ThemeMode] as its [Enum.name] under a namespaced
/// key so it can be restored across app launches. The cache is scoped to
/// only the theme key via an allow-list, keeping reads fast and avoiding
/// unnecessary hydration of unrelated preferences.
///
/// Instances must be obtained through the asynchronous [create] factory,
/// which initializes the underlying [SharedPreferencesWithCache] before
/// returning a ready-to-use persistence object.
///
/// Example:
///
/// ```dart
/// final persistence = await ThemePersistence.create();
/// final mode = persistence.load();
/// await persistence.save(ThemeMode.light);
/// ```
class ThemePersistence extends ThemePersistenceAbstract {
  /// Private constructor used by [create] after [_prefs] has been
  /// initialized.
  ThemePersistence._(this._prefs);

  /// Cached shared-preferences handle scoped to [_key].
  final AbstractPreferencesInterface _prefs;

  ///
  /// Storage key under which the [ThemeMode.name] is persisted.
  ///
  /// The trailing numeric suffix namespaces the key to avoid collisions
  /// with any legacy or unrelated `theme_mode` entries that may exist in
  /// shared preferences from prior app versions or other packages.
  static const _key = 'theme_mode-317293440000';

  /// Asynchronously creates and initializes a [ThemePersistence] instance
  ///
  /// Builds a [SharedPreferencesWithCache] whose cache allow-list contains
  /// only [_key], so only the theme preference is hydrated into memory.
  /// This is the only supported way to construct a [ThemePersistence].
  static Future<ThemePersistence> create(
    AbstractPreferencesInterface preference,
  ) async {
    return ThemePersistence._(preference);
  }

  /// Returns the persisted [ThemeMode], defaulting to [ThemeMode.dark].
  ///
  /// Reads the stored string via the cached preferences handle and matches
  /// it against [ThemeMode.values] by [Enum.name]. If no value is present
  /// or the stored value does not correspond to a known mode (for example,
  /// after an enum rename), [ThemeMode.dark] is returned.
  ///
  /// This method is synchronous because [SharedPreferencesWithCache]
  /// serves the value directly from its in-memory cache.
  @override
  Future<ThemeMode> load() async {
    final value = await _prefs.getString(_key);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.dark,
    );
  }

  ///
  /// Persists [mode] by writing its [Enum.name] under [_key].
  ///
  /// The returned [Future] completes once the value has been written to
  /// the underlying shared-preferences store.
  @override
  Future<void> save(ThemeMode mode) => _prefs.setString(_key, mode.name);
}
