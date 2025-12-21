// icodeforyou_flutter/packages/since_when/lib/src/database/_database_initializer.dart

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:since_when/src/sql/_sql_statements.dart';
import 'package:sqflite/sqflite.dart';

/// Handles database initialization and table creation.
///
/// This class is internal and should not be exported publicly.
abstract final class DatabaseInitializer {
  /// Opens or creates a database at the specified path.
  ///
  /// Creates tables and indexes if they don't exist.
  /// Enables foreign key support.
  static Future<Database> openOrCreateDatabase(String dbName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDirectory.path, dbName);

    return openDatabase(
      dbPath,
      version: 1,
      onCreate: _createTables,
      onOpen: _onOpen,
    );
  }

  /// Opens or creates an in-memory database for testing.
  static Future<Database> openInMemoryDatabase() async {
    return openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: _createTables,
      onOpen: _onOpen,
    );
  }

  /// Creates all tables and indexes.
  static Future<void> _createTables(Database db, int version) async {
    await db.execute(SqlStatements.createTableSinceWhen);
    await db.execute(SqlStatements.createIndexCreatedTimeStamp);
    await db.execute(SqlStatements.createIndexParentTimeStamp);
    await db.execute(SqlStatements.createTableTags);
    await db.execute(SqlStatements.createIndexTag);
    await db.execute(SqlStatements.createIndexTagsCreatedTimeStamp);
  }

  /// Runs on every database open to enable foreign keys.
  static Future<void> _onOpen(Database db) async {
    await db.execute(SqlStatements.enableForeignKeys);
  }
}
