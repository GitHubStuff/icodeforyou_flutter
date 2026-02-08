// packages/widgetbook_workspace/lib/packages/sqlite_viewer/sqlite_viewer.usecase.dart

import 'package:flutter/material.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart'
    show DisplayQueryWidget, TextHandling;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook/widgetbook.dart' show KnobsExtension;

final _sampleColumns = ['id', 'name', 'email', 'created_at', 'status'];

final _sampleRows = <Map<String, Object?>>[
  {
    'id': 1,
    'name': 'Alice Johnson',
    'email': 'alice@example.com',
    'created_at': '2025-01-10 14:30:00',
    'status': 'active',
  },
  {
    'id': 2,
    'name': 'Bob Smith',
    'email': 'bob@example.com',
    'created_at': '2025-01-11 09:15:00',
    'status': 'pending',
  },
  {
    'id': 3,
    'name': 'Charlie Brown',
    'email': null,
    'created_at': '2025-01-12 16:45:00',
    'status': 'active',
  },
  {
    'id': 4,
    'name': 'Diana Prince',
    'email': 'diana@example.com',
    'created_at': null,
    'status': 'inactive',
  },
  {
    'id': 5,
    'name': 'A very long name that should demonstrate truncation behavior',
    'email': 'longname@example.com',
    'created_at': '2025-01-13 08:00:00',
    'status': 'active',
  },
  {
    'id': 6,
    'name': 'Frank Castle',
    'email': 'frank@example.com',
    'created_at': '2025-01-14 11:20:00',
    'status': 'pending',
  },
  {
    'id': 7,
    'name': 'Grace Hopper',
    'email': 'grace@example.com',
    'created_at': '2025-01-15 13:45:00',
    'status': 'active',
  },
  {
    'id': 8,
    'name': 'Henry Ford',
    'email': 'henry@example.com',
    'created_at': '2025-01-16 10:30:00',
    'status': null,
  },
];

@widgetbook.UseCase(name: 'Default', type: DisplayQueryWidget)
Widget buildDisplayQueryWidgetDefault(BuildContext context) {
  final showRowNumbers = context.knobs.boolean(
    label: 'Show Row Numbers',
    initialValue: false,
  );

  final textHandling = context.knobs.object.dropdown<TextHandling>(
    label: 'Text Handling',
    options: TextHandling.values,
    initialOption: TextHandling.trunc,
    labelBuilder: (value) => value.name,
  );

  final nullValueDisplay = context.knobs.string(
    label: 'Null Value Display',
    initialValue: 'NULL',
  );

  final minColumnWidth = context.knobs.double.slider(
    label: 'Min Column Width',
    initialValue: 60.0,
    min: 40.0,
    max: 150.0,
  );

  final maxColumnWidth = context.knobs.double.slider(
    label: 'Max Column Width',
    initialValue: 300.0,
    min: 150.0,
    max: 500.0,
  );

  final headerHeight = context.knobs.double.slider(
    label: 'Header Height',
    initialValue: 48.0,
    min: 32.0,
    max: 72.0,
  );

  final rowHeight = context.knobs.double.slider(
    label: 'Row Height',
    initialValue: 44.0,
    min: 32.0,
    max: 64.0,
  );

  final evenRowColorValue = context.knobs.object.dropdown<Color>(
    label: 'Even Row Color',
    options: [
      Colors.white,
      Colors.grey.shade50,
      Colors.blue.shade50,
      Colors.green.shade50,
    ],
    initialOption: Colors.white,
    labelBuilder: _colorLabel,
  );

  final oddRowColorValue = context.knobs.object.dropdown<Color>(
    label: 'Odd Row Color',
    options: [
      Colors.grey.shade100,
      Colors.grey.shade200,
      Colors.blue.shade100,
      Colors.green.shade100,
    ],
    initialOption: Colors.grey.shade100,
    labelBuilder: _colorLabel,
  );

  final headerBackgroundColorValue = context.knobs.object.dropdown<Color>(
    label: 'Header Background',
    options: [
      Colors.grey.shade200,
      Colors.blue.shade200,
      Colors.indigo.shade200,
      Colors.teal.shade200,
    ],
    initialOption: Colors.grey.shade200,
    labelBuilder: _colorLabel,
  );

  return DisplayQueryWidget(
    columns: _sampleColumns,
    rows: _sampleRows,
    evenRowStyle: const TextStyle(fontSize: 14.0, color: Colors.black87),
    oddRowStyle: const TextStyle(fontSize: 14.0, color: Colors.black87),
    headerStyle: const TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    showRowNumbers: showRowNumbers,
    textHandling: textHandling,
    nullValueDisplay: nullValueDisplay,
    minColumnWidth: minColumnWidth,
    maxColumnWidth: maxColumnWidth,
    headerHeight: headerHeight,
    rowHeight: rowHeight,
    evenRowColor: evenRowColorValue,
    oddRowColor: oddRowColorValue,
    headerBackgroundColor: headerBackgroundColorValue,
  );
}

@widgetbook.UseCase(name: 'Empty State', type: DisplayQueryWidget)
Widget buildDisplayQueryWidgetEmpty(BuildContext context) {
  final emptyMessage = context.knobs.string(
    label: 'Empty Message',
    initialValue: 'No records found',
  );

  return DisplayQueryWidget(
    columns: _sampleColumns,
    rows: const [],
    evenRowStyle: const TextStyle(fontSize: 14.0, color: Colors.black87),
    oddRowStyle: const TextStyle(fontSize: 14.0, color: Colors.black87),
    emptyWidget: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 48.0, color: Colors.grey),
          const SizedBox(height: 16.0),
          Text(
            emptyMessage,
            style: const TextStyle(fontSize: 16.0, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Dark Theme', type: DisplayQueryWidget)
Widget buildDisplayQueryWidgetDark(BuildContext context) {
  final showRowNumbers = context.knobs.boolean(
    label: 'Show Row Numbers',
    initialValue: true,
  );

  return Container(
    color: Colors.grey.shade900,
    child: DisplayQueryWidget(
      columns: _sampleColumns,
      rows: _sampleRows,
      evenRowStyle: const TextStyle(fontSize: 14.0, color: Colors.white70),
      oddRowStyle: const TextStyle(fontSize: 14.0, color: Colors.white70),
      headerStyle: const TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        color: Colors.amber,
      ),
      evenRowColor: Colors.grey.shade800,
      oddRowColor: Colors.grey.shade700,
      headerBackgroundColor: Colors.grey.shade900,
      borderColor: Colors.grey.shade700,
      showRowNumbers: showRowNumbers,
      nullValueDisplay: '—',
    ),
  );
}

@widgetbook.UseCase(name: 'Many Columns', type: DisplayQueryWidget)
Widget buildDisplayQueryWidgetManyColumns(BuildContext context) {
  final columns = [
    'id',
    'first_name',
    'last_name',
    'email',
    'phone',
    'address',
    'city',
    'state',
    'zip',
    'country',
    'created_at',
    'updated_at',
    'status',
    'role',
    'department',
  ];

  final rows = <Map<String, Object?>>[
    {
      'id': 1,
      'first_name': 'Alice',
      'last_name': 'Johnson',
      'email': 'alice@example.com',
      'phone': '555-0100',
      'address': '123 Main St',
      'city': 'Springfield',
      'state': 'IL',
      'zip': '62701',
      'country': 'USA',
      'created_at': '2025-01-10',
      'updated_at': '2025-01-12',
      'status': 'active',
      'role': 'admin',
      'department': 'Engineering',
    },
    {
      'id': 2,
      'first_name': 'Bob',
      'last_name': 'Smith',
      'email': 'bob@example.com',
      'phone': '555-0101',
      'address': '456 Oak Ave',
      'city': 'Portland',
      'state': 'OR',
      'zip': '97201',
      'country': 'USA',
      'created_at': '2025-01-11',
      'updated_at': null,
      'status': 'pending',
      'role': 'user',
      'department': 'Sales',
    },
  ];

  return DisplayQueryWidget(
    columns: columns,
    rows: rows,
    evenRowStyle: const TextStyle(fontSize: 12.0, color: Colors.black87),
    oddRowStyle: const TextStyle(fontSize: 12.0, color: Colors.black87),
    headerStyle: const TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.bold,
      color: Colors.indigo,
    ),
    showRowNumbers: true,
    minColumnWidth: 50.0,
    maxColumnWidth: 200.0,
    evenRowColor: Colors.white,
    oddRowColor: Colors.indigo.shade50,
    headerBackgroundColor: Colors.indigo.shade100,
  );
}

String _colorLabel(Color color) {
  if (color == Colors.white) return 'White';
  if (color == Colors.grey.shade50) return 'Grey 50';
  if (color == Colors.grey.shade100) return 'Grey 100';
  if (color == Colors.grey.shade200) return 'Grey 200';
  if (color == Colors.grey.shade800) return 'Grey 800';
  if (color == Colors.grey.shade700) return 'Grey 700';
  if (color == Colors.grey.shade900) return 'Grey 900';
  if (color == Colors.blue.shade50) return 'Blue 50';
  if (color == Colors.blue.shade100) return 'Blue 100';
  if (color == Colors.blue.shade200) return 'Blue 200';
  if (color == Colors.green.shade50) return 'Green 50';
  if (color == Colors.green.shade100) return 'Green 100';
  if (color == Colors.indigo.shade200) return 'Indigo 200';
  if (color == Colors.teal.shade200) return 'Teal 200';
  return color.toString();
}
