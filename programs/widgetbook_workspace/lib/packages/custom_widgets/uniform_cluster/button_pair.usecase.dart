// widgetbook_workspace/lib/packages/custom_widgets/uniform_cluster/button_pair.usecase.dart
import 'package:custom_widgets/src/uniform_cluster/button_pair.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ButtonPair)
Widget buttonPairDefault(BuildContext context) {
  final axis = context.knobs.object.dropdown<Axis>(
    label: 'axis',
    options: Axis.values,
    initialOption: Axis.horizontal,
    labelBuilder: (a) => a.name,
  );

  final primaryText = context.knobs.string(
    label: 'primaryText',
    initialValue: 'Save',
  );

  final secondaryText = context.knobs.string(
    label: 'secondaryText',
    initialValue: 'Cancel',
  );

  final primaryEnabled = context.knobs.boolean(
    label: 'primary enabled',
    initialValue: true,
  );

  final secondaryEnabled = context.knobs.boolean(
    label: 'secondary enabled',
    initialValue: true,
  );

  return Padding(
    padding: const EdgeInsets.all(24),
    child: Align(
      alignment: axis == Axis.horizontal
          ? Alignment.topCenter
          : Alignment.centerLeft,
      child: ButtonPair(
        axis: axis,
        primaryText: primaryText,
        secondaryText: secondaryText,
        onPrimary: primaryEnabled ? () {} : null,
        onSecondary: secondaryEnabled ? () {} : null,
      ),
    ),
  );
}
