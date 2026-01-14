// packages/sqlite_table_viewer/lib/src/models/text_handling.dart

/// Defines how long text content is handled within table cells.
enum TextHandling {
  /// Truncate text with ellipsis when it exceeds available width.
  trunc,

  /// Wrap text to multiple lines.
  wrap,
}
