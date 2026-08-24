// packages/sincewhen_drift_framework/test/src/repositories/drift_tag_repository_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/repositories/drift_tag_repository.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

/// Builds a tag link; the database assigns the real primary key, so [id]
/// only matters for delete matching.
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
  group(DriftTagRepository, () {
    late SinceWhenDatabase database;
    late TagRepository repository;

    setUp(() async {
      database = SinceWhenDatabase(NativeDatabase.memory());
      repository = DriftTagRepository(database.tagItemsDao);

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

    test('satisfies the persistence-free contract', () {
      expect(repository, isA<TagRepository>());
    });

    test('insertItem persists through the dao', () async {
      final inserted = await repository.insertItem(
        _item(recordTimestamp: 10, glossaryTimestamp: 100),
      );

      expect(inserted.id, greaterThan(0));
      expect(inserted.recordTimestamp, 10);
      expect(inserted.glossaryTimestamp, 100);
    });

    test('allItems and watchAllItems delegate the full set', () async {
      await repository.insertItem(
        _item(recordTimestamp: 10, glossaryTimestamp: 100),
      );
      await repository.insertItem(
        _item(recordTimestamp: 20, glossaryTimestamp: 200),
      );

      expect(await repository.allItems(), hasLength(2));
      expect(await repository.watchAllItems().first, hasLength(2));
    });

    test(
      'itemsForRecord and watchItemsForRecord delegate the record view',
      () async {
        await repository.insertItem(
          _item(recordTimestamp: 10, glossaryTimestamp: 100),
        );
        await repository.insertItem(
          _item(recordTimestamp: 20, glossaryTimestamp: 200),
        );

        expect(await repository.itemsForRecord(10), hasLength(1));
        expect(await repository.watchItemsForRecord(10).first, hasLength(1));
      },
    );

    test('itemsForGlossary delegates the glossary view', () async {
      await repository.insertItem(
        _item(recordTimestamp: 10, glossaryTimestamp: 100),
      );
      await repository.insertItem(
        _item(recordTimestamp: 20, glossaryTimestamp: 100),
      );

      expect(await repository.itemsForGlossary(100), hasLength(2));
    });

    test('itemCount and watchItemCount delegate the totals', () async {
      await repository.insertItem(
        _item(recordTimestamp: 10, glossaryTimestamp: 100),
      );

      expect(await repository.itemCount(), 1);
      expect(await repository.watchItemCount().first, 1);
    });

    test('deleteItem delegates and reports the outcome', () async {
      final inserted = await repository.insertItem(
        _item(recordTimestamp: 10, glossaryTimestamp: 100),
      );

      expect(await repository.deleteItem(inserted), isTrue);
      expect(await repository.itemCount(), 0);
    });
  });
}
