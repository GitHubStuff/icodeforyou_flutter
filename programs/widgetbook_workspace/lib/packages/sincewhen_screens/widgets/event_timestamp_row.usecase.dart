// programs/widgetbook_workspace/lib/packages/sincewhen_screens/widgets/event_timestamp_row.usecase.dart

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sincewhen_screens/sincewhen_screens.dart'
    show EventTimestampRow, TimestampDisplay;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const double _minDemoWidth = 240;
const double _maxDemoWidth = 700;
const double _initialDemoWidth = 420;
const double _demoPadding = 24;

/// Interactive use case starting with no event value.
///
/// Exercises the placeholder rendering and the absence of the clear
/// affordance; picking a date/time transitions it to the populated
/// presentation.
@widgetbook.UseCase(
  name: 'Empty',
  type: EventTimestampRow,
)
Widget buildEventTimestampRowEmptyUseCase(BuildContext context) {
  return _EventTimestampRowDemo(
    key: const ValueKey('event_timestamp_row_empty'),
    initialTimestamp: null,
    width: _widthKnob(context),
  );
}

/// Interactive use case starting with a populated event value.
///
/// Exercises the `'Tue 14-Jul-2024 6:27:47 pm'` display contract and
/// the clear (✕) affordance; clearing transitions it back to the
/// placeholder presentation.
@widgetbook.UseCase(
  name: 'With value',
  type: EventTimestampRow,
)
Widget buildEventTimestampRowWithValueUseCase(BuildContext context) {
  return _EventTimestampRowDemo(
    key: const ValueKey('event_timestamp_row_with_value'),
    initialTimestamp: DateTime(
      2024,
      7,
      14,
      18,
      27,
      47,
    ).microsecondsSinceEpoch,
    width: _widthKnob(context),
  );
}

/// Width knob simulating the timestamp-column constraint of the
/// iPad-mini landscape layout.
double _widthKnob(BuildContext context) {
  return context.knobs.double.slider(
    label: 'Width',
    initialValue: _initialDemoWidth,
    min: _minDemoWidth,
    max: _maxDemoWidth,
  );
}

/// Stateful demo host: owns the nullable timestamp so picks and
/// clears actually mutate the presentation, and reports callback
/// traffic via toasts.
///
/// Widgetbook plumbing only — product state for this widget lives in
/// `SinceWhenMiniCubit`, not here.
class _EventTimestampRowDemo extends StatefulWidget {
  const _EventTimestampRowDemo({
    required this.initialTimestamp,
    required this.width,
    super.key,
  });

  final int? initialTimestamp;
  final double width;

  @override
  State<_EventTimestampRowDemo> createState() => _EventTimestampRowDemoState();
}

class _EventTimestampRowDemoState extends State<_EventTimestampRowDemo> {
  late int? _timestamp = widget.initialTimestamp;

  void _onEventSelected(DateTime selected) {
    setState(() {
      _timestamp = selected.microsecondsSinceEpoch;
    });
    showToast(
      'onEventSelected: '
      '${TimestampDisplay.format(_timestamp!)}',
    );
  }

  void _onEventCleared() {
    setState(() {
      _timestamp = null;
    });
    showToast('onEventCleared');
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: Center(
        child: SizedBox(
          width: widget.width,
          child: Padding(
            padding: const EdgeInsets.all(_demoPadding),
            child: EventTimestampRow(
              eventTimestamp: _timestamp,
              onEventSelected: _onEventSelected,
              onEventCleared: _onEventCleared,
            ),
          ),
        ),
      ),
    );
  }
}
