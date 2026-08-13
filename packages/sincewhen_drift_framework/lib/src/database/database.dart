// packages/sincewhen_drift_framework/lib/src/database/database.dart

import 'package:drift/drift.dart';
import 'package:sincewhen_drift_framework/src/tables/glossary_items/glossary_items.dart'
    show GlossaryItems;
import 'package:sincewhen_drift_framework/src/tables/glossary_items/glossary_items_dao.dart'
    show GlossaryItemsDao;
import 'package:sincewhen_drift_framework/src/tables/sincewhen_items/sincewhen_items.dart'
    show SinceWhenItems;
import 'package:sincewhen_drift_framework/src/tables/sincewhen_items/sincewhen_items_dao.dart'
    show SinceWhenItemsDao;
import 'package:sincewhen_drift_framework/src/tables/tag_items/tag_items.dart'
    show TagItems;
import 'package:sincewhen_drift_framework/src/tables/tag_items/tag_items_dao.dart'
    show TagItemsDao;

part 'database.g.dart';

/// The SinceWhen application database.
///
/// Construct via `SinceWhenDatabaseOpening` and register the instance at
/// the composition root; consumers resolve it through
/// `DependencyResolver`. There is deliberately no global instance in
/// this library.
@DriftDatabase(
  tables: [GlossaryItems, SinceWhenItems, TagItems],
  daos: [GlossaryItemsDao, SinceWhenItemsDao, TagItemsDao],
)
class SinceWhenDatabase extends _$SinceWhenDatabase {
  /// Creates the database over [executor].
  SinceWhenDatabase(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;
}
