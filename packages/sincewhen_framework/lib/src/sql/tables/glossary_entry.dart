// packages/sincewhen_framework/lib/src/sql/tables/glossary_entry.dart

import 'package:meta/meta.dart';

/// Immutable representation of one row in the glossary table.
///
/// A [GlossaryEntry] always mirrors a *persisted* record: if you hold one,
/// the row exists in the database with the [id] and [createdTimeStamp] it
/// carries. Inserts therefore never construct one directly — the framework
/// assigns both identity fields and returns the completed entry.
///
/// [createdTimeStamp] is the principal identifier used in queries and as
/// the foreign-key target of the tags junction table; [id] is the SQLite
/// rowid and is rarely referenced. Neither is ever updated.
///
/// Converts losslessly to and from the raw row representation via
/// [GlossaryEntry.fromRow] and [toRow], keeping the mapping adjacent to the
/// hand-written DDL it mirrors.
@immutable
class GlossaryEntry {
  /// Creates an entry from already-validated field values.
  ///
  /// Callers outside the framework normally obtain instances from query
  /// methods (e.g. `glossaryEntryByColor`) rather than constructing them;
  /// this constructor performs no validation of the table's constraints
  /// (tag length, uniqueness) — the database enforces those.
  const GlossaryEntry({
    required this.id,
    required this.createdTimeStamp,
    required this.tagName,
    required this.description,
    required this.color,
  });

  /// Builds an entry from a raw drift row map
  /// (`QueryRow.data` / one element of `select()`'s result).
  ///
  /// The map must contain every glossary column keyed by its exact column
  /// name, with values in their raw SQLite representations (`int` for
  /// INTEGER columns, `String` for TEXT).
  ///
  /// Throws a [TypeError] if a column is missing or holds an
  /// unexpected type — a schema/query mismatch, so failing loudly
  /// is correct.
  factory GlossaryEntry.fromRow(Map<String, Object?> row) {
    return GlossaryEntry(
      id: row['id']! as int,
      createdTimeStamp: row['createdTimeStamp']! as int,
      tagName: row['tagName']! as String,
      description: row['description']! as String,
      color: row['color']! as int,
    );
  }

  /// SQLite rowid (`INTEGER PRIMARY KEY AUTOINCREMENT`).
  ///
  /// Present for schema fidelity (database viewer, export) but not used
  /// as the working identifier — see [createdTimeStamp].
  final int id;

  /// Framework-assigned creation timestamp in milliseconds since epoch;
  /// `UNIQUE NOT NULL` and the entry's principal identifier.
  ///
  /// The tags junction table foreign-keys on this value with
  /// `ON DELETE CASCADE`, so it is immutable for the lifetime of the row.
  final int createdTimeStamp;

  /// User-facing tag label; `UNIQUE NOT NULL`, non-empty, at most six
  /// characters (enforced by the table's CHECK constraint).
  final String tagName;

  /// Free-text description of the tag; `NOT NULL`, unbounded length.
  final String description;

  /// Tag color as an ARGB32 int (`Color.toARGB32()` representation);
  /// `UNIQUE NOT NULL`, so no two entries share a color.
  final int color;

  /// Inverse of [fromRow]: the entry as a column-name → value map matching
  /// the glossary schema exactly.
  ///
  /// Also JSON-encodable as-is (all values are `int` or `String`), so it
  /// plugs straight into a future export/backup payload.
  Map<String, Object?> toRow() => <String, Object?>{
    'id': id,
    'createdTimeStamp': createdTimeStamp,
    'tagName': tagName,
    'description': description,
    'color': color,
  };

  /// Value equality over all five fields.
  ///
  /// Two entries are equal only if every column matches; two rows that
  /// differ solely in [id] or [createdTimeStamp] are *not* equal, since
  /// those fields are identity.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlossaryEntry &&
          other.id == id &&
          other.createdTimeStamp == createdTimeStamp &&
          other.tagName == tagName &&
          other.description == description &&
          other.color == color;

  /// Hash consistent with [operator ==], combining all five fields.
  @override
  int get hashCode =>
      Object.hash(id, createdTimeStamp, tagName, description, color);

  /// Debug representation listing every field; not intended for UI display.
  @override
  String toString() =>
      'GlossaryEntry(id: $id, createdTimeStamp: $createdTimeStamp, '
      'tagName: $tagName, description: $description, color: $color)';
}
