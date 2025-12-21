// icodeforyou_flutter/packages/since_when/lib/src/domain/table_info.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:since_when/since_when.dart';

/// Information about a database table.
///
/// Used by [SinceWhenDatabase.getTableListInfo] to return
/// metadata about tables in the database.
@immutable
class TableInfo {
  /// Creates a [TableInfo] instance.
  const TableInfo({
    required this.tableName,
    required this.rowCount,
  });

  /// The name of the table.
  final String tableName;

  /// The number of rows in the table.
  final int rowCount;

  @override
  String toString() => 'TableInfo(tableName: $tableName, rowCount: $rowCount)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TableInfo &&
        other.tableName == tableName &&
        other.rowCount == rowCount;
  }

  @override
  int get hashCode => Object.hash(tableName, rowCount);
}
