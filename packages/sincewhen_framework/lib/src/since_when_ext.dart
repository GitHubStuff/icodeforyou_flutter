// packages/sincewhen_framework/lib/src/since_when_ext.dart
part of 'since_when.dart';

/// Convenience operations on [SinceWhen] that expose controlled slices of
/// the underlying drift database without leaking the database object itself.
///
/// Lives in a `part` file so it can reach the private `_db` field while
/// keeping [SinceWhen]'s public class definition uncluttered.
extension SinceWhenExt on SinceWhen {
  /// Runs a raw SQL SELECT and returns each row as a column-name → value map.
  ///
  /// Values are the raw SQLite representations (`int`, `double`, `String`,
  /// `Uint8List`, or `null`); no type mapping or converters are applied.
  ///
  /// Dynamic values must be passed via [variables], never interpolated into
  /// [query]. Each `?` placeholder in [query] is bound positionally to the
  /// corresponding entry in [variables], which eliminates SQL injection for
  /// value positions:
  ///
  /// ```dart
  /// final rows = await db.select(
  ///   query: 'SELECT * FROM events WHERE tag = ? AND created_at > ?',
  ///   variables: [tag, cutoffMillis],
  /// );
  /// ```
  ///
  /// Placeholders bind values only — table and column names cannot be
  /// parameterized in SQL, so [query] itself must still come from trusted
  /// code, never from user input. Intended for diagnostics and
  /// database-viewer tooling; use the typed drift API for application
  /// queries.
  ///
  /// The returned list is an independent snapshot: mutating it does not
  /// affect the database, and it does not update when the database changes.
  ///
  /// Throws a drift/SQLite exception if [query] is not valid SQL, references
  /// tables or columns that do not exist, or if the number of placeholders
  /// does not match the length of [variables].
  Future<List<Map<String, Object?>>> select({
    required String query,
    List<Object?> variables = const <Object?>[],
  }) async {
    final rows = await _db
        .customSelect(
          query,
          variables: variables.map(Variable<Object>.new).toList(),
        )
        .get();
    return rows.map((row) => row.data).toList();
  }

  /// Closes the underlying database connection.
  ///
  /// After this completes, the [SinceWhen] instance is unusable: any further
  /// query on it throws. Closing is permanent for this instance — create a
  /// new [SinceWhen] to reopen the database. Safe to call once during
  /// teardown; drift ignores redundant close calls on an already-closed
  /// database.
  Future<void> close() => _db.close();
}
