// lib/packages/analog_clock_widget/analog_clock_widget.usecase.dart

// Non-production doesn't require the full DARTDOC content
// ignore_for_file: public_member_api_docs, avoid_redundant_argument_values

import 'package:analog_clock_widget/analog_clock_widget.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ---------------------------------------------------------------------------
// Default — all defaults, radius knob
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Default', type: AnalogClock)
Widget analogClockDefault(BuildContext context) {
  final radius = context.knobs.double.slider(
    label: 'Radius',
    initialValue: 100,
    min: 30,
    max: 200,
  );

  return Center(
    child: AnalogClock(radius: radius),
  );
}

// ---------------------------------------------------------------------------
// Face styles
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Classic Face', type: AnalogClock)
Widget analogClockClassic(BuildContext context) {
  final radius = context.knobs.double.slider(
    label: 'Radius',
    initialValue: 100,
    min: 30,
    max: 200,
  );

  return Center(
    child: AnalogClock(
      radius: radius,
      style: ClockStyle.defaultStyle,
    ),
  );
}

@widgetbook.UseCase(name: 'Modern Face', type: AnalogClock)
Widget analogClockModern(BuildContext context) {
  final radius = context.knobs.double.slider(
    label: 'Radius',
    initialValue: 100,
    min: 30,
    max: 200,
  );

  return Center(
    child: AnalogClock(
      radius: radius,
      style: const ClockStyle(faceStyle: ClockFaceStyle.modern),
    ),
  );
}

@widgetbook.UseCase(name: 'Minimal Face', type: AnalogClock)
Widget analogClockMinimal(BuildContext context) {
  final radius = context.knobs.double.slider(
    label: 'Radius',
    initialValue: 100,
    min: 30,
    max: 200,
  );

  return Center(
    child: AnalogClock(
      radius: radius,
      style: const ClockStyle(faceStyle: ClockFaceStyle.minimal),
    ),
  );
}

// ---------------------------------------------------------------------------
// Hand styles
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Traditional Hands', type: AnalogClock)
Widget analogClockTraditionalHands(BuildContext context) {
  return Center(
    child: AnalogClock(
      radius: 100,
      style: ClockStyle.defaultStyle,
    ),
  );
}

@widgetbook.UseCase(name: 'Modern Hands', type: AnalogClock)
Widget analogClockModernHands(BuildContext context) {
  return Center(
    child: AnalogClock(
      radius: 100,
      style: const ClockStyle(handStyle: HandStyle.modern),
    ),
  );
}

@widgetbook.UseCase(name: 'Sleek Hands', type: AnalogClock)
Widget analogClockSleekHands(BuildContext context) {
  return Center(
    child: AnalogClock(
      radius: 100,
      style: const ClockStyle(handStyle: HandStyle.sleek),
    ),
  );
}

// ---------------------------------------------------------------------------
// No second hand
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'No Second Hand', type: AnalogClock)
Widget analogClockNoSecondHand(BuildContext context) {
  return Center(
    child: AnalogClock(
      radius: 100,
      style: const ClockStyle(showSecondHand: false),
    ),
  );
}

// ---------------------------------------------------------------------------
// No numbers
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'No Numbers', type: AnalogClock)
Widget analogClockNoNumbers(BuildContext context) {
  return Center(
    child: AnalogClock(
      radius: 100,
      style: const ClockStyle(showNumbers: false),
    ),
  );
}

// ---------------------------------------------------------------------------
// Timezone — UTC knob
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Timezone', type: AnalogClock)
Widget analogClockTimezone(BuildContext context) {
  final offset = context.knobs.double.slider(
    label: 'UTC offset (minutes)',
    initialValue: 0,
    min: -720,
    max: 840,
  );

  return Center(
    child: AnalogClock(
      radius: 100,
      utcMinuteOffset: offset.toInt(),
    ),
  );
}
