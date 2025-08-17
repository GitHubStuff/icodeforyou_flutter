import 'package:analog_clock_widget/analog_clock_widget.dart' show AnalogClock;
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// Import the widget from your app

@widgetbook.UseCase(name: 'Default', type: AnalogClock)
Widget buildAnalogClockCase(BuildContext context) {
  return AnalogClock();
}
