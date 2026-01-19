// packages/sqlite_viewer/lib/src/cubit/sqlite_viewer_cubit.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../abstract/sqlite_viewer_abstract.dart';
import '../failures/sqlite_viewer_failure.dart';
import '../models/database_metadata.dart';
import '../models/pragma_key.dart';
import '../utils/query_validator.dart';
import 'sqlite_viewer_state.dart';

/// Cubit for managing sqlite_viewer state.
///
/// Accepts any [SqliteViewerAbstract] implementation as a data source.
/// Handles loading metadata, table details, and executing custom queries.
///
/// Example usage:
/// ```dart
/// final db = await SinceWhenDatabase.openOrCreate();
/// final cubit = SqliteViewerCubit(db);
///
/// // Connect and load metadata
/// await cubit.connect();
///
/// // Select a table to view
/// await cubit.selectTable('users');
///
/// // Execute custom query
/// await cubit.executeQuery('SELECT * FROM users WHERE active = 1');
/// ```
class SqliteViewerCubit extends Cubit<SqliteViewerState> {
  SqliteViewerCubit(this._source) : super(const ViewerDisconnected());

  final SqliteViewerAbstract _source;

  // ═══════════════════════════════════════════════════════════════════════════
  // Connection
  // ═══════════════════════════════════════════════════════════════════════════

  /// Connects to the database source and loads initial metadata.
  ///
  /// Transitions: [ViewerDisconnected] → [ViewerConnecting] → [MetadataLoaded]
  /// On failure: → [ViewerConnectionFailed]
  Future<void> connect() async {
    emit(const ViewerConnecting());

    final metadataResult = await _loadMetadata();

    metadataResult.fold(
      (failure) => emit(ViewerConnectionFailed(failure: failure)),
      (metadata) => emit(MetadataLoaded(metadata: metadata)),
    );
  }

  /// Disconnects from the database source.
  ///
  /// Resets state to [ViewerDisconnected].
  void disconnect() {
    emit(const ViewerDisconnected());
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Metadata
  // ═══════════════════════════════════════════════════════════════════════════

  /// Refreshes database metadata.
  ///
  /// Requires being in a connected state (any state with metadata).
  /// Transitions: [MetadataLoaded] → [MetadataLoading] → [MetadataLoaded]
  /// On failure: → [MetadataLoadFailed]
  Future<void> refreshMetadata() async {
    final currentMetadata = _getCurrentMetadata();
    if (currentMetadata == null) {
      emit(const ViewerConnectionFailed(
        failure: ViewerDatabaseNotOpen(),
      ));
      return;
    }

    emit(MetadataLoading(metadata: currentMetadata));

    final metadataResult = await _loadMetadata();

    metadataResult.fold(
      (failure) => emit(MetadataLoadFailed(
        failure: failure,
        metadata: currentMetadata,
      )),
      (metadata) => emit(MetadataLoaded(metadata: metadata)),
    );
  }

  /// Returns to metadata view from table detail or query result.
  ///
  /// Requires being in a connected state.
  void showMetadata() {
    final currentMetadata = _getCurrentMetadata();
    if (currentMetadata == null) return;

    emit(MetadataLoaded(metadata: currentMetadata));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Table Detail
  // ═══════════════════════════════════════════════════════════════════════════

  /// Loads and displays details for a specific table.
  ///
  /// Loads column definitions, indexes, foreign keys, and table data.
  /// Transitions: → [TableDetailLoading] → [TableDetailLoaded]
  /// On failure: → [TableDetailLoadFailed]
  Future<void> selectTable(String tableName) async {
    final currentMetadata = _getCurrentMetadata();
    if (currentMetadata == null) {
      emit(const ViewerConnectionFailed(
        failure: ViewerDatabaseNotOpen(),
      ));
      return;
    }

    emit(TableDetailLoading(
      metadata: currentMetadata,
      tableName: tableName,
    ));

    // Load column names
    final columnsResult = await _source.getColumnNames(tableName);
    if (columnsResult.isLeft()) {
      emit(TableDetailLoadFailed(
        metadata: currentMetadata,
        tableName: tableName,
        failure: columnsResult.fold((f) => f, (_) => throw StateError('')),
      ));
      return;
    }
    final columns = columnsResult.fold((_) => <String>[], (c) => c);

    // Load PRAGMA table_info
    final tableInfoResult = await _source.getPragma(
      tableName: tableName,
      key: PragmaKey.tableInfo,
    );
    if (tableInfoResult.isLeft()) {
      emit(TableDetailLoadFailed(
        metadata: currentMetadata,
        tableName: tableName,
        failure: tableInfoResult.fold((f) => f, (_) => throw StateError('')),
      ));
      return;
    }
    final tableInfo = tableInfoResult.fold(
      (_) => <Map<String, Object?>>[],
      (t) => t,
    );

    // Load PRAGMA index_list
    final indexListResult = await _source.getPragma(
      tableName: tableName,
      key: PragmaKey.indexList,
    );
    if (indexListResult.isLeft()) {
      emit(TableDetailLoadFailed(
        metadata: currentMetadata,
        tableName: tableName,
        failure: indexListResult.fold((f) => f, (_) => throw StateError('')),
      ));
      return;
    }
    final indexList = indexListResult.fold(
      (_) => <Map<String, Object?>>[],
      (i) => i,
    );

    // Load PRAGMA foreign_key_list
    final foreignKeysResult = await _source.getPragma(
      tableName: tableName,
      key: PragmaKey.foreignKeyList,
    );
    if (foreignKeysResult.isLeft()) {
      emit(TableDetailLoadFailed(
        metadata: currentMetadata,
        tableName: tableName,
        failure: foreignKeysResult.fold((f) => f, (_) => throw StateError('')),
      ));
      return;
    }
    final foreignKeys = foreignKeysResult.fold(
      (_) => <Map<String, Object?>>[],
      (f) => f,
    );

    // Load row count
    final rowCountResult = await _source.getRowCount(tableName);
    if (rowCountResult.isLeft()) {
      emit(TableDetailLoadFailed(
        metadata: currentMetadata,
        tableName: tableName,
        failure: rowCountResult.fold((f) => f, (_) => throw StateError('')),
      ));
      return;
    }
    final rowCount = rowCountResult.fold((_) => 0, (r) => r);

    // Load table data (SELECT * FROM table)
    final rowsResult = await _source.executeSelect(
      'SELECT * FROM "$tableName"',
    );
    if (rowsResult.isLeft()) {
      emit(TableDetailLoadFailed(
        metadata: currentMetadata,
        tableName: tableName,
        failure: rowsResult.fold((f) => f, (_) => throw StateError('')),
      ));
      return;
    }
    final rows = rowsResult.fold((_) => <Map<String, Object?>>[], (r) => r);

    emit(TableDetailLoaded(
      metadata: currentMetadata,
      tableName: tableName,
      columns: columns,
      tableInfo: tableInfo,
      indexList: indexList,
      foreignKeys: foreignKeys,
      rows: rows,
      rowCount: rowCount,
    ));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Custom Query
  // ═══════════════════════════════════════════════════════════════════════════

  /// Executes a custom SELECT query.
  ///
  /// Validates that the query is a SELECT or WITH statement.
  /// Transitions: → [QueryExecuting] → [QueryResultLoaded]
  /// On failure: → [QueryFailed]
  Future<void> executeQuery(String sql) async {
    final currentMetadata = _getCurrentMetadata();
    if (currentMetadata == null) {
      emit(const ViewerConnectionFailed(
        failure: ViewerDatabaseNotOpen(),
      ));
      return;
    }

    // Validate query before execution
    final validationResult = QueryValidator.validate(sql);
    if (validationResult.isLeft()) {
      emit(QueryFailed(
        metadata: currentMetadata,
        query: sql,
        failure: validationResult.fold((f) => f, (_) => throw StateError('')),
      ));
      return;
    }
    final validatedQuery = validationResult.fold((_) => '', (q) => q);

    emit(QueryExecuting(
      metadata: currentMetadata,
      query: validatedQuery,
    ));

    final result = await _source.executeSelect(validatedQuery);

    result.fold(
      (failure) => emit(QueryFailed(
        metadata: currentMetadata,
        query: validatedQuery,
        failure: failure,
      )),
      (rows) {
        // Extract column names from first row, or empty list
        final columns = rows.isNotEmpty ? rows.first.keys.toList() : <String>[];

        emit(QueryResultLoaded(
          metadata: currentMetadata,
          query: validatedQuery,
          columns: columns,
          rows: rows,
        ));
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Private Helpers
  // ═══════════════════════════════════════════════════════════════════════════

  /// Loads database metadata from the source.
  Future<Either<SqliteViewerFailure, DatabaseMetadata>> _loadMetadata() async {
    // Load full path
    final pathResult = await _source.getFullPath();
    if (pathResult.isLeft()) {
      return Left(pathResult.fold((f) => f, (_) => throw StateError('')));
    }
    final fullPath = pathResult.fold((_) => '', (p) => p);

    // Load SQLite version
    final versionResult = await _source.getSqliteVersion();
    if (versionResult.isLeft()) {
      return Left(versionResult.fold((f) => f, (_) => throw StateError('')));
    }
    final sqliteVersion = versionResult.fold((_) => '', (v) => v);

    // Load database size
    final sizeResult = await _source.getDatabaseSize();
    if (sizeResult.isLeft()) {
      return Left(sizeResult.fold((f) => f, (_) => throw StateError('')));
    }
    final databaseSize = sizeResult.fold((_) => 0, (s) => s);

    // Load table names
    final tablesResult = await _source.getTableNames();
    if (tablesResult.isLeft()) {
      return Left(tablesResult.fold((f) => f, (_) => throw StateError('')));
    }
    final tables = tablesResult.fold((_) => <String>[], (t) => t);

    return Right(DatabaseMetadata(
      fullPath: fullPath,
      sqliteVersion: sqliteVersion,
      databaseSize: databaseSize,
      tables: tables,
    ));
  }

  /// Extracts metadata from current state, if available.
  DatabaseMetadata? _getCurrentMetadata() {
    final currentState = state;
    return switch (currentState) {
      ViewerDisconnected() => null,
      ViewerConnecting() => null,
      ViewerConnectionFailed() => null,
      MetadataLoading(:final metadata) => metadata,
      MetadataLoaded(:final metadata) => metadata,
      MetadataLoadFailed(:final metadata) => metadata,
      TableDetailLoading(:final metadata) => metadata,
      TableDetailLoaded(:final metadata) => metadata,
      TableDetailLoadFailed(:final metadata) => metadata,
      QueryExecuting(:final metadata) => metadata,
      QueryResultLoaded(:final metadata) => metadata,
      QueryFailed(:final metadata) => metadata,
    };
  }
}
