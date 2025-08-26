// widgetbook_analog_clock.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:analog_clock_widget/analog_clock_widget.dart'
    show AnalogClock, ClockFaceStyle, ClockStyle;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AnalogClock)
Widget buildAnalogClockCase(BuildContext context) {
  final clockStyle = ClockStyle.defaultStyle;
  return Center(
    child: AnalogClock(
      style: clockStyle,
      radius: context.knobs.double.slider(
        label: 'Radius',
        initialValue: 100,
        min: 30,
        max: 200,
      ),

      // Time Zone Control
      utcMinuteOffset: context.knobs.int.slider(
        label: 'UTC Offset (minutes)',
        initialValue: 0,
        min: -720, // -12 hours
        max: 720, // +12 hours
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Full features', type: AnalogClock)
Widget buildAnalogClockDarkCase(BuildContext context) {
  final classic = ClockStyle(
    faceColor: context.knobs.colorOrNull(label: 'Face', initialValue: null),
    borderColor: context.knobs.colorOrNull(label: 'Border', initialValue: null),
    hourHandColor: context.knobs.colorOrNull(
      label: 'Hour Hands',
      initialValue: null,
    ),
    minuteHandColor: context.knobs.colorOrNull(
      label: 'Minute Hands',
      initialValue: null,
    ),
    secondHandColor: context.knobs.colorOrNull(
      label: 'Second Hands',
      initialValue: null,
    ),
    showNumbers: context.knobs.boolean(
      label: 'Show Numbers',
      initialValue: true,
    ),
    showSecondHand: context.knobs.boolean(
      label: 'Show Second Hand',
      initialValue: true,
    ),
    faceStyle: ClockFaceStyle.classic,
  );
  final modern = classic.copyWith(faceStyle: ClockFaceStyle.modern);
  final minimal = modern.copyWith(faceStyle: ClockFaceStyle.minimal);
  return Container(
    color: context.knobs.colorOrNull(label: 'Clock Wall', initialValue: null),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Classic'),
          AnalogClock(
            style: classic,
            radius: context.knobs.double.slider(
              label: 'Radius',
              initialValue: 120,
              min: 30,
              max: 200,
            ),
          ),
          Gap(10),
          Text('Modern'),
          AnalogClock(
            style: modern,
            radius: context.knobs.double.slider(
              label: 'Radius',
              initialValue: 120,
              min: 30,
              max: 200,
            ),
          ),
          Gap(10),
          Text('Minimal'),
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
