// lib/packages/animated_widgets/lib/src/length_colored_border_field/length_colored_border_field.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: LengthColoredBorderField)
Widget lengthColoredBorderFieldUseCase(BuildContext context) {
  final useCap = context.knobs.boolean(
    label: 'use maxLength cap',
    initialValue: true,
  );

  final maxLength = context.knobs.int.slider(
    label: 'maxLength',
    initialValue: 40,
    min: 5,
    max: 120,
  );

  final ramp = context.knobs.object.dropdown<_RampOption>(
    label: 'ramp',
    options: _RampOption.values,
    initialOption: _RampOption.traffic,
    labelBuilder: (o) => o.label,
  );

  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Ramp: ${ramp.label}'),
            const Gap(8),
            LengthColoredBorderField(
              ramp: ramp.toRamp(),
              maxLength: useCap ? maxLength : null,
            ),
            const Gap(8),
            const Text(
              'Type to watch the border color shift through the ramp.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    ),
  );
}

enum _RampOption {
  traffic('traffic (red → yellow → green)'),
  cool('cool (blue → cyan → teal)'),
  fire('fire (grey → orange → red)');

  const _RampOption(this.label);

  final String label;

  ColorPointRamp toRamp() {
    switch (this) {
      case _RampOption.traffic:
        return ColorPointRamp(const [
          ColorPoint(point: 0, color: Colors.red),
          ColorPoint(point: 10, color: Colors.orange),
          ColorPoint(point: 25, color: Colors.amber),
          ColorPoint(point: 40, color: Colors.green),
        ]);
      case _RampOption.cool:
        return ColorPointRamp(const [
          ColorPoint(point: 0, color: Colors.blue),
          ColorPoint(point: 15, color: Colors.cyan),
          ColorPoint(point: 35, color: Colors.teal),
        ]);
      case _RampOption.fire:
        return ColorPointRamp(const [
          ColorPoint(point: 0, color: Colors.grey),
          ColorPoint(point: 5, color: Colors.deepOrange),
          ColorPoint(point: 20, color: Colors.red),
        ]);
    }
  }
}
