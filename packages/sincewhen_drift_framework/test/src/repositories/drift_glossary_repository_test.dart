// packages/sincewhen_drift_framework/test/src/repositories/drift_glossary_repository_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/repositories/drift_glossary_repository.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

/// Builds a glossary item; the database assigns the real primary key,
/// so [id] only matters for update/delete matching.
GlossaryItem _item({
  int id = 0,
  required int createdTimestamp,
  required String tag,
  required int colorArgb,
}) => GlossaryItem(
  id: id,
  createdTimestamp: createdTimestamp,
  tag: tag,
  colorArgb: colorArgb,
);

void main() {
  group(DriftGlossaryRepository, () {
    late SinceWhenDatabase database;
    late GlossaryRepository repository;

    setUp(() {
      database = SinceWhenDatabase(NativeDatabase.memory());
      repository = DriftGlossaryRepository(database.glossaryItemsDao);
    });

    tearDown(() async {
      await database.close();
    });

    test('satisfies the persistence-free contract', () {
      expect(repository, isA<GlossaryRepository>());
    });

    test('insertItem persists through the dao', () async {
      final inserted = await repository.insertItem(
        _item(createdTimestamp: 1, tag: 'alpha', colorArgb: 100),
      );

      expect(inserted.id, greaterThan(0));
      expect(inserted.tag, 'alpha');
    });

    test('allItems and watchAllItems delegate ordered reads', () async {
      await repository.insertItem(
        _item(createdTimestamp: 1, tag: 'zulu', colorArgb: 100),
      );
      await repository.insertItem(
        _item(createdTimestamp: 2, tag: 'alpha', colorArgb: 200),
      );

      final items = await repository.allItems();
      final watched = await repository.watchAllItems().first;

      expect(items.map((item) => item.tag).toList(), <String>[
        'alpha',
        'zulu',
      ]);
      expect(watched.map((item) => item.tag).toList(), <String>[
        'alpha',
        'zulu',
      ]);
    });

    test('allColorArgbValues delegates the color set', () async {
      await repository.insertItem(
        _item(createdTimestamp: 1, tag: 'alpha', colorArgb: 100),
      );

      expect(await repository.allColorArgbValues(), <int>{100});
    });

    test('itemByTag delegates the tag lookup', () async {
      await repository.insertItem(
        _item(createdTimestamp: 1, tag: 'alpha', colorArgb: 100),
      );

      expect((await repository.itemByTag('alpha'))?.colorArgb, 100);
      expect(await repository.itemByTag('missing'), isNull);
    });

    test('itemWithColor delegates the color lookup', () async {
      await repository.insertItem(
        _item(createdTimestamp: 1, tag: 'alpha', colorArgb: 100),
      );

      expect((await repository.itemWithColor(100))?.tag, 'alpha');
      expect(await repository.itemWithColor(999), isNull);
    });

    test('itemCount and watchItemCount delegate the totals', () async {
      await repository.insertItem(
        _item(createdTimestamp: 1, tag: 'alpha', colorArgb: 100),
      );

      expect(await repository.itemCount(), 1);
      expect(await repository.watchItemCount().first, 1);
    });

    test('updateItem delegates and reports the outcome', () async {
      final inserted = await repository.insertItem(
        _item(createdTimestamp: 1, tag: 'alpha', colorArgb: 100),
      );

      final updated = await repository.updateItem(
        _item(
          id: inserted.id,
          createdTimestamp: 2,
          tag: 'beta',
          colorArgb: 200,
        ),
      );

      expect(updated, isTrue);
      expect((await repository.itemByTag('beta'))?.id, inserted.id);
    });

    test('deleteItem delegates and reports the outcome', () async {
      final inserted = await repository.insertItem(
        _item(createdTimestamp: 1, tag: 'alpha', colorArgb: 100),
      );

      expect(await repository.deleteItem(inserted), isTrue);
      expect(await repository.itemCount(), 0);
    });
  });
}
