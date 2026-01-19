// packages/sqlite_viewer/lib/src/models/pragma_key.dart

/// Supported SQLite PRAGMA metadata queries.
///
/// Used with [SqliteViewerAbstract.getPragma] to retrieve
/// table structure information.
enum PragmaKey {
  /// Column metadata: name, type, nullable, default value, primary key.
  ///
  /// SQLite: `PRAGMA table_info("table_name")`
  ///
  /// Returns:
  /// ```dart
  /// [
  ///   {'cid': 0, 'name': 'id', 'type': 'INTEGER', 'notnull': 1, 'dflt_value': null, 'pk': 1},
  ///   {'cid': 1, 'name': 'title', 'type': 'TEXT', 'notnull': 0, 'dflt_value': null, 'pk': 0},
  /// ]
  /// ```
  tableInfo,

  /// Index metadata: name, uniqueness, origin.
  ///
  /// SQLite: `PRAGMA index_list("table_name")`
  ///
  /// Returns:
  /// ```dart
  /// [
  ///   {'seq': 0, 'name': 'idx_users_email', 'unique': 1, 'origin': 'c', 'partial': 0},
  /// ]
  /// ```
  indexList,

  /// Foreign key metadata: referenced table, columns, on update/delete actions.
  ///
  /// SQLite: `PRAGMA foreign_key_list("table_name")`
  ///
  /// Returns:
  /// ```dart
  /// [
  ///   {'id': 0, 'seq': 0, 'table': 'users', 'from': 'user_id', 'to': 'id', 'on_update': 'NO ACTION', 'on_delete': 'CASCADE', 'match': 'NONE'},
  /// ]
  /// ```
  foreignKeyList,
}
