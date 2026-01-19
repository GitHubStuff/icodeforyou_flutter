// packages/sqlite_viewer/lib/src/failures/sqlite_viewer_failure.dart

import 'package:equatable/equatable.dart';

/// Base failure type for sqlite_viewer operations.
///
/// Implementations should return [SqliteViewerFailure] in the `Left` side
/// of `Either` for all [SqliteViewerAbstract] methods.
sealed class SqliteViewerFailure extends Equatable {
  const SqliteViewerFailure();

  /// Human-readable error message.
  String get message;

  @override
  List<Object?> get props => [message];
}

/// Database connection is not open or source not attached.
final class ViewerDatabaseNotOpen extends SqliteViewerFailure {
  const ViewerDatabaseNotOpen();

  @override
  String get message => 'Database is not open';
}

/// Requested table does not exist in the database.
final class ViewerTableNotFound extends SqliteViewerFailure {
  const ViewerTableNotFound(this.tableName);

  final String tableName;

  @override
  String get message => 'Table not found: $tableName';

  @override
  List<Object?> get props => [tableName];
}

/// Query is not a valid SELECT or WITH statement.
final class ViewerInvalidQuery extends SqliteViewerFailure {
  const ViewerInvalidQuery(this.query, [this.reason]);

  final String query;
  final String? reason;

  @override
  String get message =>
      reason ?? 'Invalid query: only SELECT and WITH statements are allowed';

  @override
  List<Object?> get props => [query, reason];
}

/// Query execution failed at runtime.
final class ViewerQueryFailed extends SqliteViewerFailure {
  const ViewerQueryFailed(this.query, this.error);

  final String query;
  final String error;

  @override
  String get message => 'Query failed: $error';

  @override
  List<Object?> get props => [query, error];
}

/// Failed to retrieve PRAGMA metadata.
final class ViewerPragmaFailed extends SqliteViewerFailure {
  const ViewerPragmaFailed(this.tableName, this.pragmaKey, this.error);

  final String tableName;
  final String pragmaKey;
  final String error;

  @override
  String get message => 'Failed to get $pragmaKey for $tableName: $error';

  @override
  List<Object?> get props => [tableName, pragmaKey, error];
}

/// Failed to retrieve database metadata (version, size, etc.).
final class ViewerMetadataFailed extends SqliteViewerFailure {
  const ViewerMetadataFailed(this.operation, this.error);

  final String operation;
  final String error;

  @override
  String get message => 'Failed to get $operation: $error';

  @override
  List<Object?> get props => [operation, error];
}

/// Unexpected error not covered by other failure types.
final class ViewerUnexpectedError extends SqliteViewerFailure {
  const ViewerUnexpectedError(this.error);

  final String error;

  @override
  String get message => 'Unexpected error: $error';

  @override
  List<Object?> get props => [error];
}
