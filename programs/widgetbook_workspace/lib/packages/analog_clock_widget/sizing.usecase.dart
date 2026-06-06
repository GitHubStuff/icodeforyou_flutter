// programs/widgetbook_workspace/lib/packages/analog_clock_widget/sizing.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:analog_clock_widget/analog_clock_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '_shared.dart';

@widgetbook.UseCase(name: 'Sizing (radius ladder)', type: AnalogClock)
Widget sizingAnalogClockUseCase(BuildContext context) {
  // radius is the ladder axis — every other ClockStyle property is shared
  // across the ladder and surfaced via knobs.
  final style = clockStyleKnobs(context);

  const radii = <double>[30, 50, 75, 100, 140, 180];

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final r in radii)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnalogClock(radius: r, style: style),
              const Gap(8),
              Text(
                '${r.toInt()} px',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
      ],
    ),
  );
}
