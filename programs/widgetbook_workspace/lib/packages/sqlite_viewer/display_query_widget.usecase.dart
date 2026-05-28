// widgetbook_workspace/lib/packages/sqlite_viewer/display_query_widget.usecase.dart
import 'package:flutter/material.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/packages/sqlite_viewer/mock/mock_data.dart';

@widgetbook.UseCase(name: 'Default', type: DisplayQueryWidget)
Widget displayQueryWidgetDefault(BuildContext context) {
  final textHandling = context.knobs.object.dropdown<TextHandling>(
    label: 'textHandling',
    options: TextHandling.values,
    initialOption: TextHandling.trunc,
    labelBuilder: (t) => t.name,
  );

  final showRowNumbers = context.knobs.boolean(
    label: 'showRowNumbers',
    initialValue: false,
  );

  final nullValueDisplay = context.knobs.string(
    label: 'nullValueDisplay',
    initialValue: 'NULL',
  );

  final cellPaddingH = context.knobs.double.slider(
    label: 'cellPadding.horizontal',
    initialValue: 12,
    min: 0,
    max: 48,
    divisions: 48,
  );

  final cellPaddingV = context.knobs.double.slider(
    label: 'cellPadding.vertical',
    initialValue: 8,
    min: 0,
    max: 48,
    divisions: 48,
  );

  final minColumnWidth = context.knobs.double.slider(
    label: 'minColumnWidth',
    initialValue: 60,
    min: 20,
    max: 200,
    divisions: 36,
  );

  final maxColumnWidth = context.knobs.double.slider(
    label: 'maxColumnWidth',
    initialValue: 300,
    min: 80,
    max: 600,
    divisions: 52,
  );

  final headerHeight = context.knobs.double.slider(
    label: 'headerHeight',
    initialValue: 48,
    min: 24,
    max: 96,
    divisions: 36,
  );

  final rowHeight = context.knobs.double.slider(
    label: 'rowHeight',
    initialValue: 44,
    min: 24,
    max: 96,
    divisions: 36,
  );

  final useEmpty = context.knobs.boolean(
    label: 'use empty rows (show emptyWidget)',
    initialValue: false,
  );

  final scheme = Theme.of(context).colorScheme;
  final body =
      Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14);

  return Padding(
    padding: const EdgeInsets.all(16),
    child: DisplayQueryWidget(
      columns: kUsersColumns,
      rows: useEmpty ? const [] : kUsersRows,
      evenRowStyle: body,
      oddRowStyle: body,
      headerStyle: body.copyWith(fontWeight: FontWeight.bold),
      evenRowColor: scheme.surface,
      oddRowColor: scheme.surfaceContainerLowest,
      headerBackgroundColor: scheme.surfaceContainerHighest,
      cellPadding: EdgeInsets.symmetric(
        horizontal: cellPaddingH,
        vertical: cellPaddingV,
      ),
      nullValueDisplay: nullValueDisplay,
      textHandling: textHandling,
      showRowNumbers: showRowNumbers,
      minColumnWidth: minColumnWidth,
      maxColumnWidth: maxColumnWidth,
      headerHeight: headerHeight,
      rowHeight: rowHeight,
    ),
  );
}
