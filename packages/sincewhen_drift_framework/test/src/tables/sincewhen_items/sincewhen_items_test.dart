// packages/sincewhen_drift_framework/test/src/tables/sincewhen_items/sincewhen_items_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/tables/sincewhen_items/sincewhen_items.dart';

void main() {
  group(SinceWhenItems, () {
    test('names the SQL table sinceWhen', () {
      expect(SinceWhenItems().tableName, 'sinceWhen');
    });

    test('column builders throw outside code generation', () {
      // The generated $SinceWhenItemsTable overrides every column getter,
      // so these bodies never run in production. Drift's DSL documents
      // that direct invocation throws; asserting that here executes each
      // declaration and pins the contract.
      final table = SinceWhenItems();

      expect(() => table.id, throwsUnsupportedError);
      expect(() => table.createdTimestamp, throwsUnsupportedError);
      expect(() => table.reviewedTimestamp, throwsUnsupportedError);
      expect(() => table.editedTimestamp, throwsUnsupportedError);
      expect(() => table.parentTimestamp, throwsUnsupportedError);
      expect(() => table.eventTimestamp, throwsUnsupportedError);
      expect(() => table.sequenceNumber, throwsUnsupportedError);
      expect(() => table.metaData, throwsUnsupportedError);
      expect(() => table.tldr, throwsUnsupportedError);
      expect(() => table.content, throwsUnsupportedError);
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
        final columnNames = database.sinceWhenItems.$columns
            .map((column) => column.name)
            .toList();

        expect(columnNames, <String>[
          'id',
          'createdTimestamp',
          'reviewedTimestamp',
          'editedTimestamp',
          'parentTimestamp',
          'eventTimestamp',
          'sequenceNumber',
          'metaData',
          'tldr',
          'content',
        ]);
      });

      test('defaults sequenceNumber to zero', () async {
        await database.customStatement(
          'INSERT INTO sinceWhen '
          '(createdTimestamp, reviewedTimestamp, editedTimestamp, content) '
          "VALUES (1, 1, 1, 'body')",
        );

        final row = await database
            .customSelect('SELECT sequenceNumber FROM sinceWhen')
            .getSingle();
        expect(row.read<int>('sequenceNumber'), 0);
      });

      test('enforces UNIQUE on createdTimestamp', () async {
        await database.customStatement(
          'INSERT INTO sinceWhen '
          '(createdTimestamp, reviewedTimestamp, editedTimestamp, content) '
          "VALUES (1, 1, 1, 'first')",
        );

        await expectLater(
          database.customStatement(
            'INSERT INTO sinceWhen '
            '(createdTimestamp, reviewedTimestamp, editedTimestamp, content) '
            "VALUES (1, 2, 2, 'second')",
          ),
          throwsA(anything),
        );
      });
    });
  });
}
