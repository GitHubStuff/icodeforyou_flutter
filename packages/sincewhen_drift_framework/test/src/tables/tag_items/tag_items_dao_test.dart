// packages/sincewhen_drift_framework/test/src/tables/tag_items/tag_items_dao_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/tables/tag_items/tag_items_dao.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

/// Builds a tag link for insertion; the database assigns the real
/// primary key, so [id] only matters for delete matching.
TagItem _item({
  required int recordTimestamp,
  required int glossaryTimestamp,
  int id = 0,
}) => TagItem(
  id: id,
  recordTimestamp: recordTimestamp,
  glossaryTimestamp: glossaryTimestamp,
);

void main() {
  group(TagItemsDao, () {
    late SinceWhenDatabase database;
    late TagItemsDao dao;

    setUp(() async {
      database = SinceWhenDatabase(NativeDatabase.memory());
      dao = database.tagItemsDao;

      // Referenced rows for the foreign keys, keeping the fixtures valid
      // even with enforcement enabled.
      await database.customStatement(
        'INSERT INTO glossary (createdTimestamp, tag, colorArgb) '
        "VALUES (100, 'alpha', 1), (200, 'beta', 2)",
      );
      await database.customStatement(
        'INSERT INTO sinceWhen '
        '(createdTimestamp, reviewedTimestamp, editedTimestamp, content) '
        "VALUES (10, 1, 1, 'first'), (20, 1, 1, 'second')",
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('insertItem returns the persisted row with its assigned id', () async {
      final inserted = await dao.insertItem(
        _item(recordTimestamp: 10, glossaryTimestamp: 100),
      );

      expect(inserted.id, greaterThan(0));
      expect(inserted.recordTimestamp, 10);
      expect(inserted.glossaryTimestamp, 100);
    });

    test('allItems and watchAllItems return every row', () async {
      await dao.insertItem(_item(recordTimestamp: 10, glossaryTimestamp: 100));
      await dao.insertItem(_item(recordTimestamp: 20, glossaryTimestamp: 200));

      final items = await dao.allItems();
      final watched = await dao.watchAllItems().first;

      expect(items, hasLength(2));
      expect(watched, hasLength(2));
    });

    test('itemsForRecord returns only the links for that record', () async {
      await dao.insertItem(_item(recordTimestamp: 10, glossaryTimestamp: 100));
      await dao.insertItem(_item(recordTimestamp: 10, glossaryTimestamp: 200));
      await dao.insertItem(_item(recordTimestamp: 20, glossaryTimestamp: 100));

      final items = await dao.itemsForRecord(10);

      expect(items, hasLength(2));
      expect(
        items.map((item) => item.glossaryTimestamp).toSet(),
        <int>{100, 200},
      );
    });

    test('watchItemsForRecord emits only the links for that record', () async {
      await dao.insertItem(_item(recordTimestamp: 10, glossaryTimestamp: 100));
      await dao.insertItem(_item(recordTimestamp: 20, glossaryTimestamp: 200));

      final items = dao.watchItemsForRecord(10);

      expect(await items.first, hasLength(1));
    });

    test('itemsForGlossary returns only the links using that entry', () async {
      await dao.insertItem(_item(recordTimestamp: 10, glossaryTimestamp: 100));
      await dao.insertItem(_item(recordTimestamp: 20, glossaryTimestamp: 100));
      await dao.insertItem(_item(recordTimestamp: 20, glossaryTimestamp: 200));

      final items = await dao.itemsForGlossary(100);

      expect(items, hasLength(2));
      expect(
        items.map((item) => item.recordTimestamp).toSet(),
        <int>{10, 20},
      );
    });

    test('itemCount and watchItemCount report the row total', () async {
      expect(await dao.itemCount(), 0);
      expect(await dao.watchItemCount().first, 0);

      await dao.insertItem(_item(recordTimestamp: 10, glossaryTimestamp: 100));

      expect(await dao.itemCount(), 1);
      expect(await dao.watchItemCount().first, 1);
    });

    test('deleteItem removes the row and reports success', () async {
      final inserted = await dao.insertItem(
        _item(recordTimestamp: 10, glossaryTimestamp: 100),
      );

      final deleted = await dao.deleteItem(inserted);

      expect(deleted, isTrue);
      expect(await dao.itemCount(), 0);
    });

    test('deleteItem returns false when no row matches the id', () async {
      final deleted = await dao.deleteItem(
        _item(id: 999, recordTimestamp: 10, glossaryTimestamp: 100),
      );

      expect(deleted, isFalse);
    });
  });
}
