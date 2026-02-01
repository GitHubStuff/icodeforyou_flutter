// packages/sqlite_viewer/lib/src/models/database_metadata.dart

import 'package:equatable/equatable.dart';

/// Metadata about a connected SQLite database.
///
/// Holds information retrieved when connecting to a database source.
/// Used by 'SqliteViewerState' to preserve metadata across state transitions.
///
/// Example:
/// ```dart
/// final metadata = DatabaseMetadata(
///   fullPath: '/data/user/0/com.example/databases/app.db',
///   sqliteVersion: '3.39.0',
///   databaseSize: 524288,
///   tables: ['users', 'posts', 'comments'],
/// );
///
/// print(metadata.formattedSize); // '512.00 KB'
/// print(metadata.isInMemory);    // false
/// ```
class DatabaseMetadata extends Equatable {
  /// Creates a [DatabaseMetadata] with the given properties.
  const DatabaseMetadata({
    required this.fullPath,
    required this.sqliteVersion,
    required this.databaseSize,
    required this.tables,
  });

  /// Full path to the database file.
  ///
  /// For in-memory databases, this is ':memory:'.
  final String fullPath;

  /// SQLite version string (e.g., '3.39.0').
  final String sqliteVersion;

  /// Database size in bytes.
  final int databaseSize;

  /// List of user table names (excludes sqlite_* tables).
  final List<String> tables;

  /// Token used to identify in-memory databases.
  static const String inMemoryToken = ':memory:';

  /// Returns true if this is an in-memory database.
  bool get isInMemory => fullPath == inMemoryToken;

  /// Returns the number of tables in the database.
  int get tableCount => tables.length;

  /// Returns the database filename without path.
  ///
  /// For in-memory databases, returns ':memory:'.
  String get filename {
    if (isInMemory) return inMemoryToken;
    final lastSeparator = fullPath.lastIndexOf('/');
    if (lastSeparator == -1) return fullPath;
    return fullPath.substring(lastSeparator + 1);
  }

  /// Returns the database size formatted as human-readable string.
  ///
  /// Examples: '1.23 KB', '45.67 MB', '512 B'
  String get formattedSize {
    if (databaseSize < 1024) {
      return '$databaseSize B';
    } else if (databaseSize < 1024 * 1024) {
      return '${(databaseSize / 1024).toStringAsFixed(2)} KB';
    } else if (databaseSize < 1024 * 1024 * 1024) {
      return '${(databaseSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(databaseSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Creates a copy with updated fields.
  DatabaseMetadata copyWith({
    String? fullPath,
    String? sqliteVersion,
    int? databaseSize,
    List<String>? tables,
  }) {
    return DatabaseMetadata(
      fullPath: fullPath ?? this.fullPath,
      sqliteVersion: sqliteVersion ?? this.sqliteVersion,
      databaseSize: databaseSize ?? this.databaseSize,
      tables: tables ?? this.tables,
    );
  }

  @override
  List<Object?> get props => [fullPath, sqliteVersion, databaseSize, tables];

  @override
  String toString() {
    return 'DatabaseMetadata('
        'fullPath: $fullPath, '
        'sqliteVersion: $sqliteVersion, '
        'databaseSize: $formattedSize, '
        'tables: ${tables.length}'
        ')';
  }
}
