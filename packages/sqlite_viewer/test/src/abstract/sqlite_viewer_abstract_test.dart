// test/src/abstract/sqlite_viewer_abstract_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../helpers/mock_sqlite_viewer_source.dart';

void main() {
  group('SqliteViewerAbstract', () {
    // Tests that the abstract class contract is properly implemented
    // by using the mock implementation

    late MockSqliteViewerSource source;

    setUp(() {
      source = MockSqliteViewerSource(
        fullPath: '/data/test.db',
        sqliteVersion: '3.40.0',
        databaseSize: 2048,
        tableNames: ['users', 'products'],
        rowCounts: {'users': 50, 'products': 100},
        columnNamesMap: {
          'users': ['id', 'name'],
          'products': ['id', 'title', 'price'],
        },
        pragmaResults: {
          'users_tableInfo': [
            {'cid': 0, 'name': 'id', 'type': 'INTEGER'},
          ],
        },
        selectResults: {
          'SELECT 1': [
            {'1': 1},
          ],
        },
      );
    });

    group('getFullPath', () {
      test('returns Right with path on success', () async {
        final result = await source.getFullPath();

        expect(result.isRight(), isTrue);
        expect(result.getOrElse((_) => ''), '/data/test.db');
      });

      test('returns Left with failure on error', () async {
        source.getFullPathFailure = const ViewerDatabaseNotOpen();

        final result = await source.getFullPath();

        expect(result.isLeft(), isTrue);
        result.match(
          (failure) => expect(failure, const ViewerDatabaseNotOpen()),
          (_) => fail('Should be Left'),
        );
      });
    });

    group('getSqliteVersion', () {
      test('returns Right with version on success', () async {
        final result = await source.getSqliteVersion();

        expect(result.isRight(), isTrue);
        expect(result.getOrElse((_) => ''), '3.40.0');
      });

      test('returns Left with failure on error', () async {
        source.getSqliteVersionFailure =
            const ViewerMetadataFailed('version', 'error');

        final result = await source.getSqliteVersion();

        expect(result.isLeft(), isTrue);
      });
    });

    group('getDatabaseSize', () {
      test('returns Right with size on success', () async {
        final result = await source.getDatabaseSize();

        expect(result.isRight(), isTrue);
        expect(result.getOrElse((_) => 0), 2048);
      });

      test('returns Left with failure on error', () async {
        source.getDatabaseSizeFailure =
            const ViewerMetadataFailed('size', 'error');

        final result = await source.getDatabaseSize();

        expect(result.isLeft(), isTrue);
      });
    });

    group('getTableNames', () {
      test('returns Right with table names on success', () async {
        final result = await source.getTableNames();

        expect(result.isRight(), isTrue);
        expect(result.getOrElse((_) => []), ['users', 'products']);
      });

      test('returns Left with failure on error', () async {
        source.getTableNamesFailure =
            const ViewerMetadataFailed('tables', 'error');

        final result = await source.getTableNames();

        expect(result.isLeft(), isTrue);
      });
    });

    group('getRowCount', () {
      test('returns Right with count on success', () async {
        final result = await source.getRowCount('users');

        expect(result.isRight(), isTrue);
        expect(result.getOrElse((_) => 0), 50);
      });

      test('returns Left with TableNotFound for unknown table', () async {
        final result = await source.getRowCount('unknown');

        expect(result.isLeft(), isTrue);
        result.match(
          (failure) => expect(failure, isA<ViewerTableNotFound>()),
          (_) => fail('Should be Left'),
        );
      });

      test('returns Left with failure on error', () async {
        source.getRowCountFailure =
            const ViewerQueryFailed('COUNT', 'error');

        final result = await source.getRowCount('users');

        expect(result.isLeft(), isTrue);
      });
    });

    group('getColumnNames', () {
      test('returns Right with column names on success', () async {
        final result = await source.getColumnNames('users');

        expect(result.isRight(), isTrue);
        expect(result.getOrElse((_) => []), ['id', 'name']);
      });

      test('returns Left with TableNotFound for unknown table', () async {
        final result = await source.getColumnNames('unknown');

        expect(result.isLeft(), isTrue);
        result.match(
          (failure) => expect(failure, isA<ViewerTableNotFound>()),
          (_) => fail('Should be Left'),
        );
      });

      test('returns Left with failure on error', () async {
        source.getColumnNamesFailure = const ViewerTableNotFound('users');

        final result = await source.getColumnNames('users');

        expect(result.isLeft(), isTrue);
      });
    });

    group('getPragma', () {
      test('returns Right with pragma results on success', () async {
        final result = await source.getPragma(
          tableName: 'users',
          key: PragmaKey.tableInfo,
        );

        expect(result.isRight(), isTrue);
        final data = result.getOrElse((_) => []);
        expect(data.length, 1);
        expect(data.first['name'], 'id');
      });

      test('returns empty list for unknown pragma key', () async {
        final result = await source.getPragma(
          tableName: 'users',
          key: PragmaKey.indexList,
        );

        expect(result.isRight(), isTrue);
        expect(result.getOrElse((_) => [{'x': 1}]), isEmpty);
      });

      test('returns Left with failure on error', () async {
        source.getPragmaFailure =
            const ViewerPragmaFailed('users', 'table_info', 'error');

        final result = await source.getPragma(
          tableName: 'users',
          key: PragmaKey.tableInfo,
        );

        expect(result.isLeft(), isTrue);
      });
    });

    group('executeSelect', () {
      test('returns Right with results on success', () async {
        final result = await source.executeSelect('SELECT 1');

        expect(result.isRight(), isTrue);
        final data = result.getOrElse((_) => []);
        expect(data.length, 1);
        expect(data.first['1'], 1);
      });

      test('returns empty list for unknown query', () async {
        final result = await source.executeSelect('SELECT * FROM unknown');

        expect(result.isRight(), isTrue);
        expect(result.getOrElse((_) => [{'x': 1}]), isEmpty);
      });

      test('returns Left with failure on error', () async {
        source.executeSelectFailure =
            const ViewerQueryFailed('SELECT', 'error');

        final result = await source.executeSelect('SELECT 1');

        expect(result.isLeft(), isTrue);
      });
    });

    group('type checks', () {
      test('MockSqliteViewerSource implements SqliteViewerAbstract', () {
        expect(source, isA<SqliteViewerAbstract>());
      });
    });
  });
}
