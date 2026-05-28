// test/src/models/database_metadata_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

void main() {
  group('DatabaseMetadata constructor', () {
    test('stores all properties', () {
      const metadata = DatabaseMetadata(
        fullPath: '/x/y.db',
        sqliteVersion: '3.39.0',
        databaseSize: 2048,
        tables: ['users', 'posts'],
      );
      expect(metadata.fullPath, '/x/y.db');
      expect(metadata.sqliteVersion, '3.39.0');
      expect(metadata.databaseSize, 2048);
      expect(metadata.tables, ['users', 'posts']);
    });
  });

  group('isInMemory', () {
    test('returns true when fullPath is :memory:', () {
      const metadata = DatabaseMetadata(
        fullPath: ':memory:',
        sqliteVersion: '3.0',
        databaseSize: 0,
        tables: [],
      );
      expect(metadata.isInMemory, isTrue);
    });

    test('returns false for file paths', () {
      const metadata = DatabaseMetadata(
        fullPath: '/x/y.db',
        sqliteVersion: '3.0',
        databaseSize: 0,
        tables: [],
      );
      expect(metadata.isInMemory, isFalse);
    });
  });

  group('inMemoryToken', () {
    test('is :memory:', () {
      expect(DatabaseMetadata.inMemoryToken, ':memory:');
    });
  });

  group('tableCount', () {
    test('matches tables.length', () {
      const metadata = DatabaseMetadata(
        fullPath: '/x.db',
        sqliteVersion: '3.0',
        databaseSize: 0,
        tables: ['a', 'b', 'c'],
      );
      expect(metadata.tableCount, 3);
    });

    test('is 0 for empty tables', () {
      const metadata = DatabaseMetadata(
        fullPath: '/x.db',
        sqliteVersion: '3.0',
        databaseSize: 0,
        tables: [],
      );
      expect(metadata.tableCount, 0);
    });
  });

  group('filename', () {
    test('returns :memory: for in-memory db', () {
      const metadata = DatabaseMetadata(
        fullPath: ':memory:',
        sqliteVersion: '3.0',
        databaseSize: 0,
        tables: [],
      );
      expect(metadata.filename, ':memory:');
    });

    test('extracts filename from path with slashes', () {
      const metadata = DatabaseMetadata(
        fullPath: '/data/user/0/com.example/databases/app.db',
        sqliteVersion: '3.0',
        databaseSize: 0,
        tables: [],
      );
      expect(metadata.filename, 'app.db');
    });

    test('returns fullPath when no separator present', () {
      const metadata = DatabaseMetadata(
        fullPath: 'app.db',
        sqliteVersion: '3.0',
        databaseSize: 0,
        tables: [],
      );
      expect(metadata.filename, 'app.db');
    });
  });

  group('formattedSize', () {
    test('formats bytes below 1024 as B', () {
      const metadata = DatabaseMetadata(
        fullPath: '/x.db',
        sqliteVersion: '3.0',
        databaseSize: 512,
        tables: [],
      );
      expect(metadata.formattedSize, '512 B');
    });

    test('formats kilobytes', () {
      const metadata = DatabaseMetadata(
        fullPath: '/x.db',
        sqliteVersion: '3.0',
        databaseSize: 2048,
        tables: [],
      );
      expect(metadata.formattedSize, '2.00 KB');
    });

    test('formats megabytes', () {
      const metadata = DatabaseMetadata(
        fullPath: '/x.db',
        sqliteVersion: '3.0',
        databaseSize: 5 * 1024 * 1024,
        tables: [],
      );
      expect(metadata.formattedSize, '5.00 MB');
    });

    test('formats gigabytes', () {
      const metadata = DatabaseMetadata(
        fullPath: '/x.db',
        sqliteVersion: '3.0',
        databaseSize: 3 * 1024 * 1024 * 1024,
        tables: [],
      );
      expect(metadata.formattedSize, '3.00 GB');
    });

    test('handles zero bytes', () {
      const metadata = DatabaseMetadata(
        fullPath: '/x.db',
        sqliteVersion: '3.0',
        databaseSize: 0,
        tables: [],
      );
      expect(metadata.formattedSize, '0 B');
    });

    test('handles boundary at 1024 bytes', () {
      const metadata = DatabaseMetadata(
        fullPath: '/x.db',
        sqliteVersion: '3.0',
        databaseSize: 1024,
        tables: [],
      );
      expect(metadata.formattedSize, '1.00 KB');
    });
  });

  group('copyWith', () {
    const base = DatabaseMetadata(
      fullPath: '/x.db',
      sqliteVersion: '3.0',
      databaseSize: 100,
      tables: ['a'],
    );

    test('returns identical instance with no params', () {
      expect(base.copyWith(), equals(base));
    });

    test('overrides fullPath only', () {
      final copy = base.copyWith(fullPath: '/y.db');
      expect(copy.fullPath, '/y.db');
      expect(copy.sqliteVersion, base.sqliteVersion);
      expect(copy.databaseSize, base.databaseSize);
      expect(copy.tables, base.tables);
    });

    test('overrides sqliteVersion only', () {
      final copy = base.copyWith(sqliteVersion: '3.42.0');
      expect(copy.sqliteVersion, '3.42.0');
      expect(copy.fullPath, base.fullPath);
    });

    test('overrides databaseSize only', () {
      final copy = base.copyWith(databaseSize: 2000);
      expect(copy.databaseSize, 2000);
      expect(copy.fullPath, base.fullPath);
    });

    test('overrides tables only', () {
      final copy = base.copyWith(tables: const ['b', 'c']);
      expect(copy.tables, ['b', 'c']);
      expect(copy.fullPath, base.fullPath);
    });

    test('overrides all fields at once', () {
      final copy = base.copyWith(
        fullPath: '/z.db',
        sqliteVersion: '4.0',
        databaseSize: 9999,
        tables: const ['only'],
      );
      expect(copy.fullPath, '/z.db');
      expect(copy.sqliteVersion, '4.0');
      expect(copy.databaseSize, 9999);
      expect(copy.tables, ['only']);
    });
  });

  group('equality and props', () {
    test('equal when all fields match', () {
      const a = DatabaseMetadata(
        fullPath: '/x.db',
        sqliteVersion: '3.0',
        databaseSize: 100,
        tables: ['a'],
      );
      const b = DatabaseMetadata(
        fullPath: '/x.db',
        sqliteVersion: '3.0',
        databaseSize: 100,
        tables: ['a'],
      );
      expect(a, equals(b));
    });

    test('unequal when any field differs', () {
      const a = DatabaseMetadata(
        fullPath: '/x.db',
        sqliteVersion: '3.0',
        databaseSize: 100,
        tables: ['a'],
      );
      const b = DatabaseMetadata(
        fullPath: '/y.db',
        sqliteVersion: '3.0',
        databaseSize: 100,
        tables: ['a'],
      );
      expect(a, isNot(equals(b)));
    });

    test('props returns all fields', () {
      const metadata = DatabaseMetadata(
        fullPath: '/x.db',
        sqliteVersion: '3.0',
        databaseSize: 100,
        tables: ['a'],
      );
      expect(metadata.props, [
        '/x.db',
        '3.0',
        100,
        ['a'],
      ]);
    });
  });

  group('toString', () {
    test('includes path, version, formatted size, table count', () {
      const metadata = DatabaseMetadata(
        fullPath: '/x.db',
        sqliteVersion: '3.39.0',
        databaseSize: 2048,
        tables: ['a', 'b'],
      );
      final str = metadata.toString();
      expect(str, contains('/x.db'));
      expect(str, contains('3.39.0'));
      expect(str, contains('2.00 KB'));
      expect(str, contains('2'));
    });
  });
}
