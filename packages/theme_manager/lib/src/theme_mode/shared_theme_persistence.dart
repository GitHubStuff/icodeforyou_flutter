import 'package:flutter/material.dart';
import 'package:my_logger/my_logger.dart' show MyLogger;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferencesWithCache, SharedPreferencesWithCacheOptions;
import 'package:theme_manager/src/theme_mode/theme_persistence_abstract.dart'
    show ThemePersistenceAbstract;

/// [SharedPreferencesWithCache]-backed implementation of
/// [ThemePersistenceAbstract].
///
// ignore: comment_references
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
class SharedThemePersistence extends ThemePersistenceAbstract {
  /// Private constructor used by [create] after [_prefs] has been
  /// initialized.
  SharedThemePersistence._(this._prefs);

  /// Cached shared-preferences handle scoped to [_key].
  final SharedPreferencesWithCache _prefs;

  ///
  // ignore: comment_references
  /// Storage key under which the [ThemeMode.name] is persisted.
  ///
  /// The trailing numeric suffix namespaces the key to avoid collisions
  /// with any legacy or unrelated `theme_mode` entries that may exist in
  /// shared preferences from prior app versions or other packages.
  static const _key = 'theme_mode-317293440000';

  /// Asynchronously creates and initializes a [SharedThemePersistence] instance
  ///
  /// Builds a [SharedPreferencesWithCache] whose cache allow-list contains
  /// only [_key], so only the theme preference is hydrated into memory.
  /// This is the only supported way to construct a [SharedThemePersistence].
  static Future<SharedThemePersistence> create() async {
    final stopWatch = Stopwatch()..start();
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(allowList: {_key}),
    );
    stopWatch.stop();
    MyLogger.d(
      'SharedPreferencesWithCache.create() took '
      '${stopWatch.elapsed.inMicroseconds / 1000} ms',
    );
    return SharedThemePersistence._(prefs);
  }

  /// Returns the persisted [ThemeMode], defaulting to [ThemeMode.dark].
  ///
  /// Reads the stored string via the cached preferences handle and matches
  // ignore: comment_references
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

  ///
  // ignore: comment_references
  /// Persists [mode] by writing its [Enum.name] under [_key].
  ///
  /// The returned [Future] completes once the value has been written to
  /// the underlying shared-preferences store.
  @override
  Future<void> save(ThemeMode mode) => _prefs.setString(_key, mode.name);
}
