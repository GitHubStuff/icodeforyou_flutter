// preferences/lib/src/hive/hive_preferences.dart
// ignore_for_file: always_use_package_imports, comment_references

import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../abstract_preferences_interface.dart';
import 'hive_init_mode.dart';

/// [Hive]-backed implementation of [AbstractPreferencesInterface].
///
/// Stores all values in a single dynamically-typed [Box]. The box name is
/// supplied at construction so multiple independent preference stores can
/// coexist within the same app.
///
/// Hive must be initialized once per app run via [HivePreferences.init]
/// before [create] is called.
///
/// Instances may be obtained two ways:
///  * [HivePreferences.create] — opens the box and returns a ready
///    instance. Recommended for normal use.
///  * [HivePreferences.new] — accepts an already-open [Box], primarily
///    for tests and dependency injection.
class HivePreferences implements AbstractPreferencesInterface {
  /// Wraps an already-open [box]. The caller owns the box's lifecycle.
  HivePreferences(this._box);

  /// Internal constructor used by [create] after [_box] has been opened.
  HivePreferences._(this._box);

  /// The underlying Hive box. Stores values keyed by [String].
  final Box<dynamic> _box;

  /// Whether [init] has already been called.
  static bool _initialized = false;

  /// Initializes Hive once per app run.
  ///
  /// [mode] selects the storage location:
  ///  * [HiveInitMode.test] — system temp directory, OS-reclaimed.
  ///  * [HiveInitMode.productionDocuments] — application documents
  ///    directory (backed up on iOS).
  ///  * [HiveInitMode.productionSupport] — application support directory
  ///    (not backed up on iOS).
  ///  * [HiveInitMode.custom] — caller-supplied [customPath].
  ///
  /// Asserts in debug if called more than once. In release, the second
  /// call returns immediately without re-initializing.
  static Future<void> init({
    required HiveInitMode mode,
    String? customPath,
  }) async {
    assert(!_initialized, 'HivePreferences.init() called more than once');
    if (_initialized) return;
    await _initImpl(mode: mode, customPath: customPath);
  }

  /// Resets the initialization flag. For tests only.
  @visibleForTesting
  static void resetForTesting() {
    _initialized = false;
  }

  /// Opens (or reuses) a Hive box named [boxName] and returns a ready
  /// [HivePreferences] instance.
  ///
  /// [HivePreferences.init] must be called before this factory.
  static Future<HivePreferences> create({required String boxName}) async {
    assert(
      _initialized,
      'HivePreferences.create() called before init()',
    );
    final box = await Hive.openBox<dynamic>(boxName);
    return HivePreferences._(box);
  }

  // ───── Reads ─────

  @override
  Future<String?> getString(String key) async => _read<String>(key);

  @override
  Future<int?> getInt(String key) async => _read<int>(key);

  @override
  Future<double?> getDouble(String key) async => _read<double>(key);

  @override
  Future<bool?> getBool(String key) async => _read<bool>(key);

  @override
  Future<List<String>?> getStringList(String key) async {
    final value = _box.get(key);
    if (value is List) {
      return value.cast<String>();
    }
    return null;
  }

  // ───── Writes ─────

  @override
  Future<void> setString(String key, String value) => _box.put(key, value);

  @override
  Future<void> setInt(String key, int value) => _box.put(key, value);

  @override
  Future<void> setDouble(String key, double value) => _box.put(key, value);

  @override
  Future<void> setBool(String key, bool value) => _box.put(key, value);

  @override
  Future<void> setStringList(String key, List<String> value) =>
      _box.put(key, List<String>.from(value));

  // ───── Structural ─────

  @override
  Future<void> remove(String key) => _box.delete(key);

  @override
  Future<void> clear() async {
    await _box.clear();
  }

  @override
  Future<bool> contains(String key) async => _box.containsKey(key);

  // ───── Internals ─────

  /// Performs the actual Hive initialization. Caller has already
  /// validated that initialization has not yet occurred.
  static Future<void> _initImpl({
    required HiveInitMode mode,
    String? customPath,
  }) async {
    final path = await _resolvePath(mode: mode, customPath: customPath);
    Hive.init(path);
    _initialized = true;
  }

  /// Resolves the storage directory for the given [mode].
  static Future<String> _resolvePath({
    required HiveInitMode mode,
    String? customPath,
  }) async {
    switch (mode) {
      case HiveInitMode.test:
        final dir = await Directory.systemTemp.createTemp('hive_test_');
        return dir.path;
      case HiveInitMode.productionDocuments:
        final dir = await getApplicationDocumentsDirectory();
        return p.join(dir.path, 'hive');
      case HiveInitMode.productionSupport:
        final dir = await getApplicationSupportDirectory();
        return p.join(dir.path, 'hive');
      case HiveInitMode.custom:
        assert(
          customPath != null,
          'HiveInitMode.custom requires customPath',
        );
        return customPath!;
    }
  }

  /// Returns [_box]'s value for [key] when assignable to [V], else `null`.
  V? _read<V>(String key) {
    final value = _box.get(key);
    return value is V ? value : null;
  }
}
