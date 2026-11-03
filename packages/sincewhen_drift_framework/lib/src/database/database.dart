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

// NOTE  To generate '% dart run build_runner build'
part 'database.g.dart';

/// The SinceWhen application database.
///
/// Construct via `SinceWhenDatabaseOpening` and register the instance
/// with `GetIt` at the composition root (see `SinceWhenStartup`);
/// consumers resolve it from there. There is deliberately no global
/// instance in this library.
@DriftDatabase(
  tables: [GlossaryItems, SinceWhenItems, TagItems],
  daos: [GlossaryItemsDao, SinceWhenItemsDao, TagItemsDao],
)
class SinceWhenDatabase extends _$SinceWhenDatabase {
  /// Creates the database over [executor].
  SinceWhenDatabase(QueryExecutor executor) : super(executor);

  /// Schema version 1. Bump this and add a `MigrationStrategy` with an
  /// `onUpgrade` step when the schema changes after first release.
  @override
  int get schemaVersion => 1;
}
