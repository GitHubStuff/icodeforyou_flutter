// icodeforyou_flutter/packages/since_when/lib/src/domain/tag_match_mode.dart

/// Defines how multiple tags are matched when filtering records.
enum TagMatchMode {
  /// Returns records that have **at least one** of the specified tags.
  ///
  /// Example: tags ['flutter', 'dart'] returns records tagged with
  /// 'flutter' OR 'dart' (or both).
  any,

  /// Returns records that have **all** of the specified tags.
  ///
  /// Example: tags ['flutter', 'dart'] returns only records tagged
  /// with BOTH 'flutter' AND 'dart'.
  all,
}
