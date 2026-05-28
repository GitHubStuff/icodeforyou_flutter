// widgetbook_workspace/lib/packages/sqlite_viewer/sqlite_viewer_table_detail.usecase.dart
import 'package:flutter/material.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/packages/sqlite_viewer/mock/mock_data.dart';

@widgetbook.UseCase(name: 'Default', type: SqliteViewerTableDetail)
Widget sqliteViewerTableDetailDefault(BuildContext context) {
  final textHandling = context.knobs.object.dropdown<TextHandling>(
    label: 'textHandling',
    options: TextHandling.values,
    initialOption: TextHandling.trunc,
    labelBuilder: (t) => t.name,
  );

  final showRowNumbers = context.knobs.boolean(
    label: 'showRowNumbers',
    initialValue: true,
  );

  final isLoading = context.knobs.boolean(
    label: 'isLoading',
    initialValue: false,
  );

  final wireRefresh = context.knobs.boolean(
    label: 'wire onRefresh',
    initialValue: true,
  );

  final useEmpty = context.knobs.boolean(
    label: 'empty data',
    initialValue: false,
  );

  final nullValueDisplay = context.knobs.string(
    label: 'nullValueDisplay',
    initialValue: 'NULL',
  );

  return SqliteViewerTableDetail(
    tableName: 'users',
    columns: kUsersColumns,
    tableInfo: kUsersTableInfo,
    indexList: kUsersIndexList,
    foreignKeys: kUsersForeignKeys,
    rows: useEmpty ? const [] : kUsersRows,
    rowCount: useEmpty ? 0 : kUsersRows.length,
    onRefresh: wireRefresh ? () {} : null,
    isLoading: isLoading,
    showRowNumbers: showRowNumbers,
    nullValueDisplay: nullValueDisplay,
    textHandling: textHandling,
  );
}
