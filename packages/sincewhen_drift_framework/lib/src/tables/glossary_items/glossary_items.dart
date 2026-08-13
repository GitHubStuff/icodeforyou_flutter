// packages/since_when/lib/src/tables/glossary_items.dart

import 'package:drift/drift.dart';

/// Tag glossary table: the canonical definition of every tag.
///
/// Auto-incrementing primary key, a unique creation timestamp, a unique
/// non-empty tag, and a unique color.
class GlossaryItems extends Table {
  @override
  String get tableName => 'tagGlossary';

  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// `createdTimeStamp INTEGER NOT NULL UNIQUE`.
  ///
  /// Explicitly named to preserve the camelCase column name from the raw
  /// SQL schema, since drift would otherwise emit `created_time_stamp`.
  IntColumn get createdTimeStamp =>
      integer().named('createdTimeStamp').unique()();

  /// `tag TEXT NOT NULL UNIQUE CHECK(tag != '')`.
  ///
  /// The self-reference inside `check()` is the documented drift pattern:
  /// the generated table class overrides this getter, so it is never
  /// executed at runtime — drift's builder only reads it statically to
  /// emit the CHECK clause. The recursion the analyzer flags cannot occur.
  // ignore: recursive_getters
  TextColumn get tag => text().unique().check(tag.isNotValue(''))();

  /// `color_argb INTEGER NOT NULL UNIQUE`.
  ///
  /// Packed ARGB color value, suitable for `Color(colorArgb)` on the
  /// Flutter side. Drift derives the column name from the getter.
  IntColumn get colorArgb => integer().unique()();
}
