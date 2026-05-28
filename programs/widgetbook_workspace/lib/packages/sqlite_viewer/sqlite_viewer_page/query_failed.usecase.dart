// widgetbook_workspace/lib/packages/sqlite_viewer/sqlite_viewer_page/query_failed.usecase.dart
import 'package:flutter/material.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/packages/sqlite_viewer/mock/mock_data.dart';

@widgetbook.UseCase(name: 'Query Failed', type: SqliteViewerPage)
Widget sqliteViewerQueryFailed(BuildContext context) {
  const source = MockSqliteViewerSource();
  const query = 'SELECT * FROM nonexistent_table';
  final cubit = SqliteViewerCubit.withState(
    source,
    const QueryFailed(
      metadata: kMockMetadata,
      query: query,
      failure: ViewerQueryFailed(
        query,
        'no such table: nonexistent_table',
      ),
    ),
  );
  return SqliteViewerPage.forWidgetbook(source: source, cubit: cubit);
}
