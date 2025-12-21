// icodeforyou_flutter/packages/since_when/lib/src/domain/since_when_record.dart


import 'package:freezed_annotation/freezed_annotation.dart';

part 'since_when_record.freezed.dart';
part 'since_when_record.g.dart';

/// A timestamped record with hierarchical relationships and tagging.
///
/// Records are uniquely identified by [createdTimeStamp] (ISO8601 UTC).
/// Records can have parent-child relationships via [parentTimeStamp].
/// Multiple tags can be associated with each record.
// Old: class SinceWhenRecord with _$SinceWhenRecord {
// New: sealed class for Freezed 3.x mixin pattern
@freezed
sealed class SinceWhenRecord with _$SinceWhenRecord {
  /// Creates a [SinceWhenRecord].
  const factory SinceWhenRecord({
    /// Auto-increment ID for internal database use.
    required int id,

    /// Unique identifier for this record (ISO8601 UTC).
    required String createdTimeStamp,

    /// Timestamp of last review (ISO8601 UTC).
    required String reviewedTimeStamp,

    /// Timestamp of last edit (ISO8601 UTC).
    required String editedTimeStamp,

    /// Metadata string (guideline: ~100 characters).
    required String metaData,

    /// User-defined ordering within sibling records.
    /// Parent records have sequenceNumber 0.
    required int sequenceNumber,

    /// Primary data content (unlimited length).
    required String dataString,

    /// Free-form category classification.
    required String category,

    /// List of tags associated with this record.
    required List<String> tags,

    /// Reference to parent record's [createdTimeStamp], if any.
    String? parentTimeStamp,

    /// Optional metadata timestamp (ISO8601 UTC).
    String? metaTimeStamp,
  }) = _SinceWhenRecord;

  /// Creates a [SinceWhenRecord] from JSON.
  factory SinceWhenRecord.fromJson(Map<String, dynamic> json) =>
      _$SinceWhenRecordFromJson(json);
}
