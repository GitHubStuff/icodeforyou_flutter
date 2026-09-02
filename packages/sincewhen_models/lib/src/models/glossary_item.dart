// packages/sincewhen_models/lib/src/models/glossary_item.dart

import 'package:equatable/equatable.dart';

/// {@template glossary_item}
/// Pure Dart domain entity for a glossary record: the canonical
/// definition of a tag.
///
/// Persistence-free by design: `sincewhen_drift_framework` maps table rows
/// into this class via `@UseRowClass`, so consuming packages depend only on
/// `sincewhen_models`, never on `drift` or `sqflite`.
///
/// Constructor parameter names deliberately match the Drift column getter
/// names in `GlossaryItems` — that name correspondence is what allows the
/// Drift generator to construct instances directly from query rows.
///
/// Extends [Equatable] for value equality; `Equatable` is itself
/// `@immutable`, so the annotation is inherited.
/// {@endtemplate}
final class GlossaryItem extends Equatable {
  /// {@macro glossary_item}
  const GlossaryItem({
    required this.id,
    required this.createdTimestamp,
    required this.tag,
    required this.colorArgb,
    required this.descr,
  });

  /// Auto-incrementing primary key.
  final int id;

  /// Unique creation timestamp.
  final int createdTimestamp;

  /// Unique, non-empty tag text.
  final String tag;

  /// Unique packed ARGB color value, suitable for `Color(colorArgb)` on
  /// the Flutter side.
  final int colorArgb;

  /// The description of what the tag means
  final String descr;

  /// Returns a copy with the given fields replaced.
  GlossaryItem copyWith({
    int? id,
    int? createdTimestamp,
    String? tag,
    int? colorArgb,
    String? descr,
  }) {
    return GlossaryItem(
      id: id ?? this.id,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      tag: tag ?? this.tag,
      colorArgb: colorArgb ?? this.colorArgb,
      descr: descr ?? this.descr,
    );
  }

  @override
  List<Object?> get props => [id, createdTimestamp, tag, colorArgb, descr];

  @override
  bool get stringify => true;
}
