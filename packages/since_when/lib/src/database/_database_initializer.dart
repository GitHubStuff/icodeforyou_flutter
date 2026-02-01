// lib/src/database/_database_initializer.dart

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:since_when/src/sql/_sql_statements.dart';
import 'package:sqflite/sqflite.dart';

/// Result of database initialization containing the database and its path.
class DatabaseInitResult {
  /// Creates a [DatabaseInitResult].
  const DatabaseInitResult({
    required this.database,
    required this.fullPath,
  });

  /// The opened database instance.
  final Database database;

  /// Full path to the database file.
  final String fullPath;
}

/// Handles database initialization and table creation.
///
/// This class is internal and should not be exported publicly.
abstract final class DatabaseInitializer {
  /// Opens or creates a database at the specified path.
  ///
  /// The [dbPath] is a subfolder within the documents directory.
  /// The [dbName] is the database filename.
  ///
  /// Creates the subfolder if it doesn't exist.
  /// Creates tables and indexes if they don't exist.
  /// Enables foreign key support.
  ///
  /// Returns [DatabaseInitResult] containing the database and full path.
  ///
  /// Throws [ArgumentError] if [dbName] is empty.
  /// Throws [FileSystemException] if folder creation fails.
  static Future<DatabaseInitResult> openOrCreateDatabase({
    required String dbName,
    required String dbPath,
  }) async {
    // Validate dbName
    final trimmedName = dbName.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(
        dbName,
        'dbName',
        'Database name cannot be empty',
      );
    }

    // Normalize dbPath (remove leading/trailing slashes)
    final normalizedPath = _normalizePath(dbPath);

    // Get documents directory
    final documentsDirectory = await getApplicationDocumentsDirectory();

    // Build full directory path
    final directoryPath = normalizedPath.isEmpty
        ? documentsDirectory.path
        : p.join(documentsDirectory.path, normalizedPath);

    // Create directory if it doesn't exist
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    // Build full database path
    final fullPath = p.join(directoryPath, trimmedName);

    // Open or create database
    final database = await openDatabase(
      fullPath,
      version: 1,
      onCreate: _createTables,
      onOpen: _onOpen,
    );

    return DatabaseInitResult(
      database: database,
      fullPath: fullPath,
    );
  }

  /// Opens or creates an in-memory database for testing.
  ///
  /// Returns [DatabaseInitResult] with ':memory:' as the path.
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

  /// Normalizes a path by removing leading/trailing slashes and whitespace.
  static String _normalizePath(String path) {
    var normalized = path.trim();

    // Remove leading slashes
    while (normalized.startsWith('/') || normalized.startsWith(r'\')) {
      normalized = normalized.substring(1);
    }

    // Remove trailing slashes
    while (normalized.endsWith('/') || normalized.endsWith(r'\')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    return normalized;
  }

  /// Creates all tables and indexes.
  static Future<void> _createTables(Database db, int version) async {
    // Main records table
    await db.execute(SqlStatements.createTableSinceWhen);
    await db.execute(SqlStatements.createIndexCreatedTimeStamp);
    await db.execute(SqlStatements.createIndexParentTimeStamp);

    // Tag glossary table
    await db.execute(SqlStatements.createTableTagGlossary);
    await db.execute(SqlStatements.createIndexTagName);
    await db.execute(SqlStatements.createIndexGlossaryTimestamp);

    // Junction table
    await db.execute(SqlStatements.createTableTags);
    await db.execute(SqlStatements.createIndexTagsRecordTimestamp);
    await db.execute(SqlStatements.createIndexTagsGlossaryTimestamp);
  }

  /// Runs on every database open to enable foreign keys.
  static Future<void> _onOpen(Database db) async {
    await db.execute(SqlStatements.enableForeignKeys);
  }
}
