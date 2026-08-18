// packages/sincewhen_drift_framework/test/src/database/database_test.dart

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';

void main() {
  group(SinceWhenDatabase, () {
    late SinceWhenDatabase database;

    setUp(() {
      database = SinceWhenDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('constructs over the given executor and opens', () async {
      final rows = await database.customSelect('SELECT 1 AS one').get();

      expect(rows.single.read<int>('one'), 1);
    });

    test('reports schema version 1', () {
      expect(database.schemaVersion, 1);
    });

    test('creates all three tables', () async {
      final rows = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' "
            "AND name NOT LIKE 'sqlite_%' ORDER BY name",
          )
          .get();
      final names = rows.map((row) => row.read<String>('name')).toList();

      expect(names, containsAll(<String>['glossary', 'sinceWhen', 'tags']));
    });

    test('creates every declared index', () async {
      final rows = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'index' "
            "AND name LIKE 'idx_%' ORDER BY name",
          )
          .get();
      final names = rows.map((row) => row.read<String>('name')).toList();

      expect(names, <String>[
        'idx_since_when_edited',
        'idx_since_when_event',
        'idx_since_when_parent',
        'idx_since_when_reviewed',
        'idx_tags_glossary',
      ]);
    });

    group('migration', () {
      test('onUpgrade below version 2 adds the tldr column', () async {
        // Force the database open at the current schema, then drop the
        // column to simulate a store created before tldr existed. The
        // upgrade step must restore it.
        await database.customSelect('SELECT 1').get();
        await database.customStatement(
          'ALTER TABLE sinceWhen DROP COLUMN tldr',
        );

        await database.migration.onUpgrade(database.createMigrator(), 1, 2);

        final rows = await database
            .customSelect("SELECT name FROM pragma_table_info('sinceWhen')")
            .get();
        final columns = rows.map((row) => row.read<String>('name')).toList();
        expect(columns, contains('tldr'));
      });

      test('onUpgrade at or above version 2 is a no-op', () async {
        await database.customSelect('SELECT 1').get();

        await expectLater(
          database.migration.onUpgrade(database.createMigrator(), 2, 2),
          completes,
        );
      });
    });
  });
}
