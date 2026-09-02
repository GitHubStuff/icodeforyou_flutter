// packages/sincewhen_drift_framework/lib/src/glossary_items/color_collector.dart

import 'package:extensions/color/color_ext.dart';
import 'package:random_color_generator/random_color_generator.dart'
    show RandomColorGenerator;
import 'package:sincewhen_drift_framework/src/tables/glossary_items/glossary_items_dao.dart'
    show GlossaryItemsDao;

/// Collects random colors that are not already used by any glossary item.
class ColorCollector {
  /// Creates the collector reading existing colors from [dao].
  const ColorCollector({required this.dao});

  /// Data access used to look up the colors already in use.
  final GlossaryItemsDao dao;

  /// Returns [count] distinct random colors as ARGB integers, none of
  /// which are used by an existing glossary item.
  ///
  /// Existing colors are read once as a snapshot; a color inserted
  /// elsewhere after the snapshot is not excluded. The unique constraint
  /// on the color column remains the final guard at insert time.
  Future<List<int>> getList({required int count}) async {
    final List<int> result = [];
    final taken = await dao.allColorArgbValues();
    while (result.length < count) {
      final candidate = RandomColorGenerator.generate().toInt();
      if (!taken.contains(candidate) && !result.contains(candidate)) {
        result.add(candidate);
      }
    }
    return result;
  }
}
