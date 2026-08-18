// packages/sincewhen_drift_framework/test/src/repositories/drift_since_when_repository_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/repositories/drift_since_when_repository.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

/// Builds a record; the database assigns the real primary key, so [id]
/// only matters for update/delete matching.
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
  group(DriftSinceWhenRepository, () {
    late SinceWhenDatabase database;
    late SinceWhenRepository repository;

    setUp(() {
      database = SinceWhenDatabase(NativeDatabase.memory());
      repository = DriftSinceWhenRepository(database.sinceWhenItemsDao);
    });

    tearDown(() async {
      await database.close();
    });

    test('satisfies the persistence-free contract', () {
      expect(repository, isA<SinceWhenRepository>());
    });

    test('insertItem persists through the dao', () async {
      final inserted = await repository.insertItem(
        _item(createdTimestamp: 10, content: 'body'),
      );

      expect(inserted.id, greaterThan(0));
      expect(inserted.content, 'body');
    });

    test('allItems and watchAllItems delegate ordered reads', () async {
      await repository.insertItem(_item(createdTimestamp: 20));
      await repository.insertItem(_item(createdTimestamp: 10));

      final items = await repository.allItems();
      final watched = await repository.watchAllItems().first;

      expect(items.map((item) => item.createdTimestamp).toList(), <int>[
        10,
        20,
      ]);
      expect(watched.map((item) => item.createdTimestamp).toList(), <int>[
        10,
        20,
      ]);
    });

    test('itemByCreatedTimestamp delegates the lookup', () async {
      await repository.insertItem(_item(createdTimestamp: 10));

      expect(
        (await repository.itemByCreatedTimestamp(10))?.createdTimestamp,
        10,
      );
      expect(await repository.itemByCreatedTimestamp(999), isNull);
    });

    test('itemCount and watchItemCount delegate the totals', () async {
      await repository.insertItem(_item(createdTimestamp: 10));

      expect(await repository.itemCount(), 1);
      expect(await repository.watchItemCount().first, 1);
    });

    test('updateItem delegates and reports the outcome', () async {
      final inserted = await repository.insertItem(_item(createdTimestamp: 10));

      final updated = await repository.updateItem(
        _item(id: inserted.id, createdTimestamp: 20, content: 'new body'),
      );

      expect(updated, isTrue);
      expect(
        (await repository.itemByCreatedTimestamp(20))?.content,
        'new body',
      );
    });

    test('deleteItem delegates and reports the outcome', () async {
      final inserted = await repository.insertItem(_item(createdTimestamp: 10));

      expect(await repository.deleteItem(inserted), isTrue);
      expect(await repository.itemCount(), 0);
    });
  });
}
