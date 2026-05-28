// widgetbook_workspace/lib/packages/sqlite_viewer/sql_command.usecase.dart
import 'package:flutter/material.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: SqlCommand)
Widget sqlCommandDefault(BuildContext context) {
  // SqlCommand takes no constructor parameters and manages its own popover
  // internally (a single top-level _controller / _popoverHandle in the
  // package). Tap the button to open the editor; tap Save or Cancel to
  // dismiss.
  return const Padding(
    padding: EdgeInsets.all(24),
    child: Center(child: SqlCommand()),
  );
}
