// programs/widgetbook_workspace/lib/packages/analog_clock_widget/playground.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:analog_clock_widget/analog_clock_widget.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '_shared.dart';

@widgetbook.UseCase(name: 'Playground', type: AnalogClock)
Widget playgroundAnalogClockUseCase(BuildContext context) {
  final radius = context.knobs.double.slider(
    label: 'radius',
    initialValue: 120,
    min: 30,
    max: 240,
  );

  final style = clockStyleKnobs(context);

  final utcMinuteOffset = context.knobs.intOrNull.input(
    label: 'utc minute offset (null = local)',
    initialValue: null,
  );

  return Center(
    child: AnalogClock(
      radius: radius,
      utcMinuteOffset: utcMinuteOffset,
      style: style,
    ),
  );
}
