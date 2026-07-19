// packages/sincewhen_framework/lib/src/error_handler/error_handler.dart

import 'package:sincewhen_framework/src/sql/table_names.dart' show TableNames;

class ErrorHandler {
  /// Rejects non-CREATE statements and any attempt to (re)define a
  /// core table.
  static void validateAddTables(List<String> statements) {
    final createTable = RegExp(
      r'^\s*CREATE\s+TABLE\s+(IF\s+NOT\s+EXISTS\s+)?[`"\[]?(\w+)',
      caseSensitive: false,
    );
    final coreNames = TableNames.values
        .map((t) => t.name.toLowerCase())
        .toSet();

    for (final sql in statements) {
      final match = createTable.firstMatch(sql);
      if (match == null) {
        throw ArgumentError(
          'addTables only accepts CREATE TABLE statements. Rejected:\n$sql',
        );
      }
      final tableName = match.group(2)!.toLowerCase();
      if (coreNames.contains(tableName)) {
        throw ArgumentError(
          '"$tableName" is a core SinceWhen table and cannot be redefined.',
        );
      }
    }
  }
}
