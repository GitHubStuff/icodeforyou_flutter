// test/src/cubit/sqlite_viewer_state_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

void main() {
  const metadata = DatabaseMetadata(
    fullPath: '/x.db',
    sqliteVersion: '3.0',
    databaseSize: 100,
    tables: ['users'],
  );

  group('ViewerDisconnected', () {
    test('is a SqliteViewerState', () {
      expect(const ViewerDisconnected(), isA<SqliteViewerState>());
    });

    test('props is empty', () {
      expect(const ViewerDisconnected().props, isEmpty);
    });

    test('equality holds', () {
      expect(const ViewerDisconnected(), equals(const ViewerDisconnected()));
    });
  });

  group('ViewerConnecting', () {
    test('is a SqliteViewerState', () {
      expect(const ViewerConnecting(), isA<SqliteViewerState>());
    });

    test('props is empty', () {
      expect(const ViewerConnecting().props, isEmpty);
    });

    test('equality holds', () {
      expect(const ViewerConnecting(), equals(const ViewerConnecting()));
    });
  });

  group('ViewerConnectionFailed', () {
    test('exposes failure', () {
      const state = ViewerConnectionFailed(failure: ViewerDatabaseNotOpen());
      expect(state.failure, isA<ViewerDatabaseNotOpen>());
    });

    test('props includes failure', () {
      const state = ViewerConnectionFailed(failure: ViewerDatabaseNotOpen());
      expect(state.props, [const ViewerDatabaseNotOpen()]);
    });

    test('equality respects failure', () {
      expect(
        const ViewerConnectionFailed(failure: ViewerDatabaseNotOpen()),
        equals(const ViewerConnectionFailed(failure: ViewerDatabaseNotOpen())),
      );
    });
  });

  group('MetadataLoading', () {
    test('exposes metadata', () {
      const state = MetadataLoading(metadata: metadata);
      expect(state.metadata, metadata);
    });

    test('props includes metadata', () {
      const state = MetadataLoading(metadata: metadata);
      expect(state.props, [metadata]);
    });
  });

  group('MetadataLoaded', () {
    test('exposes metadata', () {
      const state = MetadataLoaded(metadata: metadata);
      expect(state.metadata, metadata);
    });

    test('props includes metadata', () {
      const state = MetadataLoaded(metadata: metadata);
      expect(state.props, [metadata]);
    });
  });

  group('MetadataLoadFailed', () {
    test('exposes failure and metadata', () {
      const state = MetadataLoadFailed(
        failure: ViewerDatabaseNotOpen(),
        metadata: metadata,
      );
      expect(state.failure, isA<ViewerDatabaseNotOpen>());
      expect(state.metadata, metadata);
    });

    test('metadata is optional', () {
      const state = MetadataLoadFailed(failure: ViewerDatabaseNotOpen());
      expect(state.metadata, isNull);
    });

    test('props includes failure and metadata', () {
      const state = MetadataLoadFailed(
        failure: ViewerDatabaseNotOpen(),
        metadata: metadata,
      );
      expect(state.props, [const ViewerDatabaseNotOpen(), metadata]);
    });
  });

  group('TableDetailLoading', () {
    test('exposes metadata and tableName', () {
      const state = TableDetailLoading(
        metadata: metadata,
        tableName: 'users',
      );
      expect(state.metadata, metadata);
      expect(state.tableName, 'users');
    });

    test('props includes both fields', () {
      const state = TableDetailLoading(
        metadata: metadata,
        tableName: 'users',
      );
      expect(state.props, [metadata, 'users']);
    });
  });

  group('TableDetailLoaded', () {
    const state = TableDetailLoaded(
      metadata: metadata,
      tableName: 'users',
      columns: ['id', 'name'],
      tableInfo: [
        {'cid': 0, 'name': 'id'},
      ],
      indexList: [
        {'name': 'idx_id'},
      ],
      foreignKeys: [],
      rows: [
        {'id': 1, 'name': 'Alice'},
      ],
      rowCount: 1,
    );

    test('exposes all properties', () {
      expect(state.metadata, metadata);
      expect(state.tableName, 'users');
      expect(state.columns, ['id', 'name']);
      expect(state.tableInfo, hasLength(1));
      expect(state.indexList, hasLength(1));
      expect(state.foreignKeys, isEmpty);
      expect(state.rows, hasLength(1));
      expect(state.rowCount, 1);
    });

    test('props includes every field', () {
      expect(state.props, [
        metadata,
        'users',
        ['id', 'name'],
        [
          {'cid': 0, 'name': 'id'},
        ],
        [
          {'name': 'idx_id'},
        ],
        <Map<String, Object?>>[],
        [
          {'id': 1, 'name': 'Alice'},
        ],
        1,
      ]);
    });
  });

  group('TableDetailLoadFailed', () {
    test('exposes metadata, tableName, failure', () {
      const state = TableDetailLoadFailed(
        metadata: metadata,
        tableName: 'users',
        failure: ViewerDatabaseNotOpen(),
      );
      expect(state.metadata, metadata);
      expect(state.tableName, 'users');
      expect(state.failure, isA<ViewerDatabaseNotOpen>());
    });

    test('props includes all three fields', () {
      const state = TableDetailLoadFailed(
        metadata: metadata,
        tableName: 'users',
        failure: ViewerDatabaseNotOpen(),
      );
      expect(state.props, [metadata, 'users', const ViewerDatabaseNotOpen()]);
    });
  });

  group('QueryExecuting', () {
    test('exposes metadata and query', () {
      const state = QueryExecuting(metadata: metadata, query: 'SELECT 1');
      expect(state.metadata, metadata);
      expect(state.query, 'SELECT 1');
    });

    test('props includes both fields', () {
      const state = QueryExecuting(metadata: metadata, query: 'SELECT 1');
      expect(state.props, [metadata, 'SELECT 1']);
    });
  });

  group('QueryResultLoaded', () {
    const state = QueryResultLoaded(
      metadata: metadata,
      query: 'SELECT * FROM users',
      columns: ['id', 'name'],
      rows: [
        {'id': 1, 'name': 'a'},
        {'id': 2, 'name': 'b'},
      ],
    );

    test('exposes all fields', () {
      expect(state.metadata, metadata);
      expect(state.query, 'SELECT * FROM users');
      expect(state.columns, ['id', 'name']);
      expect(state.rows, hasLength(2));
    });

    test('rowCount derives from rows.length', () {
      expect(state.rowCount, 2);
    });

    test('rowCount is 0 when rows is empty', () {
      const empty = QueryResultLoaded(
        metadata: metadata,
        query: 'SELECT * FROM users',
        columns: [],
        rows: [],
      );
      expect(empty.rowCount, 0);
    });

    test('props includes metadata, query, columns, rows', () {
      expect(state.props, [
        metadata,
        'SELECT * FROM users',
        ['id', 'name'],
        [
          {'id': 1, 'name': 'a'},
          {'id': 2, 'name': 'b'},
        ],
      ]);
    });
  });

  group('QueryFailed', () {
    test('exposes metadata, query, failure', () {
      const state = QueryFailed(
        metadata: metadata,
        query: 'SELECT *',
        failure: ViewerDatabaseNotOpen(),
      );
      expect(state.metadata, metadata);
      expect(state.query, 'SELECT *');
      expect(state.failure, isA<ViewerDatabaseNotOpen>());
    });

    test('props includes all three fields', () {
      const state = QueryFailed(
        metadata: metadata,
        query: 'SELECT *',
        failure: ViewerDatabaseNotOpen(),
      );
      expect(state.props, [
        metadata,
        'SELECT *',
        const ViewerDatabaseNotOpen(),
      ]);
    });
  });
}
