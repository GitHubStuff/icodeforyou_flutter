// widgetbook_workspace/lib/packages/sqlite_viewer/sqlite_viewer_page/query_result.usecase.dart
import 'package:flutter/material.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/packages/sqlite_viewer/mock/mock_data.dart';

@widgetbook.UseCase(name: 'Query Result', type: SqliteViewerPage)
Widget sqliteViewerQueryResult(BuildContext context) {
  const source = MockSqliteViewerSource();
  final cubit = SqliteViewerCubit.withState(
    source,
    const QueryResultLoaded(
      metadata: kMockMetadata,
      query: 'SELECT * FROM users WHERE active = 1',
      columns: kUsersColumns,
      rows: kUsersRows,
    ),
  );
  return SqliteViewerPage.forWidgetbook(source: source, cubit: cubit);
}
