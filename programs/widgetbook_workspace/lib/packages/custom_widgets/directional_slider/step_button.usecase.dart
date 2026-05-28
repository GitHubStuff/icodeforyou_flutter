// programs/widgetbook_workspace/lib/packages/custom_widgets/directional_slider/step_button.usecase.dart
import 'package:custom_widgets/src/directional_slider/buttons/step_button.dart';
import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: StepButton)
Widget stepButtonDefault(BuildContext context) {
  final iconOptions = <String, IconData>{
    'add': Icons.add,
    'remove': Icons.remove,
    'arrow_upward': Icons.arrow_upward,
    'arrow_downward': Icons.arrow_downward,
    'chevron_left': Icons.chevron_left,
    'chevron_right': Icons.chevron_right,
  };

  final iconKey = context.knobs.object.dropdown<String>(
    label: 'icon',
    options: iconOptions.keys.toList(),
    initialOption: 'add',
  );

  final enabled = context.knobs.boolean(
    label: 'enabled',
    initialValue: true,
  );

  final buttonSize = context.knobs.double.slider(
    label: 'buttonSize',
    initialValue: 36,
    min: 16,
    max: 96,
    divisions: 80,
  );

  final initialDelayMs = context.knobs.double
      .slider(
        label: 'initialDelay (ms)',
        initialValue: 350,
        min: 0,
        max: 2000,
        divisions: 40,
      )
      .round();

  final repeatIntervalMs = context.knobs.double
      .slider(
        label: 'repeatInterval (ms)',
        initialValue: 60,
        min: 16,
        max: 500,
        divisions: 60,
      )
      .round();

  final haptic = context.knobs.object.dropdown<HapticIntensity>(
    label: 'haptic',
    options: HapticIntensity.values,
    initialOption: HapticIntensity.selection,
    labelBuilder: (h) => h.name,
  );

  final tooltip = context.knobs.stringOrNull(
    label: 'tooltip',
    initialValue: null,
  );

  final color = context.knobs.colorOrNull(
    label: 'color',
    initialValue: null,
  );

  final iconColor = context.knobs.colorOrNull(
    label: 'iconColor',
    initialValue: null,
  );

  return Center(
    child: StepButton(
      icon: iconOptions[iconKey]!,
      onPressed: enabled ? () {} : null,
      buttonSize: buttonSize,
      color: color,
      iconColor: iconColor,
      initialDelay: Duration(milliseconds: initialDelayMs),
      repeatInterval: Duration(milliseconds: repeatIntervalMs),
      haptic: haptic,
      tooltip: tooltip,
    ),
  );
}
