// packages/sincewhen_drift_framework/test/src/tables/tag_items/tag_items_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/tables/tag_items/tag_items.dart';

void main() {
  group(TagItems, () {
    test('names the SQL table tags', () {
      expect(TagItems().tableName, 'tags');
    });

    test('column builders throw outside code generation', () {
      // The generated $TagItemsTable overrides every column getter, so
      // these bodies never run in production. Drift's DSL documents that
      // direct invocation throws; asserting that here executes each
      // declaration and pins the contract.
      final table = TagItems();

      expect(() => table.id, throwsUnsupportedError);
      expect(() => table.recordTimestamp, throwsUnsupportedError);
      expect(() => table.glossaryTimestamp, throwsUnsupportedError);
    });

    test('uniqueKeys throws outside code generation', () {
      // The composite key set references the column getters above, so
      // evaluating it on a bare instance hits the same DSL guard.
      expect(() => TagItems().uniqueKeys, throwsUnsupportedError);
    });

    group('generated schema', () {
      late SinceWhenDatabase database;

      setUp(() {
        database = SinceWhenDatabase(NativeDatabase.memory());
      });

      tearDown(() async {
        await database.close();
      });

      test('declares the expected columns', () {
        final columnNames = database.tagItems.$columns
            .map((column) => column.name)
            .toList();

        expect(columnNames, <String>[
          'id',
          'record_timestamp',
          'glossary_timestamp',
        ]);
      });

      test('enforces the composite unique constraint', () async {
        await database.customStatement(
          'INSERT INTO glossary (createdTimestamp, tag, colorArgb) '
          "VALUES (10, 'alpha', 100)",
        );
        await database.customStatement(
          'INSERT INTO sinceWhen '
          '(createdTimestamp, reviewedTimestamp, editedTimestamp, content) '
          "VALUES (20, 1, 1, 'body')",
        );
        await database.customStatement(
          'INSERT INTO tags (record_timestamp, glossary_timestamp) '
          'VALUES (20, 10)',
        );

        await expectLater(
          database.customStatement(
            'INSERT INTO tags (record_timestamp, glossary_timestamp) '
            'VALUES (20, 10)',
          ),
          throwsA(anything),
        );
      });

      test('cascades deletes from both referenced tables', () async {
        // Drift does not enable foreign key enforcement by itself; turn
        // it on for this connection so the ON DELETE CASCADE clauses are
        // observable.
        await database.customStatement('PRAGMA foreign_keys = ON');
        await database.customStatement(
          'INSERT INTO glossary (createdTimestamp, tag, colorArgb) '
          "VALUES (10, 'alpha', 100)",
        );
        await database.customStatement(
          'INSERT INTO sinceWhen '
          '(createdTimestamp, reviewedTimestamp, editedTimestamp, content) '
          "VALUES (20, 1, 1, 'body')",
        );
        await database.customStatement(
          'INSERT INTO tags (record_timestamp, glossary_timestamp) '
          'VALUES (20, 10)',
        );

        await database.customStatement(
          'DELETE FROM sinceWhen WHERE createdTimestamp = 20',
        );

        final remaining = await database
            .customSelect('SELECT COUNT(*) AS total FROM tags')
            .getSingle();
        expect(remaining.read<int>('total'), 0);
      });
    });
  });
}
