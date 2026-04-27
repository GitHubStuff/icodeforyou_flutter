// test/src/models/database_metadata_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

void main() {
  group('DatabaseMetadata', () {
    const testMetadata = DatabaseMetadata(
      fullPath: '/data/user/0/com.icodeforyou/databases/app.db',
      sqliteVersion: '3.39.0',
      databaseSize: 524288,
      tables: ['users', 'posts', 'comments'],
    );

    test('creates instance with required fields', () {
      expect(
        testMetadata.fullPath,
        '/data/user/0/com.icodeforyou/databases/app.db',
      );
      expect(testMetadata.sqliteVersion, '3.39.0');
      expect(testMetadata.databaseSize, 524288);
      expect(testMetadata.tables, ['users', 'posts', 'comments']);
    });

    group('inMemoryToken', () {
      test('has correct value', () {
        expect(DatabaseMetadata.inMemoryToken, ':memory:');
      });
    });

    group('isInMemory', () {
      test('returns true for in-memory database', () {
        const inMemoryMetadata = DatabaseMetadata(
          fullPath: ':memory:',
          sqliteVersion: '3.39.0',
          databaseSize: 1024,
          tables: [],
        );
        expect(inMemoryMetadata.isInMemory, isTrue);
      });

      test('returns false for file-based database', () {
        expect(testMetadata.isInMemory, isFalse);
      });
    });

    group('tableCount', () {
      test('returns correct count', () {
        expect(testMetadata.tableCount, 3);
      });

      test('returns 0 for empty tables', () {
        const emptyMetadata = DatabaseMetadata(
          fullPath: '/path/db.db',
          sqliteVersion: '3.39.0',
          databaseSize: 0,
          tables: [],
        );
        expect(emptyMetadata.tableCount, 0);
      });
    });

    group('filename', () {
      test('returns filename from full path', () {
        expect(testMetadata.filename, 'app.db');
      });

      test('returns :memory: for in-memory database', () {
        const inMemoryMetadata = DatabaseMetadata(
          fullPath: ':memory:',
          sqliteVersion: '3.39.0',
          databaseSize: 1024,
          tables: [],
        );
        expect(inMemoryMetadata.filename, ':memory:');
      });

      test('returns full path when no separator', () {
        const noSeparatorMetadata = DatabaseMetadata(
          fullPath: 'database.db',
          sqliteVersion: '3.39.0',
          databaseSize: 1024,
          tables: [],
        );
        expect(noSeparatorMetadata.filename, 'database.db');
      });
    });

    group('formattedSize', () {
      test('formats bytes correctly', () {
        const bytesMetadata = DatabaseMetadata(
          fullPath: '/path/db.db',
          sqliteVersion: '3.39.0',
          databaseSize: 512,
          tables: [],
        );
        expect(bytesMetadata.formattedSize, '512 B');
      });

      test('formats kilobytes correctly', () {
        expect(testMetadata.formattedSize, '512.00 KB');
      });

      test('formats megabytes correctly', () {
        const mbMetadata = DatabaseMetadata(
          fullPath: '/path/db.db',
          sqliteVersion: '3.39.0',
          databaseSize: 5 * 1024 * 1024,
          tables: [],
        );
        expect(mbMetadata.formattedSize, '5.00 MB');
      });

      test('formats gigabytes correctly', () {
        const gbMetadata = DatabaseMetadata(
          fullPath: '/path/db.db',
          sqliteVersion: '3.39.0',
          databaseSize: 2 * 1024 * 1024 * 1024,
          tables: [],
        );
        expect(gbMetadata.formattedSize, '2.00 GB');
      });

      test('formats edge case at 1024 bytes', () {
        const edgeMetadata = DatabaseMetadata(
          fullPath: '/path/db.db',
          sqliteVersion: '3.39.0',
          databaseSize: 1024,
          tables: [],
        );
        expect(edgeMetadata.formattedSize, '1.00 KB');
      });

      test('formats edge case at 1MB', () {
        const edgeMetadata = DatabaseMetadata(
          fullPath: '/path/db.db',
          sqliteVersion: '3.39.0',
          databaseSize: 1024 * 1024,
          tables: [],
        );
        expect(edgeMetadata.formattedSize, '1.00 MB');
      });

      test('formats edge case at 1GB', () {
        const edgeMetadata = DatabaseMetadata(
          fullPath: '/path/db.db',
          sqliteVersion: '3.39.0',
          databaseSize: 1024 * 1024 * 1024,
          tables: [],
        );
        expect(edgeMetadata.formattedSize, '1.00 GB');
      });
    });

    group('copyWith', () {
      test('creates copy with all fields unchanged', () {
        final copy = testMetadata.copyWith();
        expect(copy.fullPath, testMetadata.fullPath);
        expect(copy.sqliteVersion, testMetadata.sqliteVersion);
        expect(copy.databaseSize, testMetadata.databaseSize);
        expect(copy.tables, testMetadata.tables);
      });

      test('creates copy with fullPath changed', () {
        final copy = testMetadata.copyWith(fullPath: '/new/path.db');
        expect(copy.fullPath, '/new/path.db');
        expect(copy.sqliteVersion, testMetadata.sqliteVersion);
        expect(copy.databaseSize, testMetadata.databaseSize);
        expect(copy.tables, testMetadata.tables);
      });

      test('creates copy with sqliteVersion changed', () {
        final copy = testMetadata.copyWith(sqliteVersion: '3.40.0');
        expect(copy.fullPath, testMetadata.fullPath);
        expect(copy.sqliteVersion, '3.40.0');
        expect(copy.databaseSize, testMetadata.databaseSize);
        expect(copy.tables, testMetadata.tables);
      });

      test('creates copy with databaseSize changed', () {
        final copy = testMetadata.copyWith(databaseSize: 1024);
        expect(copy.fullPath, testMetadata.fullPath);
        expect(copy.sqliteVersion, testMetadata.sqliteVersion);
        expect(copy.databaseSize, 1024);
        expect(copy.tables, testMetadata.tables);
      });

      test('creates copy with tables changed', () {
        final copy = testMetadata.copyWith(tables: ['new_table']);
        expect(copy.fullPath, testMetadata.fullPath);
        expect(copy.sqliteVersion, testMetadata.sqliteVersion);
        expect(copy.databaseSize, testMetadata.databaseSize);
        expect(copy.tables, ['new_table']);
      });

      test('creates copy with multiple fields changed', () {
        final copy = testMetadata.copyWith(
          fullPath: '/new.db',
          databaseSize: 2048,
        );
        expect(copy.fullPath, '/new.db');
        expect(copy.sqliteVersion, testMetadata.sqliteVersion);
        expect(copy.databaseSize, 2048);
        expect(copy.tables, testMetadata.tables);
      });
    });

    group('props', () {
      test('contains all fields', () {
        expect(testMetadata.props, [
          '/data/user/0/com.icodeforyou/databases/app.db',
          '3.39.0',
          524288,
          ['users', 'posts', 'comments'],
        ]);
      });
    });

    group('equality', () {
      test('equal instances are equal', () {
        const metadata1 = DatabaseMetadata(
          fullPath: '/path/db.db',
          sqliteVersion: '3.39.0',
          databaseSize: 1024,
          tables: ['users'],
        );
        const metadata2 = DatabaseMetadata(
          fullPath: '/path/db.db',
          sqliteVersion: '3.39.0',
          databaseSize: 1024,
          tables: ['users'],
        );
        expect(metadata1, equals(metadata2));
      });

      test('different instances are not equal', () {
        const metadata1 = DatabaseMetadata(
          fullPath: '/path/db.db',
          sqliteVersion: '3.39.0',
          databaseSize: 1024,
          tables: ['users'],
        );
        const metadata2 = DatabaseMetadata(
          fullPath: '/path/other.db',
          sqliteVersion: '3.39.0',
          databaseSize: 1024,
          tables: ['users'],
        );
        expect(metadata1, isNot(equals(metadata2)));
      });
    });

    group('toString', () {
      test('returns expected string representation', () {
        final str = testMetadata.toString();
        expect(str, contains('DatabaseMetadata('));
        expect(str, contains('fullPath:'));
        expect(str, contains('sqliteVersion:'));
        expect(str, contains('databaseSize:'));
        expect(str, contains('tables:'));
      });
    });
  });
}
