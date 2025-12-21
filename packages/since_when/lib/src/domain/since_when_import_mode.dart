// icodeforyou_flutter/packages/since_when/lib/src/domain/since_when_import_mode.dart

/// Defines how records are handled during import operations.
enum SinceWhenImportMode {
  /// Incoming records are added; duplicates are ignored (keep existing).
  merge,

  /// Incoming records are added; duplicates are overwritten with incoming.
  update,

  /// Wipe existing database records and load incoming records.
  replace,

  /// Compare editedTimeStamp; keep the newest record.
  /// If timestamps are equal, existing record is kept.
  refresh,
}
