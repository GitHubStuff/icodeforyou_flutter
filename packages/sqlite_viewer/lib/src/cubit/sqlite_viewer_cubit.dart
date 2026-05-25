// packages/sqlite_viewer/lib/src/cubit/sqlite_viewer_cubit.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sqlite_viewer/src/abstract/sqlite_viewer_abstract.dart';
import 'package:sqlite_viewer/src/cubit/sqlite_viewer_state.dart';
import 'package:sqlite_viewer/src/failures/sqlite_viewer_failure.dart';
import 'package:sqlite_viewer/src/models/database_metadata.dart';
import 'package:sqlite_viewer/src/models/pragma_key.dart';
import 'package:sqlite_viewer/src/utils/query_validator.dart';

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
  /// Creates a viewer cubit with the given database 'source'.
  SqliteViewerCubit(this._source) : super(const ViewerDisconnected());

  /// Creates a cubit pre-seeded with [initialState] for testing.
  @visibleForTesting
  SqliteViewerCubit.seeded(this._source, SqliteViewerState initialState)
      : super(initialState);

  /// Creates a cubit pre-seeded with [initialState] for use outside tests —
  /// for example in a widgetbook workspace.
  ///
  /// Identical to [SqliteViewerCubit.seeded] but without the
  /// [visibleForTesting] restriction.
  SqliteViewerCubit.withState(this._source, SqliteViewerState initialState)
      : super(initialState);

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

    metadataResult.match(
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
      emit(
        const ViewerConnectionFailed(
          failure: ViewerDatabaseNotOpen(),
        ),
      );
      return;
    }

    emit(MetadataLoading(metadata: currentMetadata));

    final metadataResult = await _loadMetadata();

    metadataResult.match(
      (failure) => emit(
        MetadataLoadFailed(
          failure: failure,
          metadata: currentMetadata,
        ),
      ),
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
      emit(
        const ViewerConnectionFailed(
          failure: ViewerDatabaseNotOpen(),
        ),
      );
      return;
    }

    emit(
      TableDetailLoading(
        metadata: currentMetadata,
        tableName: tableName,
      ),
    );

    // Load column names
    final columnsResult = await _source.getColumnNames(tableName);
    if (columnsResult.isLeft()) {
      emit(
        TableDetailLoadFailed(
          metadata: currentMetadata,
          tableName: tableName,
          failure: columnsResult.match((f) => f, (_) => throw StateError('')),
        ),
      );
      return;
    }
    final columns = columnsResult.match((_) => <String>[], (c) => c);

    // Load PRAGMA table_info
    final tableInfoResult = await _source.getPragma(
      tableName: tableName,
      key: PragmaKey.tableInfo,
    );
    if (tableInfoResult
        case Left<SqliteViewerFailure, List<Map<String, Object?>>>(
          :final value,
        )) {
      emit(
        TableDetailLoadFailed(
          metadata: currentMetadata,
          tableName: tableName,
          failure: value,
        ),
      );
      return;
    }
    final tableInfo =
        (tableInfoResult
                as Right<SqliteViewerFailure, List<Map<String, Object?>>>)
            .value;

    // Load PRAGMA index_list
    final indexListResult = await _source.getPragma(
      tableName: tableName,
      key: PragmaKey.indexList,
    );
    if (indexListResult
        case Left<SqliteViewerFailure, List<Map<String, Object?>>>(
          :final value,
        )) {
      emit(
        TableDetailLoadFailed(
          metadata: currentMetadata,
          tableName: tableName,
          failure: value,
        ),
      );
      return;
    }
    final indexList =
        (indexListResult
                as Right<SqliteViewerFailure, List<Map<String, Object?>>>)
            .value;

    // Load PRAGMA foreign_key_list
    final foreignKeysResult = await _source.getPragma(
      tableName: tableName,
      key: PragmaKey.foreignKeyList,
    );
    if (foreignKeysResult
        case Left<SqliteViewerFailure, List<Map<String, Object?>>>(
          :final value,
        )) {
      emit(
        TableDetailLoadFailed(
          metadata: currentMetadata,
          tableName: tableName,
          failure: value,
        ),
      );
      return;
    }
    final foreignKeys =
        (foreignKeysResult
                as Right<SqliteViewerFailure, List<Map<String, Object?>>>)
            .value;

    // Load row count
    final rowCountResult = await _source.getRowCount(tableName);
    if (rowCountResult.isLeft()) {
      emit(
        TableDetailLoadFailed(
          metadata: currentMetadata,
          tableName: tableName,
          failure: rowCountResult.match((f) => f, (_) => throw StateError('')),
        ),
      );
      return;
    }
    final rowCount = rowCountResult.match((_) => 0, (r) => r);

    // Load table data (SELECT * FROM table)
    final rowsResult = await _source.executeSelect(
      'SELECT * FROM "$tableName"',
    );
    if (rowsResult.isLeft()) {
      emit(
        TableDetailLoadFailed(
          metadata: currentMetadata,
          tableName: tableName,
          failure: rowsResult.match((f) => f, (_) => throw StateError('')),
        ),
      );
      return;
    }
    final rows = rowsResult.match((_) => <Map<String, Object?>>[], (r) => r);

    emit(
      TableDetailLoaded(
        metadata: currentMetadata,
        tableName: tableName,
        columns: columns,
        tableInfo: tableInfo,
        indexList: indexList,
        foreignKeys: foreignKeys,
        rows: rows,
        rowCount: rowCount,
      ),
    );
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
      emit(
        const ViewerConnectionFailed(
          failure: ViewerDatabaseNotOpen(),
        ),
      );
      return;
    }

    // Validate query before execution — getLeft() avoids unreachable throw arm.
    final validationResult = QueryValidator.validate(sql);
    if (validationResult.isLeft()) {
      emit(
        QueryFailed(
          metadata: currentMetadata,
          query: sql,
          failure: validationResult.getLeft().toNullable()!,
        ),
      );
      return;
    }
    final validatedQuery = validationResult.getRight().toNullable()!;

    emit(
      QueryExecuting(
        metadata: currentMetadata,
        query: validatedQuery,
      ),
    );

    final result = await _source.executeSelect(validatedQuery);

    result.match(
      (failure) => emit(
        QueryFailed(
          metadata: currentMetadata,
          query: validatedQuery,
          failure: failure,
        ),
      ),
      (rows) {
        final columns =
            rows.isNotEmpty ? rows.first.keys.toList() : <String>[];

        emit(
          QueryResultLoaded(
            metadata: currentMetadata,
            query: validatedQuery,
            columns: columns,
            rows: rows,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Private Helpers
  // ═══════════════════════════════════════════════════════════════════════════

  Future<Either<SqliteViewerFailure, DatabaseMetadata>> _loadMetadata() async {
    final pathResult = await _source.getFullPath();
    if (pathResult.isLeft()) {
      return Left(pathResult.match((f) => f, (_) => throw StateError('')));
    }
    final fullPath = pathResult.match((_) => '', (p) => p);

    final versionResult = await _source.getSqliteVersion();
    if (versionResult.isLeft()) {
      return Left(versionResult.match((f) => f, (_) => throw StateError('')));
    }
    final sqliteVersion = versionResult.match((_) => '', (v) => v);

    final sizeResult = await _source.getDatabaseSize();
    if (sizeResult.isLeft()) {
      return Left(sizeResult.match((f) => f, (_) => throw StateError('')));
    }
    final databaseSize = sizeResult.match((_) => 0, (s) => s);

    final tablesResult = await _source.getTableNames();
    if (tablesResult.isLeft()) {
      return Left(tablesResult.match((f) => f, (_) => throw StateError('')));
    }
    final tables = tablesResult.match((_) => <String>[], (t) => t);

    return Right(
      DatabaseMetadata(
        fullPath: fullPath,
        sqliteVersion: sqliteVersion,
        databaseSize: databaseSize,
        tables: tables,
      ),
    );
  }

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
