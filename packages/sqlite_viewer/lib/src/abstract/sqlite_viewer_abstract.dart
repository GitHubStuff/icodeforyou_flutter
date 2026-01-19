// packages/sqlite_viewer/lib/src/abstract/sqlite_viewer_abstract.dart

import 'package:dartz/dartz.dart';

import '../failures/sqlite_viewer_failure.dart';
import '../models/pragma_key.dart';

/// Abstract interface for database sources compatible with sqlite_viewer.
///
/// Implement this interface to make any SQLite database viewable
/// with [SqliteViewerPage] and [SqliteViewerCubit].
///
/// All methods return [Either] with [SqliteViewerFailure] on the left
/// for error handling, and the result on the right for success.
///
/// Example implementation:
/// ```dart
/// class MyDatabase implements SqliteViewerAbstract {
///   final Database _db;
///
///   @override
///   Future<Either<SqliteViewerFailure, String>> getFullPath() async {
///     if (!_db.isOpen) {
///       return const Left(ViewerDatabaseNotOpen());
///     }
///     return Right(_db.path);
///   }
///
///   // ... implement other methods
/// }
/// ```
abstract class SqliteViewerAbstract {
  /// Returns the full path to the database file.
  ///
  /// For file-based databases, returns the absolute path.
  /// For in-memory databases, returns ':memory:' or equivalent token.
  ///
  /// Returns [Left] with [ViewerDatabaseNotOpen] if database is not open.
  Future<Either<SqliteViewerFailure, String>> getFullPath();

  /// Returns the SQLite version string.
  ///
  /// Example: '3.39.0'
  ///
  /// Returns [Left] with [ViewerMetadataFailed] on error.
  Future<Either<SqliteViewerFailure, String>> getSqliteVersion();

  /// Returns the database size in bytes.
  ///
  /// Works for both file-based and in-memory databases.
  /// For in-memory databases, calculates size from page_count * page_size.
  ///
  /// Returns [Left] with [ViewerMetadataFailed] on error.
  Future<Either<SqliteViewerFailure, int>> getDatabaseSize();

  /// Returns a list of user table names in the database.
  ///
  /// Excludes SQLite internal tables (sqlite_*).
  /// Tables are returned in alphabetical order.
  ///
  /// Returns [Left] with [ViewerMetadataFailed] on error.
  Future<Either<SqliteViewerFailure, List<String>>> getTableNames();

  /// Returns the row count for a specific table.
  ///
  /// Returns [Left] with [ViewerTableNotFound] if table doesn't exist.
  /// Returns [Left] with [ViewerQueryFailed] on other errors.
  Future<Either<SqliteViewerFailure, int>> getRowCount(String tableName);

  /// Returns column names for a specific table.
  ///
  /// Column names are returned in ordinal position order.
  ///
  /// Returns [Left] with [ViewerTableNotFound] if table doesn't exist.
  /// Returns [Left] with [ViewerPragmaFailed] on other errors.
  Future<Either<SqliteViewerFailure, List<String>>> getColumnNames(
    String tableName,
  );

  /// Returns PRAGMA metadata for a specific table.
  ///
  /// The [key] parameter determines which PRAGMA to execute:
  /// - [PragmaKey.tableInfo]: Column definitions (name, type, nullable, etc.)
  /// - [PragmaKey.indexList]: Index definitions (name, uniqueness, origin)
  /// - [PragmaKey.foreignKeyList]: Foreign key relationships
  ///
  /// Returns raw SQLite PRAGMA results as `List<Map<String, Object?>>`.
  /// Each map represents one row from the PRAGMA result.
  ///
  /// Returns [Left] with [ViewerTableNotFound] if table doesn't exist.
  /// Returns [Left] with [ViewerPragmaFailed] on other errors.
  Future<Either<SqliteViewerFailure, List<Map<String, Object?>>>> getPragma({
    required String tableName,
    required PragmaKey key,
  });

  /// Executes a read-only SELECT query and returns results.
  ///
  /// The [sql] parameter must be a valid SELECT or WITH statement.
  /// Implementations should validate the query before execution.
  ///
  /// Returns results as `List<Map<String, Object?>>` where each map
  /// represents one row with column names as keys.
  ///
  /// Returns [Left] with [ViewerInvalidQuery] if query is not SELECT/WITH.
  /// Returns [Left] with [ViewerQueryFailed] on execution errors.
  ///
  /// Example:
  /// ```dart
  /// final result = await source.executeSelect('SELECT * FROM users LIMIT 10');
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (rows) => print('Got ${rows.length} rows'),
  /// );
  /// ```
  Future<Either<SqliteViewerFailure, List<Map<String, Object?>>>> executeSelect(
    String sql,
  );
}
