// analog_clock.dart

import 'package:analog_clock_widget/analog_clock_widget.dart'
    show AnalogClock, ClockFaceStyle, ClockStyle;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AnalogClock)
Widget buildAnalogClockCase(BuildContext context) {
  return Center(
    child: AnalogClock(
      radius: context.knobs.double.slider(
        label: 'Radius',
        initialValue: 100,
        min: 30,
        max: 200,
      ),

      // Time Zone Control
      utcMinuteOffset: context.knobs.int.slider(
        label: 'UTC Offset (minutes)',
        min: -720, // -12 hours
        max: 720, // +12 hours
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Full features', type: AnalogClock)
Widget buildAnalogClockDarkCase(BuildContext context) {
  final classic = ClockStyle(
    faceColor: context.knobs.colorOrNull(label: 'Face'),
    borderColor: context.knobs.colorOrNull(label: 'Border'),
    hourHandColor: context.knobs.colorOrNull(
      label: 'Hour Hands',
    ),
    minuteHandColor: context.knobs.colorOrNull(
      label: 'Minute Hands',
    ),
    secondHandColor: context.knobs.colorOrNull(
      label: 'Second Hands',
    ),
    showNumbers: context.knobs.boolean(
      label: 'Show Numbers',
      initialValue: true,
    ),
    showSecondHand: context.knobs.boolean(
      label: 'Show Second Hand',
      initialValue: true,
    ),
  );
  final modern = classic.copyWith(faceStyle: ClockFaceStyle.modern);
  final minimal = modern.copyWith(faceStyle: ClockFaceStyle.minimal);
  return Container(
    color: context.knobs.colorOrNull(label: 'Clock Wall'),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Classic'),
          AnalogClock(
            style: classic,
            radius: context.knobs.double.slider(
              label: 'Radius',
              initialValue: 120,
              min: 30,
              max: 200,
            ),
          ),
          const Gap(10),
          const Text('Modern'),
          AnalogClock(
            style: modern,
            radius: context.knobs.double.slider(
              label: 'Radius',
              initialValue: 120,
              min: 30,
              max: 200,
            ),
          ),
          const Gap(10),
          const Text('Minimal'),
          AnalogClock(
            style: minimal,
            radius: context.knobs.double.slider(
              label: 'Radius',
              initialValue: 120,
              min: 30,
              max: 200,
            ),
          ),
        ],
      ),
    ),
  );
}
