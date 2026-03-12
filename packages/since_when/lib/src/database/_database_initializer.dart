// lib/src/database/_database_initializer.dart

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

part '../sql/_sql_statements.dart';

class DatabaseInitResult {
  const DatabaseInitResult({
    required this.database,
    required this.fullPath,
  });

  final Database database;
  final String fullPath;
}

abstract final class DatabaseInitializer {
  static Future<String> resolveFullPath({
    required String dbName,
    required String dbPath,
  }) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final normalizedPath = _normalizePath(dbPath);

    final directoryPath = normalizedPath.isEmpty
        ? documentsDirectory.path
        : p.join(documentsDirectory.path, normalizedPath);

    return p.join(directoryPath, dbName.trim());
  }

  static Future<DatabaseInitResult> openOrCreateDatabase({
    required String dbName,
    required String dbPath,
  }) async {
    final fullPath = await resolveFullPath(dbName: dbName, dbPath: dbPath);

    final directory = Directory(p.dirname(fullPath));
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    final database = await openDatabase(
      fullPath,
      version: 1,
      onCreate: _createTables,
      onOpen: _onOpen,
    );

    return DatabaseInitResult(database: database, fullPath: fullPath);
  }

  static Future<DatabaseInitResult> openInMemoryDatabase() async {
    final database = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: _createTables,
      onOpen: _onOpen,
    );

    return DatabaseInitResult(
      database: database,
      fullPath: inMemoryDatabasePath,
    );
  }

  static String _normalizePath(String path) {
    var normalized = path.trim();
    while (normalized.startsWith('/') || normalized.startsWith(r'\')) {
      normalized = normalized.substring(1);
    }
    while (normalized.endsWith('/') || normalized.endsWith(r'\')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute(SqlStatements._createTableSinceWhen);
    await db.execute(SqlStatements._createIndexCreatedTimeStamp);
    await db.execute(SqlStatements._createIndexParentTimeStamp);

    await db.execute(SqlStatements._createTableTagGlossary);
    await db.execute(SqlStatements._createIndexTagName);
    await db.execute(SqlStatements._createIndexGlossaryTimestamp);

    await db.execute(SqlStatements._createTableTags);
    await db.execute(SqlStatements._createIndexTagsRecordTimestamp);
    await db.execute(SqlStatements._createIndexTagsGlossaryTimestamp);

    await db.execute(SqlStatements._createTableLog);
    await db.execute(SqlStatements._createIndexLogTimeStamp);
    await db.execute(SqlStatements._createIndexLogAction);
  }

  static Future<void> _onOpen(Database db) async {
    await db.execute(SqlStatements._enableForeignKeys);
  }
}
