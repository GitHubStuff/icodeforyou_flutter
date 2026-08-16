// packages/sincewhen_models/lib/src/models/tag_item.dart

import 'package:equatable/equatable.dart';

/// {@template tag_item}
/// Pure Dart domain entity for a tag record: one link between a
/// since-when record and a glossary entry.
///
/// Persistence-free by design: `sincewhen_drift_framework` maps table rows
/// into this class via `@UseRowClass`, so consuming packages depend only on
/// `sincewhen_models`, never on `drift` or `sqflite`.
///
/// Constructor parameter names deliberately match the Drift column getter
/// names in `TagItems` — that name correspondence is what allows the
/// Drift generator to construct instances directly from query rows.
///
/// Extends [Equatable] for value equality; `Equatable` is itself
/// `@immutable`, so the annotation is inherited.
/// {@endtemplate}
final class TagItem extends Equatable {
  /// {@macro tag_item}
  const TagItem({
    required this.id,
    required this.recordTimestamp,
    required this.glossaryTimestamp,
  });

  /// Auto-incrementing primary key.
  final int id;

  /// Creation timestamp of the tagged since-when record.
  final int recordTimestamp;

  /// Creation timestamp of the glossary entry applied as the tag.
  final int glossaryTimestamp;

  /// Returns a copy with the given fields replaced.
  TagItem copyWith({
    int? id,
    int? recordTimestamp,
    int? glossaryTimestamp,
  }) {
    return TagItem(
      id: id ?? this.id,
      recordTimestamp: recordTimestamp ?? this.recordTimestamp,
      glossaryTimestamp: glossaryTimestamp ?? this.glossaryTimestamp,
    );
  }

  @override
  List<Object?> get props => [id, recordTimestamp, glossaryTimestamp];

  @override
  bool get stringify => true;
}
