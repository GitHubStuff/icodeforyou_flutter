// packages/sincewhen_models/lib/src/models/since_when_item.dart

import 'package:equatable/equatable.dart';

/// {@template since_when_item}
/// Pure Dart domain entity for a since-when record.
///
/// Persistence-free by design: `sincewhen_drift_framework` maps table rows
/// into this class via `@UseRowClass`, so consuming packages depend only on
/// `sincewhen_models`, never on `drift` or `sqflite`.
///
/// Constructor parameter names deliberately match the Drift column getter
/// names in `SinceWhenItems` — that name correspondence is what allows the
/// Drift generator to construct instances directly from query rows.
///
/// Extends [Equatable] for value equality; `Equatable` is itself
/// `@immutable`, so the annotation is inherited.
/// {@endtemplate}
final class SinceWhenItem extends Equatable {
  /// {@macro since_when_item}
  const SinceWhenItem({
    required this.id,
    required this.createdTimestamp,
    required this.reviewedTimestamp,
    required this.editedTimestamp,
    required this.sequenceNumber,
    required this.content,
    this.parentTimestamp,
    this.eventTimestamp,
    this.metaData,
    this.tldr,
  });

  /// Auto-incrementing primary key.
  final int id;

  /// Unique creation timestamp; foreign key target for tag rows.
  final int createdTimestamp;

  /// Last-reviewed timestamp.
  final int reviewedTimestamp;

  /// Last-edited timestamp.
  final int editedTimestamp;

  /// Ordering within siblings; defaults to 0 at the persistence layer.
  final int sequenceNumber;

  /// Required record content.
  final String content;

  /// Creation timestamp of the parent record, if any.
  final int? parentTimestamp;

  /// Timestamp of the event this record describes, if any.
  final int? eventTimestamp;

  /// Optional metadata payload.
  final String? metaData;

  /// Optional short summary of [content].
  final String? tldr;

  /// Returns a copy with the given fields replaced.
  ///
  /// Nullable fields use sentinel defaults so callers can explicitly set
  /// them to `null` (e.g. detaching a parent) rather than being unable to
  /// distinguish "unchanged" from "cleared".
  SinceWhenItem copyWith({
    int? id,
    int? createdTimestamp,
    int? reviewedTimestamp,
    int? editedTimestamp,
    int? sequenceNumber,
    String? content,
    Object? parentTimestamp = _unset,
    Object? eventTimestamp = _unset,
    Object? metaData = _unset,
    Object? tldr = _unset,
  }) {
    return SinceWhenItem(
      id: id ?? this.id,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      reviewedTimestamp: reviewedTimestamp ?? this.reviewedTimestamp,
      editedTimestamp: editedTimestamp ?? this.editedTimestamp,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      content: content ?? this.content,
      parentTimestamp: parentTimestamp == _unset
          ? this.parentTimestamp
          : parentTimestamp as int?,
      eventTimestamp: eventTimestamp == _unset
          ? this.eventTimestamp
          : eventTimestamp as int?,
      metaData: metaData == _unset ? this.metaData : metaData as String?,
      tldr: tldr == _unset ? this.tldr : tldr as String?,
    );
  }

  static const Object _unset = Object();

  @override
  List<Object?> get props => [
    id,
    createdTimestamp,
    reviewedTimestamp,
    editedTimestamp,
    sequenceNumber,
    content,
    parentTimestamp,
    eventTimestamp,
    metaData,
    tldr,
  ];

  @override
  bool get stringify => true;
}
