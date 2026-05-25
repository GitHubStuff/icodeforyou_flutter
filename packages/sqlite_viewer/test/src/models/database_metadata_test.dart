// packages/sqlite_viewer/test/src/models/database_metadata_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/src/models/database_metadata.dart';

void main() {
  const baseMetadata = DatabaseMetadata(
    fullPath: '/data/user/0/com.icodeforyou/databases/app.db',
    sqliteVersion: '3.45.0',
    databaseSize: 2048,
    tables: ['users', 'posts', 'comments'],
  );

  group('DatabaseMetadata.isInMemory', () {
    test('is true when fullPath is :memory:', () {
      const metadata = DatabaseMetadata(
        fullPath: DatabaseMetadata.inMemoryToken,
        sqliteVersion: '3.45.0',
        databaseSize: 0,
        tables: [],
      );

      expect(metadata.isInMemory, isTrue);
    });

    test('is false for a file-backed path', () {
      expect(baseMetadata.isInMemory, isFalse);
    });
  });

  group('DatabaseMetadata.tableCount', () {
    test('returns the length of tables', () {
      expect(baseMetadata.tableCount, 3);
    });
  });

  group('DatabaseMetadata.filename', () {
    test('returns :memory: for in-memory databases', () {
      const metadata = DatabaseMetadata(
        fullPath: DatabaseMetadata.inMemoryToken,
        sqliteVersion: '3.45.0',
        databaseSize: 0,
        tables: [],
      );

      expect(metadata.filename, DatabaseMetadata.inMemoryToken);
    });

    test('returns the segment after the last / for a full path', () {
      expect(baseMetadata.filename, 'app.db');
    });

    test('returns the full path when no separator is present', () {
      const metadata = DatabaseMetadata(
        fullPath: 'app.db',
        sqliteVersion: '3.45.0',
        databaseSize: 0,
        tables: [],
      );

      expect(metadata.filename, 'app.db');
    });
  });

  group('DatabaseMetadata.formattedSize', () {
    test('formats bytes when size is below 1 KB', () {
      const metadata = DatabaseMetadata(
        fullPath: '/tmp/x.db',
        sqliteVersion: '3.45.0',
        databaseSize: 512,
        tables: [],
      );

      expect(metadata.formattedSize, '512 B');
    });

    test('formats kilobytes when size is below 1 MB', () {
      const metadata = DatabaseMetadata(
        fullPath: '/tmp/x.db',
        sqliteVersion: '3.45.0',
        databaseSize: 2048,
        tables: [],
      );

      expect(metadata.formattedSize, '2.00 KB');
    });

    test('formats megabytes when size is below 1 GB', () {
      const metadata = DatabaseMetadata(
        fullPath: '/tmp/x.db',
        sqliteVersion: '3.45.0',
        databaseSize: 5 * 1024 * 1024,
        tables: [],
      );

      expect(metadata.formattedSize, '5.00 MB');
    });

    test('formats gigabytes at or above 1 GB', () {
      const metadata = DatabaseMetadata(
        fullPath: '/tmp/x.db',
        sqliteVersion: '3.45.0',
        databaseSize: 2 * 1024 * 1024 * 1024,
        tables: [],
      );

      expect(metadata.formattedSize, '2.00 GB');
    });
  });

  group('DatabaseMetadata.copyWith', () {
    test('returns an equal copy when no overrides are supplied', () {
      final copy = baseMetadata.copyWith();

      expect(copy, equals(baseMetadata));
      expect(identical(copy, baseMetadata), isFalse);
    });

    test('overrides fullPath only', () {
      final copy = baseMetadata.copyWith(fullPath: '/tmp/other.db');

      expect(copy.fullPath, '/tmp/other.db');
      expect(copy.sqliteVersion, baseMetadata.sqliteVersion);
      expect(copy.databaseSize, baseMetadata.databaseSize);
      expect(copy.tables, baseMetadata.tables);
    });

    test('overrides sqliteVersion only', () {
      final copy = baseMetadata.copyWith(sqliteVersion: '3.50.0');

      expect(copy.fullPath, baseMetadata.fullPath);
      expect(copy.sqliteVersion, '3.50.0');
      expect(copy.databaseSize, baseMetadata.databaseSize);
      expect(copy.tables, baseMetadata.tables);
    });

    test('overrides databaseSize only', () {
      final copy = baseMetadata.copyWith(databaseSize: 9999);

      expect(copy.fullPath, baseMetadata.fullPath);
      expect(copy.sqliteVersion, baseMetadata.sqliteVersion);
      expect(copy.databaseSize, 9999);
      expect(copy.tables, baseMetadata.tables);
    });

    test('overrides tables only', () {
      final copy = baseMetadata.copyWith(tables: const ['x', 'y']);

      expect(copy.fullPath, baseMetadata.fullPath);
      expect(copy.sqliteVersion, baseMetadata.sqliteVersion);
      expect(copy.databaseSize, baseMetadata.databaseSize);
      expect(copy.tables, const ['x', 'y']);
    });
  });
}
