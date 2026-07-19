// programs/widgetbook_workspace/lib/packages/analog_clock_widget/_shared.dart
// ignore_for_file: public_member_api_docs

import 'package:analog_clock_widget/analog_clock_widget.dart';
import 'package:flutter/material.dart';
import 'package:random_color_generator/random_color_generator.dart'
    show RandomColorGenerator;
import 'package:widgetbook/widgetbook.dart';

/// Properties of [ClockStyle] that a use case may handle along its own axis
/// and therefore wants suppressed from the shared knob set.
enum ClockStyleAxis {
  faceStyle,
  handStyle,
  showNumbers,
  showSecondHand,
}

/// Builds a [ClockStyle] from a uniform knob set. Use cases that vary one
/// or more properties along their own axes (matrix grids, ladders, etc.)
/// pass those properties in [axes] and apply them per-cell via [copyWith].
///
/// Every other property is always knob-driven so designers can tune the
/// full styling surface from any use case.
ClockStyle clockStyleKnobs(
  BuildContext context, {
  Set<ClockStyleAxis> axes = const {},
}) {
  final faceColor = context.knobs.colorOrNull(
    label: 'face color',
    initialValue: Colors.white,
  );
  final borderColor = context.knobs.colorOrNull(
    label: 'border color',
    initialValue: RandomColorGenerator.generate(),
  );
  final hourHandColor = context.knobs.colorOrNull(
    label: 'hour hand color',
    initialValue: RandomColorGenerator.generate(),
  );
  final minuteHandColor = context.knobs.colorOrNull(
    label: 'minute hand color',
    initialValue: RandomColorGenerator.generate(),
  );
  final secondHandColor = context.knobs.colorOrNull(
    label: 'second hand color',
    initialValue: RandomColorGenerator.generate(),
  );

  final showNumbers =
      axes.contains(ClockStyleAxis.showNumbers) ||
      context.knobs.boolean(label: 'show numbers', initialValue: true);

  final showSecondHand =
      axes.contains(ClockStyleAxis.showSecondHand) ||
      context.knobs.boolean(label: 'show second hand', initialValue: true);

  final faceStyle = axes.contains(ClockStyleAxis.faceStyle)
      ? ClockFaceStyle.classic
      : context.knobs.object.dropdown<ClockFaceStyle>(
          label: 'face style',
          options: ClockFaceStyle.values,
          initialOption: ClockFaceStyle.classic,
          labelBuilder: (s) => s.name,
        );

  final handStyle = axes.contains(ClockStyleAxis.handStyle)
      ? HandStyle.traditional
      : context.knobs.object.dropdown<HandStyle>(
          label: 'hand style',
          options: HandStyle.values,
          initialOption: HandStyle.traditional,
          labelBuilder: (s) => s.name,
        );

  return ClockStyle(
    faceColor: faceColor,
    borderColor: borderColor,
    hourHandColor: hourHandColor,
    minuteHandColor: minuteHandColor,
    secondHandColor: secondHandColor,
    showNumbers: showNumbers,
    showSecondHand: showSecondHand,
    faceStyle: faceStyle,
    handStyle: handStyle,
  );
}
