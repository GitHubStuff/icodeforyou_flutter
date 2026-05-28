// widgetbook_workspace/lib/packages/sqlite_viewer/sqlite_viewer_page/metadata_loaded.usecase.dart
import 'package:flutter/material.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/packages/sqlite_viewer/mock/mock_data.dart';

@widgetbook.UseCase(name: 'Metadata Loaded', type: SqliteViewerPage)
Widget sqliteViewerMetadataLoaded(BuildContext context) {
  const source = MockSqliteViewerSource();
  final cubit = SqliteViewerCubit.withState(
    source,
    const MetadataLoaded(metadata: kMockMetadata),
  );
  return SqliteViewerPage.forWidgetbook(source: source, cubit: cubit);
}
