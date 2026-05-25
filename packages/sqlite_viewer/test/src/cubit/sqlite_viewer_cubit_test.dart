// packages/sqlite_viewer/test/src/cubit/sqlite_viewer_cubit_test.dart
// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite_viewer/src/abstract/sqlite_viewer_abstract.dart';
import 'package:sqlite_viewer/src/cubit/sqlite_viewer_cubit.dart';
import 'package:sqlite_viewer/src/cubit/sqlite_viewer_state.dart';
import 'package:sqlite_viewer/src/failures/sqlite_viewer_failure.dart';
import 'package:sqlite_viewer/src/models/database_metadata.dart';
import 'package:sqlite_viewer/src/models/pragma_key.dart';

class MockSqliteViewerAbstract extends Mock implements SqliteViewerAbstract {}

void main() {
  late MockSqliteViewerAbstract mockSource;
  late SqliteViewerCubit cubit;

  const testMetadata = DatabaseMetadata(
    fullPath: '/test/path/database.db',
    sqliteVersion: '3.39.0',
    databaseSize: 4096,
    tables: ['users', 'posts'],
  );

  const tableName = 'users';
  final testColumns = ['id', 'name', 'email'];
  final testTableInfo = [
    {'cid': 0, 'name': 'id', 'type': 'INTEGER', 'notnull': 1, 'pk': 1},
    {'cid': 1, 'name': 'name', 'type': 'TEXT', 'notnull': 0, 'pk': 0},
  ];
  final testIndexList = [
    {'seq': 0, 'name': 'idx_users_email', 'unique': 1, 'origin': 'c'},
  ];
  final testForeignKeys = <Map<String, Object?>>[];
  final testRows = [
    {'id': 1, 'name': 'Alice', 'email': 'alice@example.com'},
  ];

  void setupSuccessfulMetadata() {
    when(
      () => mockSource.getFullPath(),
    ).thenAnswer((_) async => Right(testMetadata.fullPath));
    when(
      () => mockSource.getSqliteVersion(),
    ).thenAnswer((_) async => Right(testMetadata.sqliteVersion));
    when(
      () => mockSource.getDatabaseSize(),
    ).thenAnswer((_) async => Right(testMetadata.databaseSize));
    when(
      () => mockSource.getTableNames(),
    ).thenAnswer((_) async => Right(testMetadata.tables));
  }

  void setupSuccessfulTableDetail() {
    when(
      () => mockSource.getColumnNames(tableName),
    ).thenAnswer((_) async => Right(testColumns));
    when(
      () => mockSource.getPragma(
        tableName: tableName,
        key: PragmaKey.tableInfo,
      ),
    ).thenAnswer((_) async => Right(testTableInfo));
    when(
      () => mockSource.getPragma(
        tableName: tableName,
        key: PragmaKey.indexList,
      ),
    ).thenAnswer((_) async => Right(testIndexList));
    when(
      () => mockSource.getPragma(
        tableName: tableName,
        key: PragmaKey.foreignKeyList,
      ),
    ).thenAnswer((_) async => Right(testForeignKeys));
    when(
      () => mockSource.getRowCount(tableName),
    ).thenAnswer((_) async => Right(1));
    when(
      () => mockSource.executeSelect('SELECT * FROM "$tableName"'),
    ).thenAnswer((_) async => Right(testRows));
  }

  setUp(() {
    mockSource = MockSqliteViewerAbstract();
    cubit = SqliteViewerCubit(mockSource);
  });

  tearDown(() {
    unawaited(cubit.close());
  });

  group('SqliteViewerCubit', () {
    test('initial state is ViewerDisconnected', () {
      expect(cubit.state, isA<ViewerDisconnected>());
    });

    group('connect', () {
      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [ViewerConnecting, MetadataLoaded] on success',
        setUp: setupSuccessfulMetadata,
        build: () => cubit,
        act: (cubit) => cubit.connect(),
        expect: () => [
          ViewerConnecting(),
          MetadataLoaded(metadata: testMetadata),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [ViewerConnecting, ViewerConnectionFailed] when getFullPath fails',
        setUp: () {
          when(
            () => mockSource.getFullPath(),
          ).thenAnswer((_) async => Left(ViewerDatabaseNotOpen()));
        },
        build: () => cubit,
        act: (cubit) => cubit.connect(),
        expect: () => [
          ViewerConnecting(),
          ViewerConnectionFailed(failure: ViewerDatabaseNotOpen()),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [ViewerConnecting, ViewerConnectionFailed] when getSqliteVersion fails',
        setUp: () {
          when(
            () => mockSource.getFullPath(),
          ).thenAnswer((_) async => Right('/test/path'));
          when(() => mockSource.getSqliteVersion()).thenAnswer(
            (_) async => Left(ViewerMetadataFailed('version', 'error')),
          );
        },
        build: () => cubit,
        act: (cubit) => cubit.connect(),
        expect: () => [
          ViewerConnecting(),
          ViewerConnectionFailed(
            failure: ViewerMetadataFailed('version', 'error'),
          ),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [ViewerConnecting, ViewerConnectionFailed] when getDatabaseSize fails',
        setUp: () {
          when(
            () => mockSource.getFullPath(),
          ).thenAnswer((_) async => Right('/test/path'));
          when(
            () => mockSource.getSqliteVersion(),
          ).thenAnswer((_) async => Right('3.39.0'));
          when(() => mockSource.getDatabaseSize()).thenAnswer(
            (_) async => Left(ViewerMetadataFailed('size', 'error')),
          );
        },
        build: () => cubit,
        act: (cubit) => cubit.connect(),
        expect: () => [
          ViewerConnecting(),
          ViewerConnectionFailed(
            failure: ViewerMetadataFailed('size', 'error'),
          ),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [ViewerConnecting, ViewerConnectionFailed] when getTableNames fails',
        setUp: () {
          when(
            () => mockSource.getFullPath(),
          ).thenAnswer((_) async => Right('/test/path'));
          when(
            () => mockSource.getSqliteVersion(),
          ).thenAnswer((_) async => Right('3.39.0'));
          when(
            () => mockSource.getDatabaseSize(),
          ).thenAnswer((_) async => Right(4096));
          when(() => mockSource.getTableNames()).thenAnswer(
            (_) async => Left(ViewerMetadataFailed('tables', 'error')),
          );
        },
        build: () => cubit,
        act: (cubit) => cubit.connect(),
        expect: () => [
          ViewerConnecting(),
          ViewerConnectionFailed(
            failure: ViewerMetadataFailed('tables', 'error'),
          ),
        ],
      );
    });

    group('disconnect', () {
      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits ViewerDisconnected',
        setUp: setupSuccessfulMetadata,
        build: () => cubit,
        seed: () => MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.disconnect(),
        expect: () => [ViewerDisconnected()],
      );
    });

    group('refreshMetadata', () {
      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits ViewerConnectionFailed when not connected',
        build: () => cubit,
        act: (cubit) => cubit.refreshMetadata(),
        expect: () => [
          ViewerConnectionFailed(failure: ViewerDatabaseNotOpen()),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [MetadataLoading, MetadataLoaded] on success',
        setUp: setupSuccessfulMetadata,
        build: () => cubit,
        seed: () => MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.refreshMetadata(),
        expect: () => [
          MetadataLoading(metadata: testMetadata),
          MetadataLoaded(metadata: testMetadata),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [MetadataLoading, MetadataLoadFailed] on failure',
        setUp: () {
          when(
            () => mockSource.getFullPath(),
          ).thenAnswer((_) async => Left(ViewerDatabaseNotOpen()));
        },
        build: () => cubit,
        seed: () => MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.refreshMetadata(),
        expect: () => [
          MetadataLoading(metadata: testMetadata),
          MetadataLoadFailed(
            failure: ViewerDatabaseNotOpen(),
            metadata: testMetadata,
          ),
        ],
      );
    });

    group('showMetadata', () {
      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'does nothing when not connected',
        build: () => cubit,
        act: (cubit) => cubit.showMetadata(),
        expect: () => <SqliteViewerState>[],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits MetadataLoaded from TableDetailLoaded state',
        build: () => cubit,
        seed: () => TableDetailLoaded(
          metadata: testMetadata,
          tableName: tableName,
          columns: testColumns,
          tableInfo: testTableInfo,
          indexList: testIndexList,
          foreignKeys: testForeignKeys,
          rows: testRows,
          rowCount: 1,
        ),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [MetadataLoaded(metadata: testMetadata)],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits MetadataLoaded from QueryResultLoaded state',
        build: () => cubit,
        seed: () => QueryResultLoaded(
          metadata: testMetadata,
          query: 'SELECT * FROM users',
          columns: testColumns,
          rows: testRows,
        ),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [MetadataLoaded(metadata: testMetadata)],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits MetadataLoaded from MetadataLoadFailed state',
        build: () => cubit,
        seed: () => MetadataLoadFailed(
          failure: ViewerDatabaseNotOpen(),
          metadata: testMetadata,
        ),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [MetadataLoaded(metadata: testMetadata)],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits MetadataLoaded from TableDetailLoadFailed state',
        build: () => cubit,
        seed: () => TableDetailLoadFailed(
          metadata: testMetadata,
          tableName: tableName,
          failure: ViewerTableNotFound(tableName),
        ),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [MetadataLoaded(metadata: testMetadata)],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits MetadataLoaded from QueryFailed state',
        build: () => cubit,
        seed: () => QueryFailed(
          metadata: testMetadata,
          query: 'SELECT * FROM users',
          failure: ViewerQueryFailed('SELECT * FROM users', 'error'),
        ),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [MetadataLoaded(metadata: testMetadata)],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits MetadataLoaded from QueryExecuting state',
        build: () => cubit,
        seed: () => QueryExecuting(
          metadata: testMetadata,
          query: 'SELECT * FROM users',
        ),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [MetadataLoaded(metadata: testMetadata)],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits MetadataLoaded from TableDetailLoading state',
        build: () => cubit,
        seed: () => TableDetailLoading(
          metadata: testMetadata,
          tableName: tableName,
        ),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [MetadataLoaded(metadata: testMetadata)],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits MetadataLoaded from MetadataLoading state',
        build: () => cubit,
        seed: () => MetadataLoading(metadata: testMetadata),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [MetadataLoaded(metadata: testMetadata)],
      );
    });

    group('selectTable', () {
      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits ViewerConnectionFailed when not connected',
        build: () => cubit,
        act: (cubit) => cubit.selectTable(tableName),
        expect: () => [
          ViewerConnectionFailed(failure: ViewerDatabaseNotOpen()),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [TableDetailLoading, TableDetailLoaded] on success',
        setUp: setupSuccessfulTableDetail,
        build: () => cubit,
        seed: () => MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.selectTable(tableName),
        expect: () => [
          TableDetailLoading(metadata: testMetadata, tableName: tableName),
          TableDetailLoaded(
            metadata: testMetadata,
            tableName: tableName,
            columns: testColumns,
            tableInfo: testTableInfo,
            indexList: testIndexList,
            foreignKeys: testForeignKeys,
            rows: testRows,
            rowCount: 1,
          ),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits TableDetailLoadFailed when getColumnNames fails',
        setUp: () {
          when(() => mockSource.getColumnNames(tableName)).thenAnswer(
            (_) async => Left(ViewerTableNotFound(tableName)),
          );
        },
        build: () => cubit,
        seed: () => MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.selectTable(tableName),
        expect: () => [
          TableDetailLoading(metadata: testMetadata, tableName: tableName),
          TableDetailLoadFailed(
            metadata: testMetadata,
            tableName: tableName,
            failure: ViewerTableNotFound(tableName),
          ),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits TableDetailLoadFailed when getPragma tableInfo fails',
        setUp: () {
          when(
            () => mockSource.getColumnNames(tableName),
          ).thenAnswer((_) async => Right(testColumns));
          when(
            () => mockSource.getPragma(
              tableName: tableName,
              key: PragmaKey.tableInfo,
            ),
          ).thenAnswer(
            (_) async => Left(
              ViewerPragmaFailed(tableName, 'table_info', 'error'),
            ),
          );
        },
        build: () => cubit,
        seed: () => MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.selectTable(tableName),
        expect: () => [
          TableDetailLoading(metadata: testMetadata, tableName: tableName),
          TableDetailLoadFailed(
            metadata: testMetadata,
            tableName: tableName,
            failure: ViewerPragmaFailed(tableName, 'table_info', 'error'),
          ),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits TableDetailLoadFailed when getPragma indexList fails',
        setUp: () {
          when(
            () => mockSource.getColumnNames(tableName),
          ).thenAnswer((_) async => Right(testColumns));
          when(
            () => mockSource.getPragma(
              tableName: tableName,
              key: PragmaKey.tableInfo,
            ),
          ).thenAnswer((_) async => Right(testTableInfo));
          when(
            () => mockSource.getPragma(
              tableName: tableName,
              key: PragmaKey.indexList,
            ),
          ).thenAnswer(
            (_) async => Left(
              ViewerPragmaFailed(tableName, 'index_list', 'error'),
            ),
          );
        },
        build: () => cubit,
        seed: () => MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.selectTable(tableName),
        expect: () => [
          TableDetailLoading(metadata: testMetadata, tableName: tableName),
          TableDetailLoadFailed(
            metadata: testMetadata,
            tableName: tableName,
            failure: ViewerPragmaFailed(tableName, 'index_list', 'error'),
          ),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits TableDetailLoadFailed when getPragma foreignKeyList fails',
        setUp: () {
          when(
            () => mockSource.getColumnNames(tableName),
          ).thenAnswer((_) async => Right(testColumns));
          when(
            () => mockSource.getPragma(
              tableName: tableName,
              key: PragmaKey.tableInfo,
            ),
          ).thenAnswer((_) async => Right(testTableInfo));
          when(
            () => mockSource.getPragma(
              tableName: tableName,
              key: PragmaKey.indexList,
            ),
          ).thenAnswer((_) async => Right(testIndexList));
          when(
            () => mockSource.getPragma(
              tableName: tableName,
              key: PragmaKey.foreignKeyList,
            ),
          ).thenAnswer(
            (_) async => Left(
              ViewerPragmaFailed(tableName, 'foreign_key_list', 'error'),
            ),
          );
        },
        build: () => cubit,
        seed: () => MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.selectTable(tableName),
        expect: () => [
          TableDetailLoading(metadata: testMetadata, tableName: tableName),
          TableDetailLoadFailed(
            metadata: testMetadata,
            tableName: tableName,
            failure: ViewerPragmaFailed(tableName, 'foreign_key_list', 'error'),
          ),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits TableDetailLoadFailed when getRowCount fails',
        setUp: () {
          when(
            () => mockSource.getColumnNames(tableName),
          ).thenAnswer((_) async => Right(testColumns));
          when(
            () => mockSource.getPragma(
              tableName: tableName,
              key: PragmaKey.tableInfo,
            ),
          ).thenAnswer((_) async => Right(testTableInfo));
          when(
            () => mockSource.getPragma(
              tableName: tableName,
              key: PragmaKey.indexList,
            ),
          ).thenAnswer((_) async => Right(testIndexList));
          when(
            () => mockSource.getPragma(
              tableName: tableName,
              key: PragmaKey.foreignKeyList,
            ),
          ).thenAnswer((_) async => Right(testForeignKeys));
          when(() => mockSource.getRowCount(tableName)).thenAnswer(
            (_) async => Left(ViewerQueryFailed('COUNT', 'error')),
          );
        },
        build: () => cubit,
        seed: () => MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.selectTable(tableName),
        expect: () => [
          TableDetailLoading(metadata: testMetadata, tableName: tableName),
          TableDetailLoadFailed(
            metadata: testMetadata,
            tableName: tableName,
            failure: ViewerQueryFailed('COUNT', 'error'),
          ),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits TableDetailLoadFailed when executeSelect fails',
        setUp: () {
          when(
            () => mockSource.getColumnNames(tableName),
          ).thenAnswer((_) async => Right(testColumns));
          when(
            () => mockSource.getPragma(
              tableName: tableName,
              key: PragmaKey.tableInfo,
            ),
          ).thenAnswer((_) async => Right(testTableInfo));
          when(
            () => mockSource.getPragma(
              tableName: tableName,
              key: PragmaKey.indexList,
            ),
          ).thenAnswer((_) async => Right(testIndexList));
          when(
            () => mockSource.getPragma(
              tableName: tableName,
              key: PragmaKey.foreignKeyList,
            ),
          ).thenAnswer((_) async => Right(testForeignKeys));
          when(
            () => mockSource.getRowCount(tableName),
          ).thenAnswer((_) async => Right(1));
          when(
            () => mockSource.executeSelect('SELECT * FROM "$tableName"'),
          ).thenAnswer(
            (_) async => Left(ViewerQueryFailed('SELECT', 'error')),
          );
        },
        build: () => cubit,
        seed: () => MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.selectTable(tableName),
        expect: () => [
          TableDetailLoading(metadata: testMetadata, tableName: tableName),
          TableDetailLoadFailed(
            metadata: testMetadata,
            tableName: tableName,
            failure: ViewerQueryFailed('SELECT', 'error'),
          ),
        ],
      );
    });

    group('executeQuery', () {
      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits ViewerConnectionFailed when not connected',
        build: () => cubit,
        act: (cubit) => cubit.executeQuery('SELECT * FROM users'),
        expect: () => [
          ViewerConnectionFailed(failure: ViewerDatabaseNotOpen()),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits QueryFailed for invalid query',
        build: () => cubit,
        seed: () => MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.executeQuery('DELETE FROM users'),
        expect: () => [
          isA<QueryFailed>().having(
            (s) => s.failure,
            'failure',
            isA<ViewerInvalidQuery>(),
          ),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [QueryExecuting, QueryResultLoaded] on success',
        setUp: () {
          when(
            () => mockSource.executeSelect('SELECT * FROM users'),
          ).thenAnswer((_) async => Right(testRows));
        },
        build: () => cubit,
        seed: () => MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.executeQuery('SELECT * FROM users'),
        expect: () => [
          QueryExecuting(
            metadata: testMetadata,
            query: 'SELECT * FROM users',
          ),
          QueryResultLoaded(
            metadata: testMetadata,
            query: 'SELECT * FROM users',
            columns: const ['id', 'name', 'email'],
            rows: testRows,
          ),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits QueryResultLoaded with empty columns for empty results',
        setUp: () {
          when(
            () => mockSource.executeSelect('SELECT * FROM empty_table'),
          ).thenAnswer((_) async => Right(<Map<String, Object?>>[]));
        },
        build: () => cubit,
        seed: () => MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.executeQuery('SELECT * FROM empty_table'),
        expect: () => [
          QueryExecuting(
            metadata: testMetadata,
            query: 'SELECT * FROM empty_table',
          ),
          QueryResultLoaded(
            metadata: testMetadata,
            query: 'SELECT * FROM empty_table',
            columns: const <String>[],
            rows: const <Map<String, Object?>>[],
          ),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [QueryExecuting, QueryFailed] on execution failure',
        setUp: () {
          when(
            () => mockSource.executeSelect('SELECT * FROM users'),
          ).thenAnswer(
            (_) async => Left(
              ViewerQueryFailed('SELECT * FROM users', 'no such table'),
            ),
          );
        },
        build: () => cubit,
        seed: () => MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.executeQuery('SELECT * FROM users'),
        expect: () => [
          QueryExecuting(
            metadata: testMetadata,
            query: 'SELECT * FROM users',
          ),
          QueryFailed(
            metadata: testMetadata,
            query: 'SELECT * FROM users',
            failure: ViewerQueryFailed('SELECT * FROM users', 'no such table'),
          ),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'handles WITH queries correctly',
        setUp: () {
          const withQuery = 'WITH cte AS (SELECT 1) SELECT * FROM cte';
          when(() => mockSource.executeSelect(withQuery)).thenAnswer(
            (_) async => Right([
              {'1': 1},
            ]),
          );
        },
        build: () => cubit,
        seed: () => MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.executeQuery(
          'WITH cte AS (SELECT 1) SELECT * FROM cte',
        ),
        expect: () => [
          QueryExecuting(
            metadata: testMetadata,
            query: 'WITH cte AS (SELECT 1) SELECT * FROM cte',
          ),
          QueryResultLoaded(
            metadata: testMetadata,
            query: 'WITH cte AS (SELECT 1) SELECT * FROM cte',
            columns: const ['1'],
            rows: const [
              {'1': 1},
            ],
          ),
        ],
      );
    });
  });
}
