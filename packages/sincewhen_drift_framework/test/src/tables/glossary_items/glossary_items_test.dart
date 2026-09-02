// packages/sincewhen_drift_framework/test/src/tables/glossary_items/glossary_items_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/tables/glossary_items/glossary_items.dart';

void main() {
  group(GlossaryItems, () {
    test('names the SQL table glossary', () {
      expect(GlossaryItems().tableName, 'glossary');
    });

    test('column builders throw outside code generation', () {
      // The generated $GlossaryItemsTable overrides every column getter,
      // so these bodies never run in production. Drift's DSL documents
      // that direct invocation throws; asserting that here executes each
      // declaration and pins the contract.
      final table = GlossaryItems();

      expect(() => table.id, throwsUnsupportedError);
      expect(() => table.createdTimestamp, throwsUnsupportedError);
      expect(() => table.tag, throwsUnsupportedError);
      expect(() => table.colorArgb, throwsUnsupportedError);
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
        final columnNames = database.glossaryItems.$columns
            .map((column) => column.name)
            .toList();

        expect(columnNames, <String>[
          'id',
          'createdTimestamp',
          'tag',
          'colorArgb',
        ]);
      });

      test('enforces the non-empty tag CHECK constraint', () async {
        await expectLater(
          database.customStatement(
            'INSERT INTO glossary (createdTimestamp, tag, colorArgb) '
            "VALUES (1, '', 1)",
          ),
          throwsA(anything),
        );
      });

      test('enforces UNIQUE on createdTimestamp, tag, and colorArgb',
          () async {
        await database.customStatement(
          'INSERT INTO glossary (createdTimestamp, tag, colorArgb) '
          "VALUES (1, 'alpha', 100)",
        );

        await expectLater(
          database.customStatement(
            'INSERT INTO glossary (createdTimestamp, tag, colorArgb) '
            "VALUES (1, 'beta', 200)",
          ),
          throwsA(anything),
        );
        await expectLater(
          database.customStatement(
            'INSERT INTO glossary (createdTimestamp, tag, colorArgb) '
            "VALUES (2, 'alpha', 200)",
          ),
          throwsA(anything),
        );
        await expectLater(
          database.customStatement(
            'INSERT INTO glossary (createdTimestamp, tag, colorArgb) '
            "VALUES (2, 'beta', 100)",
          ),
          throwsA(anything),
        );
      });
    });
  });
}
