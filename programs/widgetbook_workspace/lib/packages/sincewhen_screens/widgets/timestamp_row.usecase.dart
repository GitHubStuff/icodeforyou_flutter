// programs/widgetbook_workspace/lib/packages/sincewhen_screens/widgets/timestamp_row.usecase.dart

import 'package:flutter/material.dart';
import 'package:sincewhen_screens/sincewhen_screens.dart'
    show TimestampDisplay, TimestampRow;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const double _minDemoWidth = 160;
const double _maxDemoWidth = 700;
const double _initialDemoWidth = 420;
const double _demoPadding = 24;

const String _initialLabel = 'Created';

/// Fixed instant so the default value renders the production display
/// contract deterministically.
final String _initialValue = TimestampDisplay.format(
  DateTime(2024, 7, 14, 18, 27, 47).microsecondsSinceEpoch,
);

/// Interactive use case for [TimestampRow].
///
/// A pure builder — the widget is stateless, tapless, and
/// presentational, so there is nothing to wrap and nothing to toast.
/// The label and value are driven directly by string knobs; the value
/// defaults to a genuinely formatted timestamp so the gallery shows
/// the real display contract, and narrowing the width knob probes
/// overflow on the longest fixed text the screen renders.
@widgetbook.UseCase(
  name: 'Interactive',
  type: TimestampRow,
)
Widget buildTimestampRowUseCase(BuildContext context) {
  final label = context.knobs.string(
    label: 'Label',
    initialValue: _initialLabel,
  );
  final value = context.knobs.string(
    label: 'Value',
    initialValue: _initialValue,
  );
  final width = context.knobs.double.slider(
    label: 'Width',
    initialValue: _initialDemoWidth,
    min: _minDemoWidth,
    max: _maxDemoWidth,
  );
  return Center(
    child: SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(_demoPadding),
        child: TimestampRow(label: label, value: value),
      ),
    ),
  );
}
