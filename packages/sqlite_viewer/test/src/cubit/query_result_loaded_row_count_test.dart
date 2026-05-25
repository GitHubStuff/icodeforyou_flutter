// packages/sqlite_viewer/test/src/cubit/query_result_loaded_row_count_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/src/cubit/sqlite_viewer_state.dart';
import 'package:sqlite_viewer/src/models/database_metadata.dart';

void main() {
  group('QueryResultLoaded.rowCount', () {
    const metadata = DatabaseMetadata(
      fullPath: '/tmp/test.db',
      sqliteVersion: '3.45.0',
      databaseSize: 1024,
      tables: ['users'],
    );

    test('returns rows.length for a populated result set', () {
      const state = QueryResultLoaded(
        metadata: metadata,
        query: 'SELECT id, name FROM users',
        columns: ['id', 'name'],
        rows: [
          {'id': 1, 'name': 'Alice'},
          {'id': 2, 'name': 'Bob'},
          {'id': 3, 'name': 'Carol'},
        ],
      );

      expect(state.rowCount, 3);
    });

    test('returns 0 for an empty result set', () {
      const state = QueryResultLoaded(
        metadata: metadata,
        query: 'SELECT id FROM users WHERE 1 = 0',
        columns: ['id'],
        rows: [],
      );

      expect(state.rowCount, 0);
    });
  });
}
