// programs/widgetbook/lib/usecases/theme_manager/theme_selection_body.usecase.dart

import 'package:flutter/material.dart';
import 'package:theme_manager/theme_manager.dart'
    show ThemeOption, ThemeSelectionBody;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// The canonical three options, matching the fixed set `MaterialPreference`
/// builds in production.
const List<ThemeOption> _kOptions = <ThemeOption>[
  ThemeOption(
    mode: ThemeMode.system,
    icon: Icons.brightness_auto,
    label: 'System',
  ),
  ThemeOption(mode: ThemeMode.dark, icon: Icons.dark_mode, label: 'Dark'),
  ThemeOption(mode: ThemeMode.light, icon: Icons.light_mode, label: 'Light'),
];

/// Presents [ThemeSelectionBody] in its controlled form.
///
/// The body owns the [RadioGroup] but not the selection: the `current` knob
/// drives which dot is lit, and taps only invoke
/// [ThemeSelectionBody.onChanged], which here logs the requested mode. Move
/// the knob to move the dot — the same round trip its production host
/// (`MaterialPreference`) completes through a cubit.
///
/// The `title` knob exercises the heading. The [Material] ancestor exists
/// because each row's [InkWell] requires one; in production the enclosing
/// [Scaffold] provides it.
@widgetbook.UseCase(name: 'Controlled', type: ThemeSelectionBody)
Widget buildThemeSelectionBodyUseCase(BuildContext context) {
  final title = context.knobs.string(
    label: 'title',
    initialValue: 'Theme',
  );
  final current = context.knobs.object.dropdown<ThemeMode>(
    label: 'current',
    options: ThemeMode.values,
    initialOption: ThemeMode.system,
    labelBuilder: (mode) => mode.name,
  );

  return Material(
    type: MaterialType.transparency,
    child: SingleChildScrollView(
      child: ThemeSelectionBody(
        title: title,
        options: _kOptions,
        current: current,
        onChanged: (mode) =>
            debugPrint('ThemeSelectionBody.onChanged: ${mode.name}'),
      ),
    ),
  );
}
