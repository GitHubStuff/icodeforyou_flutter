// test/src/cubit/sqlite_viewer_cubit_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../helpers/mock_sqlite_viewer_source.dart';

void main() {
  group('SqliteViewerCubit', () {
    late MockSqliteViewerSource mockSource;

    setUp(() {
      mockSource = MockSqliteViewerSource(
        fullPath: '/path/test.db',
        sqliteVersion: '3.39.0',
        databaseSize: 1024,
        tableNames: ['users', 'posts'],
        rowCounts: {'users': 10, 'posts': 5},
        columnNamesMap: {
          'users': ['id', 'name', 'email'],
          'posts': ['id', 'title', 'user_id'],
        },
        pragmaResults: {
          'users_tableInfo': [
            {'cid': 0, 'name': 'id', 'type': 'INTEGER', 'notnull': 1, 'pk': 1},
            {'cid': 1, 'name': 'name', 'type': 'TEXT', 'notnull': 0, 'pk': 0},
          ],
          'users_indexList': [
            {'seq': 0, 'name': 'idx_users_email', 'unique': 1},
          ],
          'users_foreignKeyList': [],
        },
        selectResults: {
          'SELECT * FROM "users"': [
            {'id': 1, 'name': 'Alice', 'email': 'alice@test.com'},
            {'id': 2, 'name': 'Bob', 'email': 'bob@test.com'},
          ],
          'SELECT * FROM users': [
            {'id': 1, 'name': 'Alice'},
          ],
        },
      );
    });

    test('initial state is ViewerDisconnected', () {
      final cubit = SqliteViewerCubit(mockSource);
      expect(cubit.state, const ViewerDisconnected());
      cubit.close();
    });

    group('connect', () {
      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [ViewerConnecting, MetadataLoaded] on success',
        build: () => SqliteViewerCubit(mockSource),
        act: (cubit) => cubit.connect(),
        expect: () => [
          const ViewerConnecting(),
          isA<MetadataLoaded>()
              .having((s) => s.metadata.fullPath, 'fullPath', '/path/test.db')
              .having((s) => s.metadata.sqliteVersion, 'version', '3.39.0')
              .having((s) => s.metadata.databaseSize, 'size', 1024)
              .having((s) => s.metadata.tables, 'tables', ['users', 'posts']),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [ViewerConnecting, ViewerConnectionFailed] when getFullPath'
        ' fails',
        build: () {
          mockSource.getFullPathFailure = const ViewerDatabaseNotOpen();
          return SqliteViewerCubit(mockSource);
        },
        act: (cubit) => cubit.connect(),
        expect: () => [
          const ViewerConnecting(),
          isA<ViewerConnectionFailed>().having(
            (s) => s.failure,
            'failure',
            const ViewerDatabaseNotOpen(),
          ),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [ViewerConnecting, ViewerConnectionFailed] when getSqliteVersion fails',
        build: () {
          mockSource.getSqliteVersionFailure = const ViewerMetadataFailed(
            'version',
            'error',
          );
          return SqliteViewerCubit(mockSource);
        },
        act: (cubit) => cubit.connect(),
        expect: () => [
          const ViewerConnecting(),
          isA<ViewerConnectionFailed>(),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [ViewerConnecting, ViewerConnectionFailed] when getDatabaseSize'
        ' fails',
        build: () {
          mockSource.getDatabaseSizeFailure = const ViewerMetadataFailed(
            'size',
            'error',
          );
          return SqliteViewerCubit(mockSource);
        },
        act: (cubit) => cubit.connect(),
        expect: () => [
          const ViewerConnecting(),
          isA<ViewerConnectionFailed>(),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [ViewerConnecting, ViewerConnectionFailed] when getTableNames fails',
        build: () {
          mockSource.getTableNamesFailure = const ViewerMetadataFailed(
            'tables',
            'error',
          );
          return SqliteViewerCubit(mockSource);
        },
        act: (cubit) => cubit.connect(),
        expect: () => [
          const ViewerConnecting(),
          isA<ViewerConnectionFailed>(),
        ],
      );
    });

    group('disconnect', () {
      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [ViewerDisconnected]',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => MetadataLoaded(
          metadata: DatabaseMetadata(
            fullPath: '/path/test.db',
            sqliteVersion: '3.39.0',
            databaseSize: 1024,
            tables: ['users'],
          ),
        ),
        act: (cubit) => cubit.disconnect(),
        expect: () => [const ViewerDisconnected()],
      );
    });

    group('refreshMetadata', () {
      const testMetadata = DatabaseMetadata(
        fullPath: '/path/test.db',
        sqliteVersion: '3.39.0',
        databaseSize: 1024,
        tables: ['users'],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [MetadataLoading, MetadataLoaded] on success',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => const MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.refreshMetadata(),
        expect: () => [
          const MetadataLoading(metadata: testMetadata),
          isA<MetadataLoaded>(),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits ViewerConnectionFailed when not connected',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => const ViewerDisconnected(),
        act: (cubit) => cubit.refreshMetadata(),
        expect: () => [
          isA<ViewerConnectionFailed>().having(
            (s) => s.failure,
            'failure',
            const ViewerDatabaseNotOpen(),
          ),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [MetadataLoading, MetadataLoadFailed] on failure',
        build: () {
          mockSource.getFullPathFailure = const ViewerDatabaseNotOpen();
          return SqliteViewerCubit(mockSource);
        },
        seed: () => const MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.refreshMetadata(),
        expect: () => [
          const MetadataLoading(metadata: testMetadata),
          isA<MetadataLoadFailed>().having(
            (s) => s.metadata,
            'metadata',
            testMetadata,
          ),
        ],
      );
    });

    group('showMetadata', () {
      const testMetadata = DatabaseMetadata(
        fullPath: '/path/test.db',
        sqliteVersion: '3.39.0',
        databaseSize: 1024,
        tables: ['users'],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits MetadataLoaded from TableDetailLoaded',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => const TableDetailLoaded(
          metadata: testMetadata,
          tableName: 'users',
          columns: ['id'],
          tableInfo: [],
          indexList: [],
          foreignKeys: [],
          rows: [],
          rowCount: 0,
        ),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [const MetadataLoaded(metadata: testMetadata)],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'does nothing when disconnected',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => const ViewerDisconnected(),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [],
      );
    });

    group('selectTable', () {
      const testMetadata = DatabaseMetadata(
        fullPath: '/path/test.db',
        sqliteVersion: '3.39.0',
        databaseSize: 1024,
        tables: ['users', 'posts'],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [TableDetailLoading, TableDetailLoaded] on success',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => const MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.selectTable('users'),
        expect: () => [
          const TableDetailLoading(
            metadata: testMetadata,
            tableName: 'users',
          ),
          isA<TableDetailLoaded>()
              .having((s) => s.tableName, 'tableName', 'users')
              .having((s) => s.columns, 'columns', ['id', 'name', 'email'])
              .having((s) => s.rowCount, 'rowCount', 10),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits ViewerConnectionFailed when not connected',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => const ViewerDisconnected(),
        act: (cubit) => cubit.selectTable('users'),
        expect: () => [
          isA<ViewerConnectionFailed>().having(
            (s) => s.failure,
            'failure',
            const ViewerDatabaseNotOpen(),
          ),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits TableDetailLoadFailed when getColumnNames fails',
        build: () {
          mockSource.getColumnNamesFailure = const ViewerTableNotFound('users');
          return SqliteViewerCubit(mockSource);
        },
        seed: () => const MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.selectTable('users'),
        expect: () => [
          const TableDetailLoading(
            metadata: testMetadata,
            tableName: 'users',
          ),
          isA<TableDetailLoadFailed>(),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits TableDetailLoadFailed when getPragma tableInfo fails',
        build: () {
          mockSource.getPragmaFailure = const ViewerPragmaFailed(
            'users',
            'table_info',
            'error',
          );
          return SqliteViewerCubit(mockSource);
        },
        seed: () => const MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.selectTable('users'),
        expect: () => [
          const TableDetailLoading(
            metadata: testMetadata,
            tableName: 'users',
          ),
          isA<TableDetailLoadFailed>(),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits TableDetailLoadFailed when getRowCount fails',
        build: () {
          mockSource.getRowCountFailure = const ViewerQueryFailed(
            'COUNT',
            'error',
          );
          return SqliteViewerCubit(mockSource);
        },
        seed: () => const MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.selectTable('users'),
        expect: () => [
          const TableDetailLoading(
            metadata: testMetadata,
            tableName: 'users',
          ),
          isA<TableDetailLoadFailed>(),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits TableDetailLoadFailed when executeSelect fails',
        build: () {
          mockSource.executeSelectFailure = const ViewerQueryFailed(
            'SELECT',
            'error',
          );
          return SqliteViewerCubit(mockSource);
        },
        seed: () => const MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.selectTable('users'),
        expect: () => [
          const TableDetailLoading(
            metadata: testMetadata,
            tableName: 'users',
          ),
          isA<TableDetailLoadFailed>(),
        ],
      );
    });

    group('executeQuery', () {
      const testMetadata = DatabaseMetadata(
        fullPath: '/path/test.db',
        sqliteVersion: '3.39.0',
        databaseSize: 1024,
        tables: ['users'],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [QueryExecuting, QueryResultLoaded] on success',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => const MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.executeQuery('SELECT * FROM users'),
        expect: () => [
          const QueryExecuting(
            metadata: testMetadata,
            query: 'SELECT * FROM users',
          ),
          isA<QueryResultLoaded>()
              .having((s) => s.query, 'query', 'SELECT * FROM users')
              .having((s) => s.columns, 'columns', ['id', 'name']),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits QueryResultLoaded with empty columns when no rows',
        build: () {
          final emptySource = MockSqliteViewerSource(
            selectResults: {'SELECT * FROM empty': []},
          );
          return SqliteViewerCubit(emptySource);
        },
        seed: () => const MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.executeQuery('SELECT * FROM empty'),
        expect: () => [
          const QueryExecuting(
            metadata: testMetadata,
            query: 'SELECT * FROM empty',
          ),
          isA<QueryResultLoaded>()
              .having((s) => s.columns, 'columns', isEmpty)
              .having((s) => s.rows, 'rows', isEmpty),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits ViewerConnectionFailed when not connected',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => const ViewerDisconnected(),
        act: (cubit) => cubit.executeQuery('SELECT 1'),
        expect: () => [
          isA<ViewerConnectionFailed>().having(
            (s) => s.failure,
            'failure',
            const ViewerDatabaseNotOpen(),
          ),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits QueryFailed for invalid query',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => const MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.executeQuery('DROP TABLE users'),
        expect: () => [
          isA<QueryFailed>().having(
            (s) => s.failure,
            'failure',
            isA<ViewerInvalidQuery>(),
          ),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits QueryFailed for empty query',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => const MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.executeQuery(''),
        expect: () => [
          isA<QueryFailed>(),
        ],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'emits [QueryExecuting, QueryFailed] when executeSelect fails',
        build: () {
          mockSource.executeSelectFailure = const ViewerQueryFailed(
            'SELECT',
            'error',
          );
          return SqliteViewerCubit(mockSource);
        },
        seed: () => const MetadataLoaded(metadata: testMetadata),
        act: (cubit) => cubit.executeQuery('SELECT * FROM users'),
        expect: () => [
          const QueryExecuting(
            metadata: testMetadata,
            query: 'SELECT * FROM users',
          ),
          isA<QueryFailed>().having(
            (s) => s.failure,
            'failure',
            isA<ViewerQueryFailed>(),
          ),
        ],
      );
    });

    group('_getCurrentMetadata from various states', () {
      const testMetadata = DatabaseMetadata(
        fullPath: '/path/test.db',
        sqliteVersion: '3.39.0',
        databaseSize: 1024,
        tables: ['users'],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'returns metadata from MetadataLoading',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => const MetadataLoading(metadata: testMetadata),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [const MetadataLoaded(metadata: testMetadata)],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'returns metadata from MetadataLoadFailed',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => const MetadataLoadFailed(
          failure: ViewerDatabaseNotOpen(),
          metadata: testMetadata,
        ),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [const MetadataLoaded(metadata: testMetadata)],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'returns metadata from TableDetailLoadFailed',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => const TableDetailLoadFailed(
          metadata: testMetadata,
          tableName: 'users',
          failure: ViewerTableNotFound('users'),
        ),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [const MetadataLoaded(metadata: testMetadata)],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'returns metadata from QueryExecuting',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => const QueryExecuting(
          metadata: testMetadata,
          query: 'SELECT 1',
        ),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [const MetadataLoaded(metadata: testMetadata)],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'returns metadata from QueryResultLoaded',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => const QueryResultLoaded(
          metadata: testMetadata,
          query: 'SELECT 1',
          columns: [],
          rows: [],
        ),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [const MetadataLoaded(metadata: testMetadata)],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'returns metadata from QueryFailed',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => const QueryFailed(
          metadata: testMetadata,
          query: 'SELECT 1',
          failure: ViewerQueryFailed('SELECT 1', 'error'),
        ),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [const MetadataLoaded(metadata: testMetadata)],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'returns null from ViewerConnecting',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => const ViewerConnecting(),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [],
      );

      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'returns null from ViewerConnectionFailed',
        build: () => SqliteViewerCubit(mockSource),
        seed: () => const ViewerConnectionFailed(
          failure: ViewerDatabaseNotOpen(),
        ),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [],
      );
    });
  });
}
