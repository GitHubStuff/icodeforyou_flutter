// packages/sincewhen_framework/lib/src/sql/table_names.dart

/// Canonical SQL table names used by the SinceWhen framework.
///
/// Each value corresponds to a table in the local database. Use the
/// built-in [name] property to get the table name as a string when
/// constructing queries:
///
/// ```dart
/// final query = 'SELECT * FROM ${TableNames.glossary.name}';
/// ```
enum TableNames {
  /// Stores the user's "since when" entries — the core records
  /// tracking when something began or last occurred.
  sinceWhen,

  /// Stores glossary definitions and reference terms.
  glossary,

  /// Stores tags used to categorize and filter entries.
  tags,
}
