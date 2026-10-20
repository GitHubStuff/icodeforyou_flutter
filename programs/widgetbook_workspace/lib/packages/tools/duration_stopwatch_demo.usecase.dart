// widgetbook_workspace/lib/tools/duration_stopwatch_demo.usecase.dart

import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:tools/tools.dart' show DurationStopwatchDemo;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: DurationStopwatchDemo)
Widget defaultDurationStopwatchDemoUseCase(BuildContext context) =>
    const DurationStopwatchDemo();

@widgetbook.UseCase(name: 'Seeded', type: DurationStopwatchDemo)
Widget seededDurationStopwatchDemoUseCase(BuildContext context) {
  final seed = context.knobs.int.input(
    label: 'seed',
    initialValue: 42,
    description: 'Same seed, same sequence of durations on every flip.',
  );

  // `random` is read once per State, so a new seed must remount the demo.
  return DurationStopwatchDemo(
    key: ValueKey(seed),
    random: Random(seed),
  );
}

@widgetbook.UseCase(name: 'Constrained width', type: DurationStopwatchDemo)
Widget constrainedWidthDurationStopwatchDemoUseCase(BuildContext context) {
  final width = context.knobs.double.slider(
    label: 'width',
    initialValue: 320,
    min: 200,
    max: 800,
  );

  return Center(
    child: SizedBox(width: width, child: const DurationStopwatchDemo()),
  );
}

@widgetbook.UseCase(name: 'Text scaling', type: DurationStopwatchDemo)
Widget textScalingDurationStopwatchDemoUseCase(BuildContext context) {
  final scale = context.knobs.double.slider(
    label: 'textScaleFactor',
    initialValue: 1,
    min: 0.8,
    max: 2,
  );

  return MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: const DurationStopwatchDemo(),
  );
}
