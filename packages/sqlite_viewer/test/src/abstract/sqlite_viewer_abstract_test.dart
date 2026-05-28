// test/src/abstract/sqlite_viewer_abstract_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../helpers/mock_sqlite_viewer_source.dart';

void main() {
  group('SqliteViewerAbstract', () {
    test('MockSqliteViewerSource implements the interface', () {
      final source = MockSqliteViewerSource();
      expect(source, isA<SqliteViewerAbstract>());
    });

    test('returns Right with fullPath on success', () async {
      final source = MockSqliteViewerSource(fullPath: '/db/test.db');
      final result = await source.getFullPath();
      expect(result, isA<Right<SqliteViewerFailure, String>>());
      expect(
        result.match((_) => '', (p) => p),
        '/db/test.db',
      );
    });

    test('returns Left when getFullPathFailure is set', () async {
      final source = MockSqliteViewerSource()
        ..getFullPathFailure = const ViewerDatabaseNotOpen();
      final result = await source.getFullPath();
      expect(result, isA<Left<SqliteViewerFailure, String>>());
    });

    test('returns Right with sqliteVersion on success', () async {
      final source = MockSqliteViewerSource(sqliteVersion: '3.42.0');
      final result = await source.getSqliteVersion();
      expect(result.match((_) => '', (v) => v), '3.42.0');
    });

    test('returns Left when getSqliteVersionFailure is set', () async {
      final source = MockSqliteViewerSource()
        ..getSqliteVersionFailure =
            const ViewerMetadataFailed('version', 'boom');
      final result = await source.getSqliteVersion();
      expect(result.isLeft(), isTrue);
    });

    test('returns Right with databaseSize on success', () async {
      final source = MockSqliteViewerSource(databaseSize: 8192);
      final result = await source.getDatabaseSize();
      expect(result.match((_) => 0, (s) => s), 8192);
    });

    test('returns Left when getDatabaseSizeFailure is set', () async {
      final source = MockSqliteViewerSource()
        ..getDatabaseSizeFailure = const ViewerMetadataFailed('size', 'boom');
      final result = await source.getDatabaseSize();
      expect(result.isLeft(), isTrue);
    });

    test('returns Right with tableNames on success', () async {
      final source = MockSqliteViewerSource(tableNames: const ['a', 'b']);
      final result = await source.getTableNames();
      expect(result.match((_) => <String>[], (t) => t), ['a', 'b']);
    });

    test('returns Left when getTableNamesFailure is set', () async {
      final source = MockSqliteViewerSource()
        ..getTableNamesFailure = const ViewerMetadataFailed('tables', 'boom');
      final result = await source.getTableNames();
      expect(result.isLeft(), isTrue);
    });

    test('returns Right with rowCount when table exists', () async {
      final source = MockSqliteViewerSource(rowCounts: const {'users': 7});
      final result = await source.getRowCount('users');
      expect(result.match((_) => 0, (c) => c), 7);
    });

    test('returns Left ViewerTableNotFound for unknown table', () async {
      final source = MockSqliteViewerSource(rowCounts: const {'users': 7});
      final result = await source.getRowCount('missing');
      expect(result.isLeft(), isTrue);
      result.match(
        (f) => expect(f, isA<ViewerTableNotFound>()),
        (_) => fail('expected Left'),
      );
    });

    test('returns Left when getRowCountFailure is set', () async {
      final source = MockSqliteViewerSource()
        ..getRowCountFailure = const ViewerQueryFailed('q', 'err');
      final result = await source.getRowCount('users');
      expect(result.isLeft(), isTrue);
    });

    test('returns Right with columnNames when table exists', () async {
      final source = MockSqliteViewerSource(
        columnNamesMap: const {
          'users': ['id', 'name'],
        },
      );
      final result = await source.getColumnNames('users');
      expect(result.match((_) => <String>[], (c) => c), ['id', 'name']);
    });

    test('returns Left ViewerTableNotFound for unknown table columns',
        () async {
      final source = MockSqliteViewerSource(
        columnNamesMap: const {
          'users': ['id'],
        },
      );
      final result = await source.getColumnNames('missing');
      expect(result.isLeft(), isTrue);
      result.match(
        (f) => expect(f, isA<ViewerTableNotFound>()),
        (_) => fail('expected Left'),
      );
    });

    test('returns Left when getColumnNamesFailure is set', () async {
      final source = MockSqliteViewerSource()
        ..getColumnNamesFailure = const ViewerPragmaFailed('t', 'k', 'err');
      final result = await source.getColumnNames('users');
      expect(result.isLeft(), isTrue);
    });

    test('returns Right with pragma when keyed entry exists', () async {
      final source = MockSqliteViewerSource(
        pragmaResults: const {
          'users_tableInfo': [
            {'cid': 0},
          ],
        },
      );
      final result = await source.getPragma(
        tableName: 'users',
        key: PragmaKey.tableInfo,
      );
      expect(
        result.match((_) => <Map<String, Object?>>[], (r) => r),
        isNotEmpty,
      );
    });

    test('returns Right with empty list when pragma keyed entry missing',
        () async {
      final source = MockSqliteViewerSource();
      final result = await source.getPragma(
        tableName: 'users',
        key: PragmaKey.foreignKeyList,
      );
      expect(result.match((_) => <Map<String, Object?>>[], (r) => r), isEmpty);
    });

    test('returns Left when getPragmaFailure is set', () async {
      final source = MockSqliteViewerSource()
        ..getPragmaFailure = const ViewerPragmaFailed('t', 'k', 'err');
      final result = await source.getPragma(
        tableName: 'users',
        key: PragmaKey.tableInfo,
      );
      expect(result.isLeft(), isTrue);
    });

    test('returns Right rows for executeSelect on known query', () async {
      const sql = 'SELECT * FROM users';
      final source = MockSqliteViewerSource(
        selectResults: const {
          sql: [
            {'id': 1},
          ],
        },
      );
      final result = await source.executeSelect(sql);
      expect(
        result.match((_) => <Map<String, Object?>>[], (r) => r),
        isNotEmpty,
      );
    });

    test('returns Right with empty list for unknown query', () async {
      final source = MockSqliteViewerSource();
      final result = await source.executeSelect('SELECT * FROM unknown');
      expect(result.match((_) => <Map<String, Object?>>[], (r) => r), isEmpty);
    });

    test('returns Left when executeSelectFailure is set', () async {
      final source = MockSqliteViewerSource()
        ..executeSelectFailure = const ViewerQueryFailed('q', 'err');
      final result = await source.executeSelect('SELECT 1');
      expect(result.isLeft(), isTrue);
    });
  });
}
