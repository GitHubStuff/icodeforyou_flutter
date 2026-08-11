// programs/widgetbook/lib/usecases/theme_framework/theme_mode_card.usecase.dart

import 'package:flutter/material.dart';
import 'package:theme_framework/theme_framework.dart' show ThemeModeCard;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Inset around the card so it does not touch the workbench edges.
const EdgeInsets _kPadding = EdgeInsets.all(16);

/// Presents [ThemeModeCard] in its controlled form.
///
/// The selected value comes from the `value` knob rather than from taps,
/// because the card owns no state: a tap only invokes
/// [ThemeModeCard.onChanged], which here logs the requested mode. Move the
/// knob to move the checkmark — that round trip is the whole contract, and
/// keeping it manual makes the controlled nature of the widget visible in
/// the workbench instead of papering over it with local state.
@widgetbook.UseCase(name: 'Controlled', type: ThemeModeCard)
Widget buildThemeModeCardUseCase(BuildContext context) {
  final value = context.knobs.object.dropdown<ThemeMode>(
    label: 'value',
    options: ThemeMode.values,
    initialOption: ThemeMode.system,
    labelBuilder: (mode) => mode.name,
  );

  return SingleChildScrollView(
    padding: _kPadding,
    child: ThemeModeCard(
      value: value,
      onChanged: (mode) => debugPrint('ThemeModeCard.onChanged: ${mode.name}'),
    ),
  );
}
