// packages/sincewhen_drift_framework/test/src/tables/sincewhen_items/sincewhen_items_dao_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/tables/sincewhen_items/sincewhen_items_dao.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

/// Builds a record for insertion; the database assigns the real primary
/// key, so [id] only matters for update/delete matching.
SinceWhenItem _item({
  int id = 0,
  required int createdTimestamp,
  int reviewedTimestamp = 1,
  int editedTimestamp = 1,
  int sequenceNumber = 0,
  int? parentTimestamp,
  int? eventTimestamp,
  String? metaData,
  String? tldr,
  String content = 'content',
}) => SinceWhenItem(
  id: id,
  createdTimestamp: createdTimestamp,
  reviewedTimestamp: reviewedTimestamp,
  editedTimestamp: editedTimestamp,
  sequenceNumber: sequenceNumber,
  parentTimestamp: parentTimestamp,
  eventTimestamp: eventTimestamp,
  metaData: metaData,
  tldr: tldr,
  content: content,
);

void main() {
  group(SinceWhenItemsDao, () {
    late SinceWhenDatabase database;
    late SinceWhenItemsDao dao;

    setUp(() {
      database = SinceWhenDatabase(NativeDatabase.memory());
      dao = database.sinceWhenItemsDao;
    });

    tearDown(() async {
      await database.close();
    });

    test('insertItem returns the persisted row with its assigned id',
        () async {
      final inserted = await dao.insertItem(
        _item(
          createdTimestamp: 10,
          reviewedTimestamp: 11,
          editedTimestamp: 12,
          sequenceNumber: 3,
          parentTimestamp: 5,
          eventTimestamp: 6,
          metaData: 'meta',
          tldr: 'summary',
          content: 'body',
        ),
      );

      expect(inserted.id, greaterThan(0));
      expect(inserted.createdTimestamp, 10);
      expect(inserted.reviewedTimestamp, 11);
      expect(inserted.editedTimestamp, 12);
      expect(inserted.sequenceNumber, 3);
      expect(inserted.parentTimestamp, 5);
      expect(inserted.eventTimestamp, 6);
      expect(inserted.metaData, 'meta');
      expect(inserted.tldr, 'summary');
      expect(inserted.content, 'body');
    });

    test('insertItem persists null optionals as null', () async {
      final inserted = await dao.insertItem(_item(createdTimestamp: 10));

      expect(inserted.parentTimestamp, isNull);
      expect(inserted.eventTimestamp, isNull);
      expect(inserted.metaData, isNull);
      expect(inserted.tldr, isNull);
    });

    test('allItems returns every row ordered by creation timestamp',
        () async {
      await dao.insertItem(_item(createdTimestamp: 20));
      await dao.insertItem(_item(createdTimestamp: 10));

      final items = await dao.allItems();

      expect(items.map((item) => item.createdTimestamp).toList(), <int>[
        10,
        20,
      ]);
    });

    test('watchAllItems emits every row ordered by creation timestamp',
        () async {
      await dao.insertItem(_item(createdTimestamp: 20));
      await dao.insertItem(_item(createdTimestamp: 10));

      final items = await dao.watchAllItems().first;

      expect(items.map((item) => item.createdTimestamp).toList(), <int>[
        10,
        20,
      ]);
    });

    test('itemByCreatedTimestamp returns the matching row or null',
        () async {
      await dao.insertItem(_item(createdTimestamp: 10));

      final found = await dao.itemByCreatedTimestamp(10);
      final missing = await dao.itemByCreatedTimestamp(999);

      expect(found?.createdTimestamp, 10);
      expect(missing, isNull);
    });

    test('itemCount and watchItemCount report the row total', () async {
      expect(await dao.itemCount(), 0);
      expect(await dao.watchItemCount().first, 0);

      await dao.insertItem(_item(createdTimestamp: 10));

      expect(await dao.itemCount(), 1);
      expect(await dao.watchItemCount().first, 1);
    });

    test('updateItem rewrites every non-key column and reports success',
        () async {
      final inserted = await dao.insertItem(_item(createdTimestamp: 10));

      final updated = await dao.updateItem(
        _item(
          id: inserted.id,
          createdTimestamp: 20,
          reviewedTimestamp: 21,
          editedTimestamp: 22,
          sequenceNumber: 4,
          parentTimestamp: 7,
          eventTimestamp: 8,
          metaData: 'new meta',
          tldr: 'new summary',
          content: 'new body',
        ),
      );

      expect(updated, isTrue);
      final reloaded = await dao.itemByCreatedTimestamp(20);
      expect(reloaded?.id, inserted.id);
      expect(reloaded?.reviewedTimestamp, 21);
      expect(reloaded?.editedTimestamp, 22);
      expect(reloaded?.sequenceNumber, 4);
      expect(reloaded?.parentTimestamp, 7);
      expect(reloaded?.eventTimestamp, 8);
      expect(reloaded?.metaData, 'new meta');
      expect(reloaded?.tldr, 'new summary');
      expect(reloaded?.content, 'new body');
    });

    test('updateItem returns false when no row matches the id', () async {
      final updated = await dao.updateItem(
        _item(id: 999, createdTimestamp: 10),
      );

      expect(updated, isFalse);
    });

    test('deleteItem removes the row and reports success', () async {
      final inserted = await dao.insertItem(_item(createdTimestamp: 10));

      final deleted = await dao.deleteItem(inserted);

      expect(deleted, isTrue);
      expect(await dao.itemCount(), 0);
    });

    test('deleteItem returns false when no row matches the id', () async {
      final deleted = await dao.deleteItem(
        _item(id: 999, createdTimestamp: 10),
      );

      expect(deleted, isFalse);
    });
  });
}
