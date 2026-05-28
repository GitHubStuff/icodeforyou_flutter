// widgetbook_workspace/lib/packages/sqlite_viewer/sqlite_viewer_metadata_panel.usecase.dart
import 'package:flutter/material.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/packages/sqlite_viewer/mock/mock_data.dart';

@widgetbook.UseCase(name: 'Default', type: SqliteViewerMetadataPanel)
Widget sqliteViewerMetadataPanelDefault(BuildContext context) {
  final tableOptions = <String>['(none)', ...kMockMetadata.tables];
  final selectedKey = context.knobs.object.dropdown<String>(
    label: 'selectedTable',
    options: tableOptions,
    initialOption: 'users',
  );

  final isLoading = context.knobs.boolean(
    label: 'isLoading',
    initialValue: false,
  );

  final isInMemory = context.knobs.boolean(
    label: 'in-memory database',
    initialValue: false,
  );

  final wireRefresh = context.knobs.boolean(
    label: 'wire onRefresh',
    initialValue: true,
  );

  final wireSelect = context.knobs.boolean(
    label: 'wire onTableSelected',
    initialValue: true,
  );

  final metadata = isInMemory
      ? kMockMetadata.copyWith(fullPath: DatabaseMetadata.inMemoryToken)
      : kMockMetadata;

  return SizedBox(
    width: 320,
    child: SqliteViewerMetadataPanel(
      metadata: metadata,
      selectedTable: selectedKey == '(none)' ? null : selectedKey,
      onTableSelected: wireSelect ? (_) {} : null,
      onRefresh: wireRefresh ? () {} : null,
      isLoading: isLoading,
    ),
  );
}
