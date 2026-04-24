// theme_manager/lib/src/theme_persistence.dart
import 'dart:async' show FutureOr;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contract for persisting and restoring the user's [ThemeMode] selection.
///
/// Implementations abstract over the underlying storage mechanism so that
/// consumers (such as a theme cubit) can remain agnostic of whether the
/// choice is backed by shared preferences, a database, in-memory storage,
/// or a test double.
///
/// Both [load] and [save] return [FutureOr] to accommodate synchronous
/// backends (e.g. an already-initialized cache) as well as asynchronous
/// ones (e.g. a disk or network write).
abstract class ThemePersistenceAbstract {
  /// Returns the currently persisted [ThemeMode].
  ///
  /// Implementations should return a sensible default (such as
  /// [ThemeMode.dark] or [ThemeMode.system]) when no value has previously
  /// been stored or when the stored value cannot be parsed.
  FutureOr<ThemeMode> load();

  /// Persists [mode] as the user's current theme selection.
  ///
  /// Subsequent calls to [load] should return the most recently saved value.
  FutureOr<void> save(ThemeMode mode);
}

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
  final SharedPreferencesWithCache _prefs;

  /// Storage key under which the [ThemeMode.name] is persisted.
  ///
  /// The trailing numeric suffix namespaces the key to avoid collisions
  /// with any legacy or unrelated `theme_mode` entries that may exist in
  /// shared preferences from prior app versions or other packages.
  static const _key = 'theme_mode-317293440000';

  /// Asynchronously creates and initializes a [ThemePersistence] instance.
  ///
  /// Builds a [SharedPreferencesWithCache] whose cache allow-list contains
  /// only [_key], so only the theme preference is hydrated into memory.
  /// This is the only supported way to construct a [ThemePersistence].
  static Future<ThemePersistence> create() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(allowList: {_key}),
    );
    return ThemePersistence._(prefs);
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
  ThemeMode load() {
    final value = _prefs.getString(_key);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.dark,
    );
  }

  /// Persists [mode] by writing its [Enum.name] under [_key].
  ///
  /// The returned [Future] completes once the value has been written to
  /// the underlying shared-preferences store.
  @override
  Future<void> save(ThemeMode mode) => _prefs.setString(_key, mode.name);
}
