// test/sqlite_viewer_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

void main() {
  group('sqlite_viewer library exports', () {
    test('exports SqliteViewerAbstract type', () {
      expect(SqliteViewerAbstract, isNotNull);
    });

    test('exports SqliteViewerCubit type', () {
      expect(SqliteViewerCubit, isNotNull);
    });

    test('exports state types', () {
      expect(const ViewerDisconnected(), isA<SqliteViewerState>());
      expect(const ViewerConnecting(), isA<SqliteViewerState>());
    });

    test('exports failure types', () {
      expect(const ViewerDatabaseNotOpen(), isA<SqliteViewerFailure>());
    });

    test('exports model types', () {
      expect(
        const DatabaseMetadata(
          fullPath: '/x.db',
          sqliteVersion: '3.0',
          databaseSize: 100,
          tables: [],
        ),
        isA<DatabaseMetadata>(),
      );
      expect(PragmaKey.tableInfo, isA<PragmaKey>());
      expect(TextHandling.trunc, isA<TextHandling>());
    });

    test('exports widget types', () {
      expect(DisplayQueryWidget, isNotNull);
      expect(SqlCommand, isNotNull);
      expect(SqliteViewerMetadataPanel, isNotNull);
      expect(SqliteViewerPage, isNotNull);
      expect(SqliteViewerTableDetail, isNotNull);
    });
  });
}
