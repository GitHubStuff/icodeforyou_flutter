// programs/widgetbook/lib/usecases/theme_manager/theme_radio_row.usecase.dart

import 'package:flutter/material.dart';
import 'package:theme_manager/theme_manager.dart'
    show ThemeOption, ThemeRadioRow;

import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Inset around the row so it does not touch the workbench edges.
const EdgeInsets _kPadding = EdgeInsets.all(16);

/// Icon shown for every knob-built option; the icon itself is exercised by
/// the [ThemeSelectionBody] use-case, so a fixed one keeps this row's knobs
/// focused on what varies per row.
const IconData _kIcon = Icons.brightness_auto;

/// Presents [ThemeRadioRow] in its controlled form, inside the [RadioGroup]
/// the row requires from an ancestor.
///
/// The row owns no state: the `mode` knob builds its [ThemeOption], the
/// `label` knob its text, and the `selected` knob drives the ancestor
/// [RadioGroup.groupValue] that lights the radio. Taps only invoke
/// [ThemeRadioRow.onChanged], which here logs the requested mode — flip the
/// `selected` knob to move the dot, making the row's controlled nature
/// visible instead of papering over it with local state.
///
/// The [Material] ancestor exists because the row's [InkWell] requires one;
/// in production the enclosing [Scaffold] provides it.
@widgetbook.UseCase(name: 'Controlled', type: ThemeRadioRow)
Widget buildThemeRadioRowUseCase(BuildContext context) {
  final mode = context.knobs.object.dropdown<ThemeMode>(
    label: 'mode',
    options: ThemeMode.values,
    initialOption: ThemeMode.system,
    labelBuilder: (mode) => mode.name,
  );
  final label = context.knobs.string(
    label: 'label',
    initialValue: 'System',
  );
  final selected = context.knobs.boolean(
    label: 'selected',
    initialValue: true,
  );

  return Material(
    type: MaterialType.transparency,
    child: Padding(
      padding: _kPadding,
      child: RadioGroup<ThemeMode>(
        groupValue: selected ? mode : null,
        onChanged: (mode) => debugPrint('RadioGroup.onChanged: ${mode?.name}'),
        child: ThemeRadioRow(
          option: ThemeOption(mode: mode, icon: _kIcon, label: label),
          onChanged: (mode) =>
              debugPrint('ThemeRadioRow.onChanged: ${mode.name}'),
        ),
      ),
    ),
  );
}
