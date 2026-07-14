// packages/sincewhen_framework/lib/src/since_when.dart

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:sincewhen_framework/src/database/executor/open_executor.dart'
    show openExecutor;
import 'package:sincewhen_framework/src/sql/table_names.dart' show TableNames;
import 'package:sincewhen_framework/src/sql/tables/create_tables.dart'
    show createTableStatements;

part 'since_when_ext.dart';

/// Gateway to the SinceWhen database.
///
/// Instances are only obtainable via [open] or [openInMemory]; by the
/// time you hold one, the connection is live and all core tables exist.
class SinceWhen {
  SinceWhen._(this._db);

  final _SinceWhenDb _db;

  /// Fixed filename used for file-backed storage.
  static const String fileName = 'SinceWhen.db';

  /// Opens (creating if necessary) the database at `directory/SinceWhen.db`,
  /// creates the core tables, then runs each statement in [addTables].
  ///
  /// [directory] must be a persistent location such as
  /// `getApplicationSupportDirectory()` — not a cache or temp directory.
  static Future<SinceWhen> open({
    required String directory,
    List<String> addTables = const [],
  }) {
    return _open(
      executor: openExecutor(path: p.join(directory, fileName)),
      addTables: addTables,
    );
  }

  /// Opens a volatile in-memory database. Contents are lost on [close].
  static Future<SinceWhen> openInMemory({
    List<String> addTables = const [],
  }) {
    return _open(
      executor: openExecutor(inMemory: true),
      addTables: addTables,
    );
  }

  static Future<SinceWhen> _open({
    required QueryExecutor executor,
    required List<String> addTables,
  }) async {
    _validateAddTables(addTables);

    final db = _SinceWhenDb(executor);
    try {
      await db.customStatement('PRAGMA foreign_keys = ON');

      await db.transaction(() async {
        for (final ddl in [...createTableStatements, ...addTables]) {
          await db.customStatement(ddl);
        }
      });
    } catch (e) {
      await db.close();
      rethrow;
    }

    return SinceWhen._(db);
  }

  /// Rejects non-CREATE statements and any attempt to (re)define a
  /// core table.
  static void _validateAddTables(List<String> statements) {
    final createTable = RegExp(
      r'^\s*CREATE\s+TABLE\s+(IF\s+NOT\s+EXISTS\s+)?[`"\[]?(\w+)',
      caseSensitive: false,
    );
    final coreNames = TableNames.values
        .map((t) => t.name.toLowerCase())
        .toSet();

    for (final sql in statements) {
      final match = createTable.firstMatch(sql);
      if (match == null) {
        throw ArgumentError(
          'addTables only accepts CREATE TABLE statements. Rejected:\n$sql',
        );
      }
      final tableName = match.group(2)!.toLowerCase();
      if (coreNames.contains(tableName)) {
        throw ArgumentError(
          '"$tableName" is a core SinceWhen table and cannot be redefined.',
        );
      }
    }
  }
}

/// Minimal drift database used purely as a cross-platform SQL executor;
/// the schema is managed by raw DDL in `_open`, not by drift codegen.
class _SinceWhenDb extends GeneratedDatabase {
  _SinceWhenDb(super.executor);

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => const [];

  @override
  int get schemaVersion => 1;

  // DDL handled in _open
  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (_) async {});
}
