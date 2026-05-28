// widgetbook_workspace/lib/packages/sqlite_viewer/sqlite_viewer_page/connection_failed.usecase.dart
import 'package:flutter/material.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/packages/sqlite_viewer/mock/mock_data.dart';

@widgetbook.UseCase(name: 'Connection Failed', type: SqliteViewerPage)
Widget sqliteViewerConnectionFailed(BuildContext context) {
  const source = MockSqliteViewerSource();
  final cubit = SqliteViewerCubit.withState(
    source,
    const ViewerConnectionFailed(
      failure: ViewerDatabaseNotOpen(),
    ),
  );
  return SqliteViewerPage.forWidgetbook(source: source, cubit: cubit);
}
