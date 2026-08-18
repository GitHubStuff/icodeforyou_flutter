// packages/sincewhen_drift_framework/test/src/glossary_items/color_collector_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/glossary_items/color_collector.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

void main() {
  group(ColorCollector, () {
    late SinceWhenDatabase database;
    late ColorCollector collector;

    setUp(() {
      database = SinceWhenDatabase(NativeDatabase.memory());
      collector = ColorCollector(dao: database.glossaryItemsDao);
    });

    tearDown(() async {
      await database.close();
    });

    test('exposes the dao it reads from', () {
      expect(collector.dao, same(database.glossaryItemsDao));
    });

    test('getList returns the requested number of distinct colors',
        () async {
      final colors = await collector.getList(count: 5);

      expect(colors, hasLength(5));
      expect(colors.toSet(), hasLength(5));
    });

    test('getList excludes colors already used by glossary items', () async {
      await database.glossaryItemsDao.insertItem(
        GlossaryItem(id: 0, createdTimestamp: 1, tag: 'alpha', colorArgb: 100),
      );
      await database.glossaryItemsDao.insertItem(
        GlossaryItem(id: 0, createdTimestamp: 2, tag: 'beta', colorArgb: 200),
      );

      final colors = await collector.getList(count: 3);

      final taken = await database.glossaryItemsDao.allColorArgbValues();
      expect(colors.toSet().intersection(taken), isEmpty);
    });

    test('getList with a zero count returns an empty list', () async {
      final colors = await collector.getList(count: 0);

      expect(colors, isEmpty);
    });
  });
}
