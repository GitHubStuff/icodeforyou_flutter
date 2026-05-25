// preferences/lib/src/abstract_preferences.dart

/// Abstract contract for an asynchronous key/value preferences store.
///
/// All operations are asynchronous to accommodate backends without an
/// in-memory cache (e.g. `SharedPreferencesAsync`). Backends with native
/// synchronous reads (e.g. `hive_ce`) wrap their results in completed
/// futures, which is effectively free.
abstract interface class AbstractPreferencesInterface {
  // ───── Reads ─────

  /// Returns the [String] stored under [key], or `null` if absent or
  /// the stored value is not a [String].
  Future<String?> getString(String key);

  /// Returns the [int] stored under [key], or `null` if absent or the
  /// stored value is not an [int].
  Future<int?> getInt(String key);

  /// Returns the [double] stored under [key], or `null` if absent or
  /// the stored value is not a [double].
  Future<double?> getDouble(String key);

  /// Returns the [bool] stored under [key], or `null` if absent or the
  /// stored value is not a [bool].
  Future<bool?> getBool(String key);

  /// Returns the `List<String>` stored under [key], or `null` if absent
  /// or the stored value is not a `List<String>`.
  Future<List<String>?> getStringList(String key);

  // ───── Writes ─────

  /// Persists [value] under [key]. Completes once the value has been
  /// written to the backing store.
  Future<void> setString(String key, String value);

  /// Persists [value] under [key]. Completes once the value has been
  /// written to the backing store.
  Future<void> setInt(String key, int value);

  /// Persists [value] under [key]. Completes once the value has been
  /// written to the backing store.
  Future<void> setDouble(String key, double value);

  /// Persists [value] under [key]. Completes once the value has been
  /// written to the backing store.
  Future<void> setBool(String key, bool value);

  /// Persists [value] under [key]. Completes once the value has been
  /// written to the backing store.
  Future<void> setStringList(String key, List<String> value);

  // ───── Structural ─────

  /// Removes the value stored under [key]. Completes once the entry
  /// has been removed from the backing store. No-op if [key] is absent.
  Future<void> remove(String key);

  /// Removes every entry from the backing store. Completes once the
  /// store has been cleared.
  Future<void> clear();

  /// Whether the backing store currently has a value under [key].
  Future<bool> contains(String key);
}
