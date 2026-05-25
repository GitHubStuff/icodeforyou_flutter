// packages/sqlite_viewer/lib/src/cubit/sqlite_viewer_state.dart

import 'package:equatable/equatable.dart';

import 'package:sqlite_viewer/src/failures/sqlite_viewer_failure.dart';
import 'package:sqlite_viewer/src/models/database_metadata.dart';

/// Base state for 'SqliteViewerCubit'.
///
/// Uses sealed class pattern for exhaustive pattern matching.
/// All states extend [Equatable] for proper BlocBuilder comparison.
sealed class SqliteViewerState extends Equatable {
  /// Creates a [SqliteViewerState].
  const SqliteViewerState();
}

// ═══════════════════════════════════════════════════════════════════════════
// CONNECTION STATES (3)
// ═══════════════════════════════════════════════════════════════════════════

/// Initial state — no database source attached.
final class ViewerDisconnected extends SqliteViewerState {
  /// Creates a [ViewerDisconnected] state.
  const ViewerDisconnected();

  @override
  List<Object?> get props => [];
}

/// Connecting to database source and loading initial metadata.
final class ViewerConnecting extends SqliteViewerState {
  /// Creates a [ViewerConnecting] state.
  const ViewerConnecting();

  @override
  List<Object?> get props => [];
}

/// Failed to connect to database or load initial metadata.
final class ViewerConnectionFailed extends SqliteViewerState {
  /// Creates a [ViewerConnectionFailed] state with the given [failure].
  const ViewerConnectionFailed({required this.failure});

  /// The failure that occurred during connection.
  final SqliteViewerFailure failure;

  @override
  List<Object?> get props => [failure];
}

// ═══════════════════════════════════════════════════════════════════════════
// METADATA STATES (3)
// ═══════════════════════════════════════════════════════════════════════════

/// Refreshing database metadata (path, version, size, tables).
final class MetadataLoading extends SqliteViewerState {
  /// Creates a [MetadataLoading] state with existing [metadata].
  const MetadataLoading({required this.metadata});

  /// Previous metadata, shown during refresh.
  final DatabaseMetadata metadata;

  @override
  List<Object?> get props => [metadata];
}

/// Database metadata loaded and ready.
///
/// This is the "home" state after successful connection.
final class MetadataLoaded extends SqliteViewerState {
  /// Creates a [MetadataLoaded] state with the loaded [metadata].
  const MetadataLoaded({required this.metadata});

  /// The loaded database metadata.
  final DatabaseMetadata metadata;

  @override
  List<Object?> get props => [metadata];
}

/// Failed to refresh database metadata.
final class MetadataLoadFailed extends SqliteViewerState {
  /// Creates a [MetadataLoadFailed] state with the given [failure].
  const MetadataLoadFailed({
    required this.failure,
    this.metadata,
  });

  /// The failure that occurred during metadata loading.
  final SqliteViewerFailure failure;

  /// Previous metadata if available, allows retry without losing context.
  final DatabaseMetadata? metadata;

  @override
  List<Object?> get props => [failure, metadata];
}

// ═══════════════════════════════════════════════════════════════════════════
// TABLE DETAIL STATES (3)
// ═══════════════════════════════════════════════════════════════════════════

/// Loading table detail (columns, indexes, foreign keys, rows).
final class TableDetailLoading extends SqliteViewerState {
  /// Creates a [TableDetailLoading] state for the given [tableName].
  const TableDetailLoading({
    required this.metadata,
    required this.tableName,
  });

  /// Current database metadata.
  final DatabaseMetadata metadata;

  /// Name of the table being loaded.
  final String tableName;

  @override
  List<Object?> get props => [metadata, tableName];
}

/// Table detail loaded and ready for display.
final class TableDetailLoaded extends SqliteViewerState {
  /// Creates a [TableDetailLoaded] state with complete table details.
  const TableDetailLoaded({
    required this.metadata,
    required this.tableName,
    required this.columns,
    required this.tableInfo,
    required this.indexList,
    required this.foreignKeys,
    required this.rows,
    required this.rowCount,
  });

  /// Current database metadata.
  final DatabaseMetadata metadata;

  /// Name of the selected table.
  final String tableName;

  /// Column names in ordinal order.
  final List<String> columns;

  /// PRAGMA table_info result — column definitions.
  final List<Map<String, Object?>> tableInfo;

  /// PRAGMA index_list result — index definitions.
  final List<Map<String, Object?>> indexList;

  /// PRAGMA foreign_key_list result — foreign key relationships.
  final List<Map<String, Object?>> foreignKeys;

  /// Table data rows (SELECT * FROM table).
  final List<Map<String, Object?>> rows;

  /// Total row count in table.
  final int rowCount;

  @override
  List<Object?> get props => [
    metadata,
    tableName,
    columns,
    tableInfo,
    indexList,
    foreignKeys,
    rows,
    rowCount,
  ];
}

/// Failed to load table detail.
final class TableDetailLoadFailed extends SqliteViewerState {
  /// Creates a [TableDetailLoadFailed] state with the given [failure].
  const TableDetailLoadFailed({
    required this.metadata,
    required this.tableName,
    required this.failure,
  });

  /// Current database metadata.
  final DatabaseMetadata metadata;

  /// Name of the table that failed to load.
  final String tableName;

  /// The failure that occurred during table loading.
  final SqliteViewerFailure failure;

  @override
  List<Object?> get props => [metadata, tableName, failure];
}

// ═══════════════════════════════════════════════════════════════════════════
// QUERY STATES (3)
// ═══════════════════════════════════════════════════════════════════════════

/// Executing a custom SELECT query.
final class QueryExecuting extends SqliteViewerState {
  /// Creates a [QueryExecuting] state for the given [query].
  const QueryExecuting({
    required this.metadata,
    required this.query,
  });

  /// Current database metadata.
  final DatabaseMetadata metadata;

  /// The query being executed.
  final String query;

  @override
  List<Object?> get props => [metadata, query];
}

/// Custom query executed successfully.
final class QueryResultLoaded extends SqliteViewerState {
  /// Creates a [QueryResultLoaded] state with query results.
  const QueryResultLoaded({
    required this.metadata,
    required this.query,
    required this.columns,
    required this.rows,
  });

  /// Current database metadata.
  final DatabaseMetadata metadata;

  /// The executed query string.
  final String query;

  /// Column names from the result set.
  final List<String> columns;

  /// Query result rows.
  final List<Map<String, Object?>> rows;

  /// Number of rows returned.
  int get rowCount => rows.length;

  @override
  List<Object?> get props => [metadata, query, columns, rows];
}

/// Custom query failed to execute.
final class QueryFailed extends SqliteViewerState {
  /// Creates a [QueryFailed] state with the given [failure].
  const QueryFailed({
    required this.metadata,
    required this.query,
    required this.failure,
  });

  /// Current database metadata.
  final DatabaseMetadata metadata;

  /// The query that failed.
  final String query;

  /// The failure that occurred during query execution.
  final SqliteViewerFailure failure;

  @override
  List<Object?> get props => [metadata, query, failure];
}
