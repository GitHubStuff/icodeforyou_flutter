// packages/sincewhen_drift_framework/lib/src/tables/glossary_items/glossary_items_dao_abstract.dart

/// Data Access Object interface for querying glossary item records.
abstract class GlossaryItemsDaoAbstract {
  /// Returns a set of all unique color values as 32-bit ARGB integers
  /// across glossary items.
  Future<Set<int>> allColorArgbValues();
}
