// programs/widgetbook_workspace/lib/packages/analog_clock_widget/toggles.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:analog_clock_widget/analog_clock_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '_shared.dart';

@widgetbook.UseCase(name: 'Toggles (numbers × second hand)', type: AnalogClock)
Widget togglesAnalogClockUseCase(BuildContext context) {
  final radius = context.knobs.double.slider(
    label: 'radius',
    initialValue: 80,
    min: 30,
    max: 140,
  );

  // showNumbers × showSecondHand are the matrix axes — every other
  // ClockStyle property is shared across the four cells and surfaced via
  // knobs.
  final baseStyle = clockStyleKnobs(
    context,
    axes: const {
      ClockStyleAxis.showNumbers,
      ClockStyleAxis.showSecondHand,
    },
  );

  Widget tile(String label, bool showNumbers, bool showSecondHand) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnalogClock(
          radius: radius,
          style: baseStyle.copyWith(
            showNumbers: showNumbers,
            showSecondHand: showSecondHand,
          ),
        ),
        const Gap(8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  return Padding(
    padding: const EdgeInsets.all(16),
    child: Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: [
        tile('numbers + seconds', true, true),
        tile('numbers, no seconds', true, false),
        tile('no numbers, seconds', false, true),
        tile('no numbers, no seconds', false, false),
      ],
    ),
  );
}
