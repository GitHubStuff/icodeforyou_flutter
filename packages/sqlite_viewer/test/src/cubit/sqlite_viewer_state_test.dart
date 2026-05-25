// test/src/cubit/sqlite_viewer_state_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

void main() {
  const testMetadata = DatabaseMetadata(
    fullPath: '/path/db.db',
    sqliteVersion: '3.39.0',
    databaseSize: 1024,
    tables: ['users', 'posts'],
  );

  const testFailure = ViewerDatabaseNotOpen();

  group('SqliteViewerState', () {
    group('ViewerDisconnected', () {
      test('has empty props', () {
        const state = ViewerDisconnected();
        expect(state.props, isEmpty);
      });

      test('equality works correctly', () {
        const state1 = ViewerDisconnected();
        const state2 = ViewerDisconnected();
        expect(state1, equals(state2));
      });
    });

    group('ViewerConnecting', () {
      test('has empty props', () {
        const state = ViewerConnecting();
        expect(state.props, isEmpty);
      });

      test('equality works correctly', () {
        const state1 = ViewerConnecting();
        const state2 = ViewerConnecting();
        expect(state1, equals(state2));
      });
    });

    group('ViewerConnectionFailed', () {
      test('stores failure', () {
        const state = ViewerConnectionFailed(failure: testFailure);
        expect(state.failure, testFailure);
      });

      test('props contains failure', () {
        const state = ViewerConnectionFailed(failure: testFailure);
        expect(state.props, [testFailure]);
      });

      test('equality works correctly', () {
        const state1 = ViewerConnectionFailed(failure: testFailure);
        const state2 = ViewerConnectionFailed(failure: testFailure);
        expect(state1, equals(state2));
      });

      test('different failures are not equal', () {
        const state1 = ViewerConnectionFailed(failure: testFailure);
        const state2 = ViewerConnectionFailed(
          failure: ViewerTableNotFound('users'),
        );
        expect(state1, isNot(equals(state2)));
      });
    });

    group('MetadataLoading', () {
      test('stores metadata', () {
        const state = MetadataLoading(metadata: testMetadata);
        expect(state.metadata, testMetadata);
      });

      test('props contains metadata', () {
        const state = MetadataLoading(metadata: testMetadata);
        expect(state.props, [testMetadata]);
      });

      test('equality works correctly', () {
        const state1 = MetadataLoading(metadata: testMetadata);
        const state2 = MetadataLoading(metadata: testMetadata);
        expect(state1, equals(state2));
      });
    });

    group('MetadataLoaded', () {
      test('stores metadata', () {
        const state = MetadataLoaded(metadata: testMetadata);
        expect(state.metadata, testMetadata);
      });

      test('props contains metadata', () {
        const state = MetadataLoaded(metadata: testMetadata);
        expect(state.props, [testMetadata]);
      });

      test('equality works correctly', () {
        const state1 = MetadataLoaded(metadata: testMetadata);
        const state2 = MetadataLoaded(metadata: testMetadata);
        expect(state1, equals(state2));
      });
    });

    group('MetadataLoadFailed', () {
      test('stores failure and metadata', () {
        const state = MetadataLoadFailed(
          failure: testFailure,
          metadata: testMetadata,
        );
        expect(state.failure, testFailure);
        expect(state.metadata, testMetadata);
      });

      test('metadata can be null', () {
        const state = MetadataLoadFailed(failure: testFailure);
        expect(state.metadata, isNull);
      });

      test('props contains failure and metadata', () {
        const state = MetadataLoadFailed(
          failure: testFailure,
          metadata: testMetadata,
        );
        expect(state.props, [testFailure, testMetadata]);
      });

      test('props contains failure and null', () {
        const state = MetadataLoadFailed(failure: testFailure);
        expect(state.props, [testFailure, null]);
      });

      test('equality works correctly', () {
        const state1 = MetadataLoadFailed(
          failure: testFailure,
          metadata: testMetadata,
        );
        const state2 = MetadataLoadFailed(
          failure: testFailure,
          metadata: testMetadata,
        );
        expect(state1, equals(state2));
      });
    });

    group('TableDetailLoading', () {
      test('stores metadata and tableName', () {
        const state = TableDetailLoading(
          metadata: testMetadata,
          tableName: 'users',
        );
        expect(state.metadata, testMetadata);
        expect(state.tableName, 'users');
      });

      test('props contains metadata and tableName', () {
        const state = TableDetailLoading(
          metadata: testMetadata,
          tableName: 'users',
        );
        expect(state.props, [testMetadata, 'users']);
      });

      test('equality works correctly', () {
        const state1 = TableDetailLoading(
          metadata: testMetadata,
          tableName: 'users',
        );
        const state2 = TableDetailLoading(
          metadata: testMetadata,
          tableName: 'users',
        );
        expect(state1, equals(state2));
      });
    });

    group('TableDetailLoaded', () {
      const columns = ['id', 'name'];
      const tableInfo = [
        {'cid': 0, 'name': 'id', 'type': 'INTEGER'},
      ];
      const indexList = [
        {'name': 'idx_1', 'unique': 1},
      ];
      const foreignKeys = [
        {'from': 'user_id', 'table': 'users'},
      ];
      const rows = [
        {'id': 1, 'name': 'Test'},
      ];

      test('stores all fields', () {
        const state = TableDetailLoaded(
          metadata: testMetadata,
          tableName: 'users',
          columns: columns,
          tableInfo: tableInfo,
          indexList: indexList,
          foreignKeys: foreignKeys,
          rows: rows,
          rowCount: 100,
        );
        expect(state.metadata, testMetadata);
        expect(state.tableName, 'users');
        expect(state.columns, columns);
        expect(state.tableInfo, tableInfo);
        expect(state.indexList, indexList);
        expect(state.foreignKeys, foreignKeys);
        expect(state.rows, rows);
        expect(state.rowCount, 100);
      });

      test('props contains all fields', () {
        const state = TableDetailLoaded(
          metadata: testMetadata,
          tableName: 'users',
          columns: columns,
          tableInfo: tableInfo,
          indexList: indexList,
          foreignKeys: foreignKeys,
          rows: rows,
          rowCount: 100,
        );
        expect(state.props, [
          testMetadata,
          'users',
          columns,
          tableInfo,
          indexList,
          foreignKeys,
          rows,
          100,
        ]);
      });

      test('equality works correctly', () {
        const state1 = TableDetailLoaded(
          metadata: testMetadata,
          tableName: 'users',
          columns: columns,
          tableInfo: tableInfo,
          indexList: indexList,
          foreignKeys: foreignKeys,
          rows: rows,
          rowCount: 100,
        );
        const state2 = TableDetailLoaded(
          metadata: testMetadata,
          tableName: 'users',
          columns: columns,
          tableInfo: tableInfo,
          indexList: indexList,
          foreignKeys: foreignKeys,
          rows: rows,
          rowCount: 100,
        );
        expect(state1, equals(state2));
      });
    });

    group('TableDetailLoadFailed', () {
      test('stores metadata, tableName, and failure', () {
        const state = TableDetailLoadFailed(
          metadata: testMetadata,
          tableName: 'users',
          failure: testFailure,
        );
        expect(state.metadata, testMetadata);
        expect(state.tableName, 'users');
        expect(state.failure, testFailure);
      });

      test('props contains all fields', () {
        const state = TableDetailLoadFailed(
          metadata: testMetadata,
          tableName: 'users',
          failure: testFailure,
        );
        expect(state.props, [testMetadata, 'users', testFailure]);
      });

      test('equality works correctly', () {
        const state1 = TableDetailLoadFailed(
          metadata: testMetadata,
          tableName: 'users',
          failure: testFailure,
        );
        const state2 = TableDetailLoadFailed(
          metadata: testMetadata,
          tableName: 'users',
          failure: testFailure,
        );
        expect(state1, equals(state2));
      });
    });

    group('QueryExecuting', () {
      test('stores metadata and query', () {
        const state = QueryExecuting(
          metadata: testMetadata,
          query: 'SELECT * FROM users',
        );
        expect(state.metadata, testMetadata);
        expect(state.query, 'SELECT * FROM users');
      });

      test('props contains metadata and query', () {
        const state = QueryExecuting(
          metadata: testMetadata,
          query: 'SELECT 1',
        );
        expect(state.props, [testMetadata, 'SELECT 1']);
      });

      test('equality works correctly', () {
        const state1 = QueryExecuting(
          metadata: testMetadata,
          query: 'SELECT 1',
        );
        const state2 = QueryExecuting(
          metadata: testMetadata,
          query: 'SELECT 1',
        );
        expect(state1, equals(state2));
      });
    });

    group('QueryResultLoaded', () {
      const columns = ['id', 'name'];
      const rows = [
        {'id': 1, 'name': 'Test'},
      ];

      test('stores all fields', () {
        const state = QueryResultLoaded(
          metadata: testMetadata,
          query: 'SELECT * FROM users',
          columns: columns,
          rows: rows,
        );
        expect(state.metadata, testMetadata);
        expect(state.query, 'SELECT * FROM users');
        expect(state.columns, columns);
        expect(state.rows, rows);
      });

      test('rowCount returns rows.length', () {
        const state = QueryResultLoaded(
          metadata: testMetadata,
          query: 'SELECT * FROM users',
          columns: columns,
          rows: rows,
        );
        expect(state.rowCount, 1);
      });

      test('rowCount returns 0 for empty rows', () {
        const state = QueryResultLoaded(
          metadata: testMetadata,
          query: 'SELECT * FROM users',
          columns: columns,
          rows: [],
        );
        expect(state.rowCount, 0);
      });

      test('props contains metadata, query, columns, and rows', () {
        const state = QueryResultLoaded(
          metadata: testMetadata,
          query: 'SELECT 1',
          columns: columns,
          rows: rows,
        );
        expect(state.props, [testMetadata, 'SELECT 1', columns, rows]);
      });

      test('equality works correctly', () {
        const state1 = QueryResultLoaded(
          metadata: testMetadata,
          query: 'SELECT 1',
          columns: columns,
          rows: rows,
        );
        const state2 = QueryResultLoaded(
          metadata: testMetadata,
          query: 'SELECT 1',
          columns: columns,
          rows: rows,
        );
        expect(state1, equals(state2));
      });
    });

    group('QueryFailed', () {
      test('stores metadata, query, and failure', () {
        const state = QueryFailed(
          metadata: testMetadata,
          query: 'SELECT * FROM users',
          failure: testFailure,
        );
        expect(state.metadata, testMetadata);
        expect(state.query, 'SELECT * FROM users');
        expect(state.failure, testFailure);
      });

      test('props contains all fields', () {
        const state = QueryFailed(
          metadata: testMetadata,
          query: 'SELECT 1',
          failure: testFailure,
        );
        expect(state.props, [testMetadata, 'SELECT 1', testFailure]);
      });

      test('equality works correctly', () {
        const state1 = QueryFailed(
          metadata: testMetadata,
          query: 'SELECT 1',
          failure: testFailure,
        );
        const state2 = QueryFailed(
          metadata: testMetadata,
          query: 'SELECT 1',
          failure: testFailure,
        );
        expect(state1, equals(state2));
      });
    });
  });
}
