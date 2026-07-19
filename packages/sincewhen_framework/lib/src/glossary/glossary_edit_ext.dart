// packages/sincewhen_framework/lib/src/glossary/glossary_edit.dart

// White space is not needed for SQL-statements
// ignore_for_file: missing_whitespace_between_adjacent_strings

part of '../since_when.dart';


/// Speciality Queries for the SinceWhen_Framework
extension GlossaryEditExt on SinceWhen {
  /// Returns `true` if a glossary entry already uses [color].
  ///
  /// [color] is the ARGB int as stored in the glossary's `color` column.
  Future<bool> glossaryColorInUse(int color) async {
    final row = await _db
        .customSelect(
          'SELECT EXISTS('
          'SELECT 1 FROM ${TableNames.glossary.name} WHERE color = ?'
          ') AS inUse',
          variables: [Variable<int>(color)],
        )
        .getSingle();
    return row.read<int>('inUse') != 0;
  }
}
