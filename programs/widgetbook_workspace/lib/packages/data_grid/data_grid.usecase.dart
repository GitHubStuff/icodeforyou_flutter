// programs/widgetbook_workspace/lib/packages/data_grid/data_grid.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:data_grid/data_grid.dart' show DataDensity, DataGrid;
import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart' show showToast;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Sample query result, held as a single const instance so knob-driven
/// rebuilds never register as a data change in [DataGrid.didUpdateWidget]
/// (which compares by identity). The rows deliberately cover every sort
/// branch: mixed-case names (isCaseSensitive), nulls (null placement),
/// numerics, a mixed-type badge column (string fallback), and one long
/// note (ellipsis + cell inspection dialog).
const List<Map<String, Object?>> _kSampleData = [
  {
    'id': 1,
    'name': 'alfie',
    'species': 'cat',
    'weight_kg': 4.2,
    'age': 3,
    'badge': 7,
    'color': 'ginger',
    'notes': 'Sleeps on the router',
  },
  {
    'id': 2,
    'name': 'Bella',
    'species': 'cat',
    'weight_kg': 3.8,
    'age': 5,
    'badge': 'seven',
    'color': 'tabby',
    'notes': null,
  },
  {
    'id': 3,
    'name': 'ZigZag',
    'species': 'cat',
    'weight_kg': null,
    'age': 2,
    'badge': 12,
    'color': 'black',
    'notes': 'Escaped the carrier twice',
  },
  {
    'id': 4,
    'name': 'ada',
    'species': 'cat',
    'weight_kg': 5.1,
    'age': 7,
    'badge': 3,
    'color': 'calico',
    'notes':
        'Named after Lovelace, obviously. Prefers the mechanical keyboard to any cat bed purchased so far, and has strong opinions about the NAS fan noise.',
  },
  {
    'id': 5,
    'name': 'Churro',
    'species': 'cat',
    'weight_kg': 6.0,
    'age': 4,
    'badge': 'two',
    'color': 'brown',
    'notes': null,
  },
  {
    'id': 6,
    'name': 'delta',
    'species': 'dog',
    'weight_kg': 12.4,
    'age': 1,
    'badge': 9,
    'color': 'white',
    'notes': 'Not actually a cat',
  },
  {
    'id': 7,
    'name': 'Echo',
    'species': 'cat',
    'weight_kg': 4.4,
    'age': 9,
    'badge': null,
    'color': 'grey',
    'notes': 'Answers to nothing',
  },
  {
    'id': 8,
    'name': 'fig',
    'species': 'cat',
    'weight_kg': 3.3,
    'age': 2,
    'badge': 21,
    'color': 'tortie',
    'notes': null,
  },
  {
    'id': 9,
    'name': 'Gadget',
    'species': 'cat',
    'weight_kg': 4.9,
    'age': 6,
    'badge': 'one',
    'color': 'ginger',
    'notes': 'Chews cables. All of them.',
  },
  {
    'id': 10,
    'name': 'hopper',
    'species': 'cat',
    'weight_kg': 4.0,
    'age': 3,
    'badge': 5,
    'color': 'black',
    'notes': 'Named after Grace',
  },
  {
    'id': 11,
    'name': 'Iris',
    'species': 'cat',
    'weight_kg': null,
    'age': 8,
    'badge': 2,
    'color': 'white',
    'notes': null,
  },
  {
    'id': 12,
    'name': 'juno',
    'species': 'cat',
    'weight_kg': 5.5,
    'age': 4,
    'badge': 'ten',
    'color': 'tabby',
    'notes': 'Sits on the warm switch',
  },
];

/// Column width overrides for the columnWidths knob. The notes column is
/// widened; the id column requests 20 — far below its caption minimum —
/// to demonstrate that overrides can widen freely but never shrink a
/// column below its full header text plus sort indicator.
const Map<String, int> _kColumnWidthOverrides = {'notes': 280, 'id': 20};

/// Header style options demonstrating the merge-over-theme contract: a
/// partial recolor keeps the base metrics; a larger size grows the row
/// height and every caption-derived column minimum.
const List<({String name, TextStyle? style})> _kHeaderStyleOptions = [
  (name: 'default (null)', style: null),
  (name: 'amber recolor (partial)', style: TextStyle(color: Colors.amber)),
  (name: 'large (fontSize 20)', style: TextStyle(fontSize: 20)),
];

/// Data style options; monospace suits the query-result framing, and the
/// large size demonstrates that the taller of chrome and data claims the
/// row height.
const List<({String name, TextStyle? style})> _kDataStyleOptions = [
  (name: 'default (null)', style: null),
  (name: 'monospace', style: TextStyle(fontFamily: 'monospace')),
  (name: 'large (fontSize 18)', style: TextStyle(fontSize: 18)),
];

/// Chrome color options, with the theme's secondaryContainer default
/// first.
const List<({String name, Color? color})> _kChromeColorOptions = [
  (name: 'default (secondaryContainer)', color: null),
  (name: 'Teal', color: Colors.teal),
  (name: 'Deep Purple', color: Colors.deepPurple),
];

@widgetbook.UseCase(name: 'Default', type: DataGrid)
Widget buildDataGridUseCase(BuildContext context) {
  final isCaseSensitive = context.knobs.boolean(
    label: 'isCaseSensitive',
    initialValue: true,
    description:
        'Sort the name column to see it: case-sensitive orders '
        'every capitalized name before every lowercase one.',
  );
  final overrideWidths = context.knobs.boolean(
    label: 'columnWidths override',
    description:
        'Widens notes to 280 and requests 20 for id — the id '
        'request is clamped up to its caption minimum.',
  );
  final headerStyleOption = context.knobs.object.dropdown(
    label: 'headerStyle',
    options: _kHeaderStyleOptions,
    initialOption: _kHeaderStyleOptions.first,
    labelBuilder: (option) => option.name,
  );
  final dataStyleOption = context.knobs.object.dropdown(
    label: 'dataStyle',
    options: _kDataStyleOptions,
    initialOption: _kDataStyleOptions.first,
    labelBuilder: (option) => option.name,
  );
  final chromeColorOption = context.knobs.object.dropdown(
    label: 'chromeColor',
    options: _kChromeColorOptions,
    initialOption: _kChromeColorOptions.first,
    labelBuilder: (option) => option.name,
  );
  final density = context.knobs.object.dropdown(
    label: 'density (DataDensity)',
    options: DataDensity.values,
    initialOption: DataDensity.standard,
    labelBuilder: (option) => option.name,
    description:
        'Density sets the row-height floor; the styles set the '
        'content claim. The taller wins, so dense under a large style '
        'is a silent no-op by design.',
  );
  final haptic = context.knobs.object.dropdown(
    label: 'haptic',
    options: HapticIntensity.values,
    initialOption: HapticIntensity.light,
    labelBuilder: (option) => option.name,
    description:
        'Fires on every tap in the grid; feel it on a device, '
        'not in the desktop workbench.',
  );

  return Padding(
    padding: const EdgeInsets.all(12),
    child: DataGrid(
      data: _kSampleData,
      columnWidths: overrideWidths ? _kColumnWidthOverrides : null,
      headerStyle: headerStyleOption.style,
      dataStyle: dataStyleOption.style,
      chromeColor: chromeColorOption.color,
      isCaseSensitive: isCaseSensitive,
      density: density.toVisualDensity(),
      haptic: haptic,
      onRowTap: (rowNumber, rowData) =>
          showToast('onRowTap($rowNumber, id: ${rowData['id']})'),
    ),
  );
}
