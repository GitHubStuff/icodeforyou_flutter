// packages/sincewhen_drift_framework/lib/src/tables/glossary_items/glossary_items.dart

import 'package:drift/drift.dart';
import 'package:sincewhen_models/sincewhen_models.dart' show GlossaryItem;

/// Tag glossary table: the canonical definition of every tag.
///
/// Auto-incrementing primary key, a unique creation timestamp, a unique
/// non-empty tag, and a unique color.
@UseRowClass(GlossaryItem) //Connects to the pure dart model
class GlossaryItems extends Table {
  @override
  String get tableName => 'glossary';

  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// `createdTimestamp INTEGER NOT NULL UNIQUE`.
  ///
  /// Explicitly named to keep the column camelCase. This is the foreign
  /// key target for `TagItems`, so the `unique()` constraint is
  /// required — SQLite rejects foreign keys that reference
  /// non-uniquely-constrained columns.
  IntColumn get createdTimestamp =>
      integer().named('createdTimestamp').unique()();

  /// `tag TEXT NOT NULL UNIQUE CHECK(tag != '')`.
  ///
  /// The self-reference inside `check()` is the documented drift pattern:
  /// the generated table class overrides this getter, so it is never
  /// executed at runtime — drift's builder only reads it statically to
  /// emit the CHECK clause. The recursion the analyzer flags cannot occur.
  // ignore: recursive_getters
  TextColumn get tag => text().unique().check(tag.isNotValue(''))();

  /// `colorArgb INTEGER NOT NULL UNIQUE`.
  ///
  /// Packed ARGB color value, suitable for `Color(colorArgb)` on the
  /// Flutter side. Explicitly named to keep the column camelCase,
  /// consistent with the rest of the table.
  IntColumn get colorArgb => integer().named('colorArgb').unique()();

  /// 'descr NOT NULL UNIQUE CHECK(descr != '')'.
  ///
  /// Descriptor of what the tag represents. Simple description for details
  /// views of the tag value meaning.
  // ignore: recursive_getters
  TextColumn get descr => text().unique().check(descr.isNotValue(''))();
}
