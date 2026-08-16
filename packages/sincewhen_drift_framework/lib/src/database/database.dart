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

  //+ Current at "1", but if there ever is a database scheme change
  //+ and migration is needed, this serves as a template.
  //+ This example is as if tldr was added in the future
  @override
  int get schemaVersion => 1;

  //+ CHANGED (new override)
  /// Migrations between schema versions.
  ///
  /// Fresh installs run `onCreate`, which builds every table at the
  /// current schema — no steps needed. Existing installs walk `onUpgrade`
  /// from their stored version to [schemaVersion], one step per bump.
  ///
  /// v1 → v2: adds the nullable `tldr` column to the `sinceWhen` table.
  /// Nullable with no default, so existing rows are valid unchanged.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(sinceWhenItems, sinceWhenItems.tldr);
      }
    },
  );
}
