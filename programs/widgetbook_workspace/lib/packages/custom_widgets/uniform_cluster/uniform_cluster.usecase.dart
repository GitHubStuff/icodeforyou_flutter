// widgetbook_workspace/lib/packages/custom_widgets/uniform_cluster/uniform_cluster.usecase.dart
import 'package:custom_widgets/custom_widgets.dart' show UniformCluster;
import 'package:flutter/material.dart';
import 'package:platform_utils/platform_utils.dart' show DipScale;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: UniformCluster)
Widget uniformClusterDefault(BuildContext context) {
  final axis = context.knobs.object.dropdown<Axis>(
    label: 'axis',
    options: Axis.values,
    initialOption: Axis.horizontal,
    labelBuilder: (a) => a.name,
  );

  final spacingOptions = <String, double>{
    'none': DipScale.none,
    'xs': DipScale.xs,
    'sm': DipScale.sm,
    'smd': DipScale.smd,
    'md': DipScale.md,
    'lg': DipScale.lg,
    'xl': DipScale.xl,
    'xxl': DipScale.xxl,
  };

  final spacingKey = context.knobs.object.dropdown<String>(
    label: 'spacing',
    options: spacingOptions.keys.toList(),
    initialOption: 'sm',
  );

  final childCount = context.knobs.double
      .slider(
        label: 'child count',
        initialValue: 3,
        min: 1,
        max: 6,
        divisions: 5,
      )
      .round();

  // Children of deliberately varied label lengths to demonstrate the uniform
  // sizing behavior: horizontal → equal share of available width; vertical →
  // all stretched to the widest child.
  const labels = [
    'OK',
    'Submit',
    'Acknowledge',
    'Reset to Defaults',
    'Cancel',
    'Continue Anyway',
  ];

  return Padding(
    padding: const EdgeInsets.all(24),
    child: Align(
      alignment: axis == Axis.horizontal
          ? Alignment.topCenter
          : Alignment.centerLeft,
      child: UniformCluster(
        axis: axis,
        spacing: spacingOptions[spacingKey] ?? DipScale.none,
        children: [
          for (var i = 0; i < childCount; i++)
            FilledButton(
              onPressed: () {},
              child: Text(labels[i % labels.length]),
            ),
        ],
      ),
    ),
  );
}
