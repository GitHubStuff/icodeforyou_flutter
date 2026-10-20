// widgetbook_workspace/lib/tools/duration_demo.usecase.dart

import 'package:flutter/material.dart';
import 'package:sliders/sliders.dart' show Constants;
import 'package:tools/tools.dart' show DurationDemo;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: DurationDemo)
Widget defaultDurationDemoUseCase(BuildContext context) => const DurationDemo();

@widgetbook.UseCase(name: 'Constrained width', type: DurationDemo)
Widget constrainedWidthDurationDemoUseCase(BuildContext context) {
  final width = context.knobs.double.slider(
    label: 'width',
    initialValue: 360,
    // HSliderWithButtons asserts at least Constants.sliderWidth.
    min: Constants.sliderWidth,
    max: 800,
  );

  return Center(
    child: SizedBox(
      width: width,
      child: const DurationDemo(),
    ),
  );
}

@widgetbook.UseCase(name: 'Text scaling', type: DurationDemo)
Widget textScalingDurationDemoUseCase(BuildContext context) {
  final scale = context.knobs.double.slider(
    label: 'textScaleFactor',
    initialValue: 1,
    min: 0.8,
    max: 2,
  );

  return MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: const DurationDemo(),
  );
}
