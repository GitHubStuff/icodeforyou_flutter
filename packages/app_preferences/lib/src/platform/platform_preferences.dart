// preferences/lib/src/platform_preferences.dart
// ignore_for_file: comment_references, always_use_package_imports

import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferencesAsync;

import '../abstract_preferences_interface.dart';

/// Platform-native implementation of [AbstractPreferencesInterface].
///
/// Routes every operation through [SharedPreferencesAsync], which writes
/// to the underlying platform store (NSUserDefaults on iOS/macOS,
/// SharedPreferences on Android, IndexedDB on web). There is no
/// in-memory cache — every call crosses the platform channel.
///
/// Suitable for low-frequency reads and writes. For hot read paths,
/// prefer a cached implementation.
///
/// Instances may be obtained two ways:
///  * [PlatformPreferences.create] — convenience factory, returns a
///    ready instance. Recommended for normal use.
///  * [PlatformPreferences.new] — accepts an injected
///    [SharedPreferencesAsync], primarily for tests and dependency
///    injection.
class PlatformPreferences implements AbstractPreferencesInterface {
  /// Wraps an injected [prefs]. The caller owns its lifecycle.
  PlatformPreferences(this._prefs);

  /// Internal constructor used by [create].
  PlatformPreferences._(this._prefs);

  /// Underlying async preferences handle.
  final SharedPreferencesAsync _prefs;

  /// Returns a ready [PlatformPreferences] instance backed by a fresh
  /// [SharedPreferencesAsync].
  ///
  /// `SharedPreferencesAsync` requires no async setup itself — this
  /// factory exists for symmetry with other [AbstractPreferencesInterface]
  /// implementations and to leave room for future initialization.
  static Future<PlatformPreferences> create() async {
    return PlatformPreferences._(SharedPreferencesAsync());
  }

  // ───── Reads ─────

  @override
  Future<String?> getString(String key) => _prefs.getString(key);

  @override
  Future<int?> getInt(String key) => _prefs.getInt(key);

  @override
  Future<double?> getDouble(String key) => _prefs.getDouble(key);

  @override
  Future<bool?> getBool(String key) => _prefs.getBool(key);

  @override
  Future<List<String>?> getStringList(String key) => _prefs.getStringList(key);

  // ───── Writes ─────

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  Future<void> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  // ───── Structural ─────

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> clear() => _prefs.clear();

  @override
  Future<bool> contains(String key) => _prefs.containsKey(key);
}
