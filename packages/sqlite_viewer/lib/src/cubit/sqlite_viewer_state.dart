// packages/sqlite_viewer/lib/src/cubit/sqlite_viewer_state.dart

import 'package:equatable/equatable.dart';

import '../failures/sqlite_viewer_failure.dart';
import '../models/database_metadata.dart';

/// Base state for [SqliteViewerCubit].
///
/// Uses sealed class pattern for exhaustive pattern matching.
/// All states extend [Equatable] for proper BlocBuilder comparison.
sealed class SqliteViewerState extends Equatable {
  const SqliteViewerState();
}

// ═══════════════════════════════════════════════════════════════════════════
// CONNECTION STATES (3)
// ═══════════════════════════════════════════════════════════════════════════

/// Initial state — no database source attached.
final class ViewerDisconnected extends SqliteViewerState {
  const ViewerDisconnected();

  @override
  List<Object?> get props => [];
}

/// Connecting to database source and loading initial metadata.
final class ViewerConnecting extends SqliteViewerState {
  const ViewerConnecting();

  @override
  List<Object?> get props => [];
}

/// Failed to connect to database or load initial metadata.
final class ViewerConnectionFailed extends SqliteViewerState {
  const ViewerConnectionFailed({required this.failure});

  final SqliteViewerFailure failure;

  @override
  List<Object?> get props => [failure];
}

// ═══════════════════════════════════════════════════════════════════════════
// METADATA STATES (3)
// ═══════════════════════════════════════════════════════════════════════════

/// Refreshing database metadata (path, version, size, tables).
final class MetadataLoading extends SqliteViewerState {
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
  const MetadataLoaded({required this.metadata});

  final DatabaseMetadata metadata;

  @override
  List<Object?> get props => [metadata];
}

/// Failed to refresh database metadata.
final class MetadataLoadFailed extends SqliteViewerState {
  const MetadataLoadFailed({
    required this.failure,
    this.metadata,
  });

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
  const TableDetailLoading({
    required this.metadata,
    required this.tableName,
  });

  final DatabaseMetadata metadata;
  final String tableName;

  @override
  List<Object?> get props => [metadata, tableName];
}

/// Table detail loaded and ready for display.
final class TableDetailLoaded extends SqliteViewerState {
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
  const TableDetailLoadFailed({
    required this.metadata,
    required this.tableName,
    required this.failure,
  });

  final DatabaseMetadata metadata;
  final String tableName;
  final SqliteViewerFailure failure;

  @override
  List<Object?> get props => [metadata, tableName, failure];
}

// ═══════════════════════════════════════════════════════════════════════════
// QUERY STATES (3)
// ═══════════════════════════════════════════════════════════════════════════

/// Executing a custom SELECT query.
final class QueryExecuting extends SqliteViewerState {
  const QueryExecuting({
    required this.metadata,
    required this.query,
  });

  final DatabaseMetadata metadata;
  final String query;

  @override
  List<Object?> get props => [metadata, query];
}

/// Custom query executed successfully.
final class QueryResultLoaded extends SqliteViewerState {
  const QueryResultLoaded({
    required this.metadata,
    required this.query,
    required this.columns,
    required this.rows,
  });

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
  const QueryFailed({
    required this.metadata,
    required this.query,
    required this.failure,
  });

  final DatabaseMetadata metadata;
  final String query;
  final SqliteViewerFailure failure;

  @override
  List<Object?> get props => [metadata, query, failure];
}
