// lib/package/since_when/since_when.usecase.dart

import 'package:flutter/material.dart';
import 'package:since_when/since_when.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:widgetbook_workspace/packages/since_when/_info_demos.dart';
import 'package:widgetbook_workspace/packages/since_when/_record_demos.dart';
import 'package:widgetbook_workspace/packages/since_when/_tag_demos.dart';

/// Demonstrates creating and displaying SinceWhenRecord entries.
@widgetbook.UseCase(name: 'Record Creation Demo', type: SinceWhenRecord)
Widget sinceWhenRecordCreation(BuildContext context) {
  return const RecordCreationDemo();
}

/// Demonstrates hierarchical parent-child record relationships.
@widgetbook.UseCase(name: 'Hierarchical Records', type: SinceWhenRecord)
Widget sinceWhenHierarchical(BuildContext context) {
  return const HierarchicalRecordsDemo();
}

/// Demonstrates tag filtering with TagMatchMode (Any/All).
@widgetbook.UseCase(name: 'Tags Demo', type: SinceWhenRecord)
Widget sinceWhenTags(BuildContext context) {
  return const TagsDemo();
}

/// Displays database table information.
@widgetbook.UseCase(name: 'Table Info', type: TableInfo)
Widget sinceWhenTableInfo(BuildContext context) {
  return const TableInfoDemo();
}

/// Interactive playground for creating custom records.
@widgetbook.UseCase(name: 'Interactive Playground', type: SinceWhenRecord)
Widget sinceWhenPlayground(BuildContext context) {
  final metaData = context.knobs.string(
    label: 'MetaData',
    initialValue: 'My custom record',
  );
  final dataString = context.knobs.string(
    label: 'Data String',
    initialValue: 'This is the content of the record...',
  );
  final category = context.knobs.object.dropdown<String>(
    label: 'Category',
    options: ['notes', 'ideas', 'tasks', 'decisions', 'questions'],
    initialOption: 'notes',
  );
  final tagsPreset = context.knobs.object.dropdown<String>(
    label: 'Tags Preset',
    options: [
      'personal',
      'work',
      'urgent',
      'personal, ideas',
      'work, urgent',
      'none',
    ],
    initialOption: 'personal',
  );
  return PlaygroundDemo(
    metaData: metaData,
    dataString: dataString,
    category: category,
    tagsPreset: tagsPreset,
  );
}

/// Demonstrates SinceWhenFailure types.
@widgetbook.UseCase(name: 'Failure Types', type: SinceWhenFailure)
Widget sinceWhenFailures(BuildContext context) {
  return const FailureTypesDemo();
}

/// Demonstrates TagMatchMode enum.
@widgetbook.UseCase(name: 'TagMatchMode', type: TagMatchMode)
Widget tagMatchModeDemo(BuildContext context) {
  return const TagMatchModeDemo();
}
