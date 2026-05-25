// app_preferences/lib/src/mock/mock_preferences.dart
// ignore_for_file: always_use_package_imports, comment_references

import 'package:meta/meta.dart';

import '../abstract_preferences_interface.dart';

/// In-memory implementation of [AbstractPreferencesInterface] for tests and dev.
///
/// Stores values in a `Map<String, Object?>`. Type checks on read mirror
/// the contract of the real backends — a value stored as `int` returns
/// `null` from [getString], etc.
///
/// Construct with [initialValues] to pre-populate. Use [reset] to wipe
/// state between tests, [snapshot] for assertion-friendly copies, and
/// [peek] for direct lookup without type filtering.
class MockPreferences implements AbstractPreferencesInterface {
  /// Creates a mock store, optionally seeded with [initialValues].
  MockPreferences({Map<String, Object?>? initialValues})
    : _store = {...?initialValues};

  /// Backing store. Keys are preference names; values are the
  /// primitives accepted by [AbstractPreferencesInterface].
  final Map<String, Object?> _store;

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
    final value = _store[key];
    if (value is List) {
      return List<String>.unmodifiable(value.cast<String>());
    }
    return null;
  }

  // ───── Writes ─────

  @override
  Future<void> setString(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _store[key] = value;
  }

  @override
  Future<void> setDouble(String key, double value) async {
    _store[key] = value;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _store[key] = value;
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    _store[key] = List<String>.from(value);
  }

  // ───── Structural ─────

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }

  @override
  Future<bool> contains(String key) async => _store.containsKey(key);

  // ───── Test helpers ─────

  /// Wipes the store. Synchronous to keep test setup terse.
  @visibleForTesting
  void reset() => _store.clear();

  /// Returns an unmodifiable copy of the current store. Use in
  /// assertions where you want to inspect the entire state.
  @visibleForTesting
  Map<String, Object?> snapshot() => Map<String, Object?>.unmodifiable(_store);

  /// Returns the raw value for [key] without type filtering.
  /// Useful when a test wants to assert the stored type itself.
  @visibleForTesting
  Object? peek(String key) => _store[key];

  // ───── Internals ─────

  /// Returns the value for [key] when assignable to [V], else `null`.
  V? _read<V>(String key) {
    final value = _store[key];
    return value is V ? value : null;
  }
}
