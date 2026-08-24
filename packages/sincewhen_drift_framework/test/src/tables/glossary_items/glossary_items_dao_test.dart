// packages/sincewhen_drift_framework/test/src/tables/glossary_items/glossary_items_dao_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/tables/glossary_items/glossary_items_dao.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

/// Builds a glossary item for insertion; the database assigns the real
/// primary key, so [id] only matters for update/delete matching.
GlossaryItem _item({
  required int createdTimestamp,
  required String tag,
  required int colorArgb,
  required String descr,
  int id = 0,
}) => GlossaryItem(
  id: id,
  createdTimestamp: createdTimestamp,
  tag: tag,
  colorArgb: colorArgb,
  descr: descr,
);

void main() {
  group(GlossaryItemsDao, () {
    late SinceWhenDatabase database;
    late GlossaryItemsDao dao;

    setUp(() {
      database = SinceWhenDatabase(NativeDatabase.memory());
      dao = database.glossaryItemsDao;
    });

    tearDown(() async {
      await database.close();
    });

    test('insertItem returns the persisted row with its assigned id', () async {
      final inserted = await dao.insertItem(
        _item(
          createdTimestamp: 1,
          tag: 'alpha',
          colorArgb: 100,
          descr: 'alpha description',
        ),
      );

      expect(inserted.id, greaterThan(0));
      expect(inserted.createdTimestamp, 1);
      expect(inserted.tag, 'alpha');
      expect(inserted.colorArgb, 100);
      expect(inserted.descr, 'alpha description');
    });

    test('allItems returns every row ordered by tag', () async {
      await dao.insertItem(
        _item(
          createdTimestamp: 1,
          tag: 'zulu',
          colorArgb: 100,
          descr: 'zulu description',
        ),
      );
      await dao.insertItem(
        _item(
          createdTimestamp: 2,
          tag: 'alpha',
          colorArgb: 200,
          descr: 'alpha description',
        ),
      );

      final items = await dao.allItems();

      expect(items.map((item) => item.tag).toList(), <String>[
        'alpha',
        'zulu',
      ]);
    });

    test('watchAllItems emits every row ordered by tag', () async {
      await dao.insertItem(
        _item(
          createdTimestamp: 1,
          tag: 'zulu',
          colorArgb: 100,
          descr: 'zulu description',
        ),
      );
      await dao.insertItem(
        _item(
          createdTimestamp: 2,
          tag: 'alpha',
          colorArgb: 200,
          descr: 'alpha description',
        ),
      );

      final items = await dao.watchAllItems().first;

      expect(items.map((item) => item.tag).toList(), <String>[
        'alpha',
        'zulu',
      ]);
    });

    test('allColorArgbValues returns the distinct set of colors', () async {
      await dao.insertItem(
        _item(
          createdTimestamp: 1,
          tag: 'alpha',
          colorArgb: 100,
          descr: 'alpha description',
        ),
      );
      await dao.insertItem(
        _item(
          createdTimestamp: 2,
          tag: 'beta',
          colorArgb: 200,
          descr: 'beta description',
        ),
      );

      final colors = await dao.allColorArgbValues();

      expect(colors, <int>{100, 200});
    });

    test('itemCount and watchItemCount report the row total', () async {
      expect(await dao.itemCount(), 0);
      expect(await dao.watchItemCount().first, 0);

      await dao.insertItem(
        _item(
          createdTimestamp: 1,
          tag: 'alpha',
          colorArgb: 100,
          descr: 'alpha description',
        ),
      );

      expect(await dao.itemCount(), 1);
      expect(await dao.watchItemCount().first, 1);
    });

    test('itemByTag returns the matching row or null', () async {
      await dao.insertItem(
        _item(
          createdTimestamp: 1,
          tag: 'alpha',
          colorArgb: 100,
          descr: 'alpha description',
        ),
      );

      final found = await dao.itemByTag('alpha');
      final missing = await dao.itemByTag('missing');

      expect(found?.createdTimestamp, 1);
      expect(missing, isNull);
    });

    test('itemWithColor returns the matching row or null', () async {
      await dao.insertItem(
        _item(
          createdTimestamp: 1,
          tag: 'alpha',
          colorArgb: 100,
          descr: 'alpha description',
        ),
      );

      final found = await dao.itemWithColor(100);
      final missing = await dao.itemWithColor(999);

      expect(found?.tag, 'alpha');
      expect(missing, isNull);
    });

    test(
      'updateItem rewrites every non-key column and reports success',
      () async {
        final inserted = await dao.insertItem(
          _item(
            createdTimestamp: 1,
            tag: 'alpha',
            colorArgb: 100,
            descr: 'alpha description',
          ),
        );

        final updated = await dao.updateItem(
          _item(
            id: inserted.id,
            createdTimestamp: 2,
            tag: 'beta',
            colorArgb: 200,
            descr: 'beta description',
          ),
        );

        expect(updated, isTrue);
        final reloaded = await dao.itemByTag('beta');
        expect(reloaded?.id, inserted.id);
        expect(reloaded?.createdTimestamp, 2);
        expect(reloaded?.colorArgb, 200);
        expect(reloaded?.descr, 'beta description');
      },
    );

    test('updateItem returns false when no row matches the id', () async {
      final updated = await dao.updateItem(
        _item(
          id: 999,
          createdTimestamp: 1,
          tag: 'ghost',
          colorArgb: 100,
          descr: 'ghost description',
        ),
      );

      expect(updated, isFalse);
    });

    test('deleteItem removes the row and reports success', () async {
      final inserted = await dao.insertItem(
        _item(
          createdTimestamp: 1,
          tag: 'alpha',
          colorArgb: 100,
          descr: 'alpha description',
        ),
      );

      final deleted = await dao.deleteItem(inserted);

      expect(deleted, isTrue);
      expect(await dao.itemCount(), 0);
    });

    test('deleteItem returns false when no row matches the id', () async {
      final deleted = await dao.deleteItem(
        _item(
          id: 999,
          createdTimestamp: 1,
          tag: 'ghost',
          colorArgb: 100,
          descr: 'ghost description',
        ),
      );

      expect(deleted, isFalse);
    });
  });
}
