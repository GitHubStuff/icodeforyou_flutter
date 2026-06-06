// test/src/cubit/sqlite_viewer_cubit_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../helpers/mock_sqlite_viewer_source.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('SqliteViewerCubit construction', () {
    test('starts in ViewerDisconnected', () {
      final cubit = SqliteViewerCubit(MockSqliteViewerSource());
      expect(cubit.state, const ViewerDisconnected());
      cubit.close();
    });

    test('.seeded uses provided initial state', () {
      final cubit = SqliteViewerCubit.seeded(
        MockSqliteViewerSource(),
        const MetadataLoaded(metadata: testMetadata),
      );
      expect(cubit.state, const MetadataLoaded(metadata: testMetadata));
      cubit.close();
    });

    test('.withState uses provided initial state', () {
      final cubit = SqliteViewerCubit.withState(
        MockSqliteViewerSource(),
        const MetadataLoaded(metadata: testMetadata),
      );
      expect(cubit.state, const MetadataLoaded(metadata: testMetadata));
      cubit.close();
    });
  });

  group('connect', () {
    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits [ViewerConnecting, MetadataLoaded] on success',
      build: () => SqliteViewerCubit(createTestMockSource()),
      act: (cubit) => cubit.connect(),
      expect: () => [
        const ViewerConnecting(),
        const MetadataLoaded(metadata: testMetadata),
      ],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits [ViewerConnecting, ViewerConnectionFailed] when getFullPath fails',
      build: () {
        final source = createTestMockSource()
          ..getFullPathFailure = const ViewerDatabaseNotOpen();
        return SqliteViewerCubit(source);
      },
      act: (cubit) => cubit.connect(),
      expect: () => [
        const ViewerConnecting(),
        const ViewerConnectionFailed(failure: ViewerDatabaseNotOpen()),
      ],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits ViewerConnectionFailed when getSqliteVersion fails',
      build: () {
        final source = createTestMockSource()
          ..getSqliteVersionFailure =
              const ViewerMetadataFailed('version', 'boom');
        return SqliteViewerCubit(source);
      },
      act: (cubit) => cubit.connect(),
      expect: () => [
        const ViewerConnecting(),
        const ViewerConnectionFailed(
          failure: ViewerMetadataFailed('version', 'boom'),
        ),
      ],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits ViewerConnectionFailed when getDatabaseSize fails',
      build: () {
        final source = createTestMockSource()
          ..getDatabaseSizeFailure =
              const ViewerMetadataFailed('size', 'boom');
        return SqliteViewerCubit(source);
      },
      act: (cubit) => cubit.connect(),
      expect: () => [
        const ViewerConnecting(),
        const ViewerConnectionFailed(
          failure: ViewerMetadataFailed('size', 'boom'),
        ),
      ],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits ViewerConnectionFailed when getTableNames fails',
      build: () {
        final source = createTestMockSource()
          ..getTableNamesFailure =
              const ViewerMetadataFailed('tables', 'boom');
        return SqliteViewerCubit(source);
      },
      act: (cubit) => cubit.connect(),
      expect: () => [
        const ViewerConnecting(),
        const ViewerConnectionFailed(
          failure: ViewerMetadataFailed('tables', 'boom'),
        ),
      ],
    );
  });

  group('disconnect', () {
    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits ViewerDisconnected from any state',
      build: () => SqliteViewerCubit.seeded(
        createTestMockSource(),
        const MetadataLoaded(metadata: testMetadata),
      ),
      act: (cubit) => cubit.disconnect(),
      expect: () => [const ViewerDisconnected()],
    );
  });

  group('refreshMetadata', () {
    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits ViewerConnectionFailed when not connected',
      build: () => SqliteViewerCubit(createTestMockSource()),
      act: (cubit) => cubit.refreshMetadata(),
      expect: () => [
        const ViewerConnectionFailed(failure: ViewerDatabaseNotOpen()),
      ],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits [MetadataLoading, MetadataLoaded] on success',
      build: () => SqliteViewerCubit.seeded(
        createTestMockSource(),
        const MetadataLoaded(metadata: testMetadata),
      ),
      act: (cubit) => cubit.refreshMetadata(),
      expect: () => [
        const MetadataLoading(metadata: testMetadata),
        const MetadataLoaded(metadata: testMetadata),
      ],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits MetadataLoadFailed when refresh fails',
      build: () {
        final source = createTestMockSource()
          ..getFullPathFailure = const ViewerDatabaseNotOpen();
        return SqliteViewerCubit.seeded(
          source,
          const MetadataLoaded(metadata: testMetadata),
        );
      },
      act: (cubit) => cubit.refreshMetadata(),
      expect: () => [
        const MetadataLoading(metadata: testMetadata),
        const MetadataLoadFailed(
          failure: ViewerDatabaseNotOpen(),
          metadata: testMetadata,
        ),
      ],
    );
  });

  group('showMetadata', () {
    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits MetadataLoaded from TableDetailLoaded',
      build: () => SqliteViewerCubit.seeded(
        createTestMockSource(),
        const TableDetailLoaded(
          metadata: testMetadata,
          tableName: 'users',
          columns: ['id'],
          tableInfo: [],
          indexList: [],
          foreignKeys: [],
          rows: [],
          rowCount: 0,
        ),
      ),
      act: (cubit) => cubit.showMetadata(),
      expect: () => [const MetadataLoaded(metadata: testMetadata)],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits nothing when in ViewerDisconnected',
      build: () => SqliteViewerCubit(createTestMockSource()),
      act: (cubit) => cubit.showMetadata(),
      expect: () => <SqliteViewerState>[],
    );
  });

  group('selectTable', () {
    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits ViewerConnectionFailed when not connected',
      build: () => SqliteViewerCubit(createTestMockSource()),
      act: (cubit) => cubit.selectTable('users'),
      expect: () => [
        const ViewerConnectionFailed(failure: ViewerDatabaseNotOpen()),
      ],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits [TableDetailLoading, TableDetailLoaded] on success',
      build: () => SqliteViewerCubit.seeded(
        createTestMockSource(),
        const MetadataLoaded(metadata: testMetadata),
      ),
      act: (cubit) => cubit.selectTable('users'),
      expect: () => [
        const TableDetailLoading(
          metadata: testMetadata,
          tableName: 'users',
        ),
        const TableDetailLoaded(
          metadata: testMetadata,
          tableName: 'users',
          columns: ['id', 'name', 'email'],
          tableInfo: testTableInfo,
          indexList: testIndexList,
          foreignKeys: testForeignKeys,
          rows: testRows,
          rowCount: 10,
        ),
      ],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits TableDetailLoadFailed when getColumnNames fails',
      build: () {
        final source = createTestMockSource()
          ..getColumnNamesFailure = const ViewerTableNotFound('users');
        return SqliteViewerCubit.seeded(
          source,
          const MetadataLoaded(metadata: testMetadata),
        );
      },
      act: (cubit) => cubit.selectTable('users'),
      expect: () => [
        const TableDetailLoading(
          metadata: testMetadata,
          tableName: 'users',
        ),
        const TableDetailLoadFailed(
          metadata: testMetadata,
          tableName: 'users',
          failure: ViewerTableNotFound('users'),
        ),
      ],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits TableDetailLoadFailed when tableInfo pragma fails',
      build: () {
        final source = createTestMockSource()
          ..getPragmaFailure =
              const ViewerPragmaFailed('users', 'tableInfo', 'boom');
        return SqliteViewerCubit.seeded(
          source,
          const MetadataLoaded(metadata: testMetadata),
        );
      },
      act: (cubit) => cubit.selectTable('users'),
      expect: () => [
        const TableDetailLoading(
          metadata: testMetadata,
          tableName: 'users',
        ),
        const TableDetailLoadFailed(
          metadata: testMetadata,
          tableName: 'users',
          failure: ViewerPragmaFailed('users', 'tableInfo', 'boom'),
        ),
      ],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits TableDetailLoadFailed when getRowCount fails',
      build: () {
        // table missing in rowCounts triggers ViewerTableNotFound
        // from MockSqliteViewerSource.getRowCount.
        final source = MockSqliteViewerSource(
          tableNames: const ['phantom'],
          columnNamesMap: const {
            'phantom': ['id'],
          },
          pragmaResults: const {
            'phantom_tableInfo': [],
            'phantom_indexList': [],
            'phantom_foreignKeyList': [],
          },
        );
        return SqliteViewerCubit.seeded(
          source,
          const MetadataLoaded(metadata: testMetadata),
        );
      },
      act: (cubit) => cubit.selectTable('phantom'),
      expect: () => [
        const TableDetailLoading(
          metadata: testMetadata,
          tableName: 'phantom',
        ),
        const TableDetailLoadFailed(
          metadata: testMetadata,
          tableName: 'phantom',
          failure: ViewerTableNotFound('phantom'),
        ),
      ],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits TableDetailLoadFailed when executeSelect for SELECT * fails',
      build: () {
        final source = createTestMockSource()
          ..executeSelectFailure =
              const ViewerQueryFailed('SELECT * FROM "users"', 'boom');
        return SqliteViewerCubit.seeded(
          source,
          const MetadataLoaded(metadata: testMetadata),
        );
      },
      act: (cubit) => cubit.selectTable('users'),
      expect: () => [
        const TableDetailLoading(
          metadata: testMetadata,
          tableName: 'users',
        ),
        const TableDetailLoadFailed(
          metadata: testMetadata,
          tableName: 'users',
          failure: ViewerQueryFailed('SELECT * FROM "users"', 'boom'),
        ),
      ],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits TableDetailLoadFailed when indexList pragma fails',
      build: () {
        // tableInfo succeeds, indexList fails — exercises the indexList
        // Left branch that a global getPragmaFailure can never reach.
        final source = createTestMockSource()
          ..pragmaKeyFailures = const {
            PragmaKey.indexList:
                ViewerPragmaFailed('users', 'indexList', 'boom'),
          };
        return SqliteViewerCubit.seeded(
          source,
          const MetadataLoaded(metadata: testMetadata),
        );
      },
      act: (cubit) => cubit.selectTable('users'),
      expect: () => [
        const TableDetailLoading(
          metadata: testMetadata,
          tableName: 'users',
        ),
        const TableDetailLoadFailed(
          metadata: testMetadata,
          tableName: 'users',
          failure: ViewerPragmaFailed('users', 'indexList', 'boom'),
        ),
      ],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits TableDetailLoadFailed when foreignKeyList pragma fails',
      build: () {
        // tableInfo and indexList succeed, foreignKeyList fails —
        // exercises the foreignKeyList Left branch.
        final source = createTestMockSource()
          ..pragmaKeyFailures = const {
            PragmaKey.foreignKeyList:
                ViewerPragmaFailed('users', 'foreignKeyList', 'boom'),
          };
        return SqliteViewerCubit.seeded(
          source,
          const MetadataLoaded(metadata: testMetadata),
        );
      },
      act: (cubit) => cubit.selectTable('users'),
      expect: () => [
        const TableDetailLoading(
          metadata: testMetadata,
          tableName: 'users',
        ),
        const TableDetailLoadFailed(
          metadata: testMetadata,
          tableName: 'users',
          failure: ViewerPragmaFailed('users', 'foreignKeyList', 'boom'),
        ),
      ],
    );
  });

  group('executeQuery', () {
    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits ViewerConnectionFailed when not connected',
      build: () => SqliteViewerCubit(createTestMockSource()),
      act: (cubit) => cubit.executeQuery('SELECT 1'),
      expect: () => [
        const ViewerConnectionFailed(failure: ViewerDatabaseNotOpen()),
      ],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits QueryFailed for invalid query (validation)',
      build: () => SqliteViewerCubit.seeded(
        createTestMockSource(),
        const MetadataLoaded(metadata: testMetadata),
      ),
      act: (cubit) => cubit.executeQuery('DROP TABLE users'),
      expect: () => [
        isA<QueryFailed>()
            .having((s) => s.query, 'query', 'DROP TABLE users')
            .having(
              (s) => s.failure,
              'failure',
              isA<ViewerInvalidQuery>(),
            ),
      ],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits [QueryExecuting, QueryResultLoaded] for valid SELECT',
      build: () {
        final source = MockSqliteViewerSource(
          tableNames: const ['users'],
          rowCounts: const {'users': 2},
          columnNamesMap: const {
            'users': ['id', 'name'],
          },
          selectResults: const {
            'SELECT * FROM users': [
              {'id': 1, 'name': 'Alice'},
              {'id': 2, 'name': 'Bob'},
            ],
          },
        );
        return SqliteViewerCubit.seeded(
          source,
          const MetadataLoaded(metadata: testMetadata),
        );
      },
      act: (cubit) => cubit.executeQuery('SELECT * FROM users'),
      expect: () => [
        const QueryExecuting(
          metadata: testMetadata,
          query: 'SELECT * FROM users',
        ),
        const QueryResultLoaded(
          metadata: testMetadata,
          query: 'SELECT * FROM users',
          columns: ['id', 'name'],
          rows: [
            {'id': 1, 'name': 'Alice'},
            {'id': 2, 'name': 'Bob'},
          ],
        ),
      ],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits QueryResultLoaded with empty columns when rows are empty',
      build: () => SqliteViewerCubit.seeded(
        createTestMockSource(),
        const MetadataLoaded(metadata: testMetadata),
      ),
      act: (cubit) => cubit.executeQuery('SELECT * FROM empty_table'),
      expect: () => [
        const QueryExecuting(
          metadata: testMetadata,
          query: 'SELECT * FROM empty_table',
        ),
        const QueryResultLoaded(
          metadata: testMetadata,
          query: 'SELECT * FROM empty_table',
          columns: [],
          rows: [],
        ),
      ],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'emits QueryFailed when executeSelect fails',
      build: () {
        final source = createTestMockSource()
          ..executeSelectFailure =
              const ViewerQueryFailed('SELECT * FROM users', 'boom');
        return SqliteViewerCubit.seeded(
          source,
          const MetadataLoaded(metadata: testMetadata),
        );
      },
      act: (cubit) => cubit.executeQuery('SELECT * FROM users'),
      expect: () => [
        const QueryExecuting(
          metadata: testMetadata,
          query: 'SELECT * FROM users',
        ),
        const QueryFailed(
          metadata: testMetadata,
          query: 'SELECT * FROM users',
          failure: ViewerQueryFailed('SELECT * FROM users', 'boom'),
        ),
      ],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'trims whitespace in validated query',
      build: () => SqliteViewerCubit.seeded(
        createTestMockSource(),
        const MetadataLoaded(metadata: testMetadata),
      ),
      act: (cubit) => cubit.executeQuery('  SELECT * FROM users  '),
      expect: () => [
        const QueryExecuting(
          metadata: testMetadata,
          query: 'SELECT * FROM users',
        ),
        // executeSelect for 'SELECT * FROM users' returns testRows in mock
        const QueryResultLoaded(
          metadata: testMetadata,
          query: 'SELECT * FROM users',
          columns: ['id', 'name', 'email'],
          rows: testRows,
        ),
      ],
    );
  });

  group('_getCurrentMetadata across all state types', () {
    // Indirect coverage of the switch arms — exercise each by sending
    // an action that hits _getCurrentMetadata from that state.
    for (final entry in <String, SqliteViewerState>{
      'MetadataLoading': const MetadataLoading(metadata: testMetadata),
      'MetadataLoaded': const MetadataLoaded(metadata: testMetadata),
      'MetadataLoadFailed': const MetadataLoadFailed(
        failure: ViewerDatabaseNotOpen(),
        metadata: testMetadata,
      ),
      'TableDetailLoading': const TableDetailLoading(
        metadata: testMetadata,
        tableName: 'users',
      ),
      'TableDetailLoaded': const TableDetailLoaded(
        metadata: testMetadata,
        tableName: 'users',
        columns: [],
        tableInfo: [],
        indexList: [],
        foreignKeys: [],
        rows: [],
        rowCount: 0,
      ),
      'TableDetailLoadFailed': const TableDetailLoadFailed(
        metadata: testMetadata,
        tableName: 'users',
        failure: ViewerDatabaseNotOpen(),
      ),
      'QueryExecuting': const QueryExecuting(
        metadata: testMetadata,
        query: 'SELECT 1',
      ),
      'QueryResultLoaded': const QueryResultLoaded(
        metadata: testMetadata,
        query: 'SELECT 1',
        columns: [],
        rows: [],
      ),
      'QueryFailed': const QueryFailed(
        metadata: testMetadata,
        query: 'SELECT 1',
        failure: ViewerDatabaseNotOpen(),
      ),
    }.entries) {
      blocTest<SqliteViewerCubit, SqliteViewerState>(
        'showMetadata transitions to MetadataLoaded from ${entry.key}',
        build: () => SqliteViewerCubit.seeded(
          createTestMockSource(),
          entry.value,
        ),
        act: (cubit) => cubit.showMetadata(),
        expect: () => [const MetadataLoaded(metadata: testMetadata)],
      );
    }

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'showMetadata emits nothing from ViewerConnecting',
      build: () => SqliteViewerCubit.seeded(
        createTestMockSource(),
        const ViewerConnecting(),
      ),
      act: (cubit) => cubit.showMetadata(),
      expect: () => <SqliteViewerState>[],
    );

    blocTest<SqliteViewerCubit, SqliteViewerState>(
      'showMetadata emits nothing from ViewerConnectionFailed',
      build: () => SqliteViewerCubit.seeded(
        createTestMockSource(),
        const ViewerConnectionFailed(failure: ViewerDatabaseNotOpen()),
      ),
      act: (cubit) => cubit.showMetadata(),
      expect: () => <SqliteViewerState>[],
    );
  });
}
