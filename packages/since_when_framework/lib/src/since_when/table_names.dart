// packages/since_when_framework/lib/src/since_when/table_names.dart

/// Canonical table names for the since_when schema.
///
/// Kept in one place so every CREATE, DROP, INDEX, and query references
/// the same identifier.
abstract final class TableNames {
  /// Main records table.
  static const String sinceWhen = 'sinceWhen';

  /// Tag glossary table.
  static const String tagGlossary = 'sinceWhenGlossary';

  /// Join table linking records to tags.
  static const String tags = 'sinceWhenTags';
}
