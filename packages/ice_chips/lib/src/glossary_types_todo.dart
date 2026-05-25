// packages/ice_chips/lib/src/glossary_types_todo.dart

// ─────────────────────────────────────────────────────────────────────────────
// TODO(since_when): DELETE THIS ENTIRE FILE the day the new `since_when`
// package ships its glossary repository + model + failure types.
//
// This file is a temporary stand-in that lets `ice_chips` compile against
// `since_when_framework` alone, without depending on the dead monolithic
// `since_when` package (which bundled SinceWhenDatabase + CRUD).
//
// The interfaces, model, and failure type below are the single source of
// truth for these types during the stub period. `since_when_widgets`
// imports them from this package; do NOT duplicate them there.
//
// Migration steps when the real package arrives:
//   1. Add `since_when: ^x.y.z` to pubspec.yaml.
//   2. In each file that imports this placeholder, change
//        `import 'package:ice_chips/src/glossary_types_todo.dart';`
//      to
//        `import 'package:since_when/since_when.dart';`
//      (also update the corresponding imports in since_when_widgets, which
//      currently get these types via `package:ice_chips/ice_chips.dart`).
//   3. Delete this file.
//   4. Delete `fpdart` from pubspec.yaml if the real package re-exports it.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:since_when_framework/database.dart' show DatabaseFailure;

// ─── Failure type ───────────────────────────────────────────────────────────

/// Typed failure for glossary CRUD operations.
///
/// TODO(since_when): replace with the real `SinceWhenFailure` hierarchy
/// from the new package. The real one will likely be a sealed class with
/// variants for not-found, unique-constraint-violation, etc. — for now
/// this is a single concrete type wrapping any underlying
/// [DatabaseFailure] so the widgets can `failure.toString()` for display
/// and the type flows through `Either` the way the cubits expect.
class SinceWhenFailure extends Equatable implements Exception {
  /// Wraps an underlying [DatabaseFailure].
  const SinceWhenFailure(this.cause);

  /// The underlying database-layer failure.
  final DatabaseFailure cause;

  @override
  List<Object?> get props => [cause];

  @override
  String toString() => 'SinceWhenFailure: $cause';
}

// ─── Row model ──────────────────────────────────────────────────────────────

/// One row from the `since_when_tag_glossary` table.
///
/// TODO(since_when): replace with the real `RecordTagDefinition` from the
/// new package. The field set (`id`, `createdTimeStamp`, `tagName`,
/// `color`) and `copyWith` shape below match the columns defined in the
/// framework's `create_tables.dart` so a 1:1 swap is mechanical.
class RecordTagDefinition extends Equatable {
  /// Creates a tag definition.
  ///
  /// [id] defaults to `null` for records that have not yet been
  /// persisted to the database. Loaded records carry their assigned
  /// primary key.
  const RecordTagDefinition({
    required this.createdTimeStamp,
    required this.tagName,
    required this.color,
    this.id,
  });

  /// Auto-increment primary key. Null when the record has not been
  /// inserted yet.
  final int? id;

  /// Millisecond epoch timestamp assigned at insertion. Stable across
  /// updates and used as the foreign-key target from
  /// `since_when_tags.glossary_timestamp`.
  final int createdTimeStamp;

  /// Display name. Stored upper-cased; `UNIQUE` and non-empty per
  /// `create_tables.dart`.
  final String tagName;

  /// ARGB32-packed color. `UNIQUE` per `create_tables.dart`.
  final int color;

  /// Returns a copy with any provided fields replaced.
  RecordTagDefinition copyWith({
    int? id,
    int? createdTimeStamp,
    String? tagName,
    int? color,
  }) => RecordTagDefinition(
    id: id ?? this.id,
    createdTimeStamp: createdTimeStamp ?? this.createdTimeStamp,
    tagName: tagName ?? this.tagName,
    color: color ?? this.color,
  );

  @override
  List<Object?> get props => [id, createdTimeStamp, tagName, color];
}

// ─── Role-segregated interfaces ─────────────────────────────────────────────

/// Reads glossary rows.
///
/// TODO(since_when): replace with the real `GlossaryReader` from the new
/// package. Method signature kept identical so [TagsCubit] compiles
/// against the real interface without changes.
abstract interface class GlossaryReader {
  /// Returns every tag definition currently in the glossary, in
  /// insertion order. Result is `Right(records)` on success,
  /// `Left(failure)` on any database-level error.
  Future<Either<SinceWhenFailure, List<RecordTagDefinition>>>
  fetchAllTagDefinitions();
}

/// Inserts new glossary rows.
abstract interface class GlossaryRepository {
  /// Inserts a new tag definition and returns the persisted row,
  /// including the newly-assigned [RecordTagDefinition.id] and
  /// [RecordTagDefinition.createdTimeStamp].
  Future<Either<SinceWhenFailure, RecordTagDefinition>> insertTagDefinition({
    required String tagName,
    required int color,
  });
}

/// Updates existing glossary rows.
abstract interface class GlossaryWriter {
  /// Updates an existing tag definition by primary key. The [record]'s
  /// `id` and `createdTimeStamp` are preserved; `tagName` and `color`
  /// are written.
  Future<Either<SinceWhenFailure, Unit>> updateTagDefinition(
    RecordTagDefinition record,
  );
}

/// Deletes glossary rows.
abstract interface class GlossaryDeleter {
  /// Deletes the tag definition with the given primary key. Foreign-key
  /// cascade on `since_when_tags.glossary_timestamp` removes any join
  /// rows referencing it.
  Future<Either<SinceWhenFailure, Unit>> deleteTagDefinition(int id);
}
