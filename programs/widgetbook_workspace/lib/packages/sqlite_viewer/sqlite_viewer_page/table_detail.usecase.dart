// widgetbook_workspace/lib/packages/sqlite_viewer/sqlite_viewer_page/table_detail.usecase.dart
import 'package:flutter/material.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/packages/sqlite_viewer/mock/mock_data.dart';

@widgetbook.UseCase(name: 'Table Detail', type: SqliteViewerPage)
Widget sqliteViewerTableDetail(BuildContext context) {
  const source = MockSqliteViewerSource();
  final cubit = SqliteViewerCubit.withState(
    source,
    const TableDetailLoaded(
      metadata: kMockMetadata,
      tableName: 'users',
      columns: kUsersColumns,
      tableInfo: kUsersTableInfo,
      indexList: kUsersIndexList,
      foreignKeys: kUsersForeignKeys,
      rows: kUsersRows,
      rowCount: 6,
    ),
  );
  return SqliteViewerPage.forWidgetbook(source: source, cubit: cubit);
}
