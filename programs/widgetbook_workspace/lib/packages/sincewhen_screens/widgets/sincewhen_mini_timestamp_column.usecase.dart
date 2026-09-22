// widgetbook_workspace/lib/src/sincewhen_screens/
// since_when_mini_timestamp_column.usecase.dart

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sincewhen_models/sincewhen_models.dart' show SinceWhenItem;
import 'package:sincewhen_screens/sincewhen_screens.dart'
    show SinceWhenMiniReady, SinceWhenMiniTimestampColumn, TimestampDisplay;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const double _minDemoWidth = 280;
const double _maxDemoWidth = 700;
const double _initialDemoWidth = 420;
const double _demoPadding = 24;

/// Fixed instants so the gallery renders deterministically.
///
/// The edit-mode trio respects the production invariant
/// `created <= edited <= reviewed`.
final int _createdStamp = DateTime(
  2024,
  7,
  14,
  18,
  27,
  47,
).microsecondsSinceEpoch;

final int _editedStamp = DateTime(
  2024,
  8,
  2,
  9,
  15,
  3,
).microsecondsSinceEpoch;

final int _reviewedStamp = DateTime(
  2024,
  9,
  30,
  21,
  5,
  59,
).microsecondsSinceEpoch;

final int _eventStamp = DateTime(
  2024,
  6,
  1,
  7,
  30,
).microsecondsSinceEpoch;

/// A brand-new draft: all three stamps equal, no baseline, no event.
SinceWhenMiniReady _createModeState() => SinceWhenMiniReady(
  createdTimestamp: _createdStamp,
  reviewedTimestamp: _createdStamp,
  editedTimestamp: _createdStamp,
  content: '',
  metaData: '',
  tldr: '',
);

/// An existing record under edit: distinct stamps, a set event, and a
/// non-zero sequence number.
SinceWhenMiniReady _editModeState() {
  final original = SinceWhenItem(
    id: 42,
    createdTimestamp: _createdStamp,
    reviewedTimestamp: _reviewedStamp,
    editedTimestamp: _editedStamp,
    sequenceNumber: 3,
    content: 'Replaced the kitchen tap washer.',
    eventTimestamp: _eventStamp,
    tldr: 'Kitchen tap washer replaced.',
  );
  return SinceWhenMiniReady(
    original: original,
    createdTimestamp: original.createdTimestamp,
    reviewedTimestamp: original.reviewedTimestamp,
    editedTimestamp: original.editedTimestamp,
    content: original.content,
    metaData: original.metaData ?? '',
    tldr: original.tldr ?? '',
    eventTimestamp: original.eventTimestamp,
  );
}

/// Interactive use case projecting a create-mode draft.
///
/// All three lifecycle stamps render the same instant — a created
/// record *is* its creation — the event shows the placeholder, and
/// the sequence number is `0`.
@widgetbook.UseCase(
  name: 'Create mode',
  type: SinceWhenMiniTimestampColumn,
)
Widget buildSinceWhenMiniTimestampColumnCreateUseCase(
  BuildContext context,
) {
  return _TimestampColumnDemo(
    key: const ValueKey('since_when_mini_timestamp_column_create'),
    initialState: _createModeState(),
    width: _widthKnob(context),
  );
}

/// Interactive use case projecting an edit-mode draft.
///
/// Distinct created/edited/reviewed instants, a populated event with
/// its clear affordance, and a non-zero sequence number.
@widgetbook.UseCase(
  name: 'Edit mode',
  type: SinceWhenMiniTimestampColumn,
)
Widget buildSinceWhenMiniTimestampColumnEditUseCase(
  BuildContext context,
) {
  return _TimestampColumnDemo(
    key: const ValueKey('since_when_mini_timestamp_column_edit'),
    initialState: _editModeState(),
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

/// Stateful demo host: holds a [SinceWhenMiniReady] and mutates its
/// event through the state's own `copyWith` sentinel path — the same
/// contract production uses — so picks and clears render truthfully.
///
/// Widgetbook plumbing only — product state for this widget lives in
/// `SinceWhenMiniCubit`, not here.
class _TimestampColumnDemo extends StatefulWidget {
  const _TimestampColumnDemo({
    required this.initialState,
    required this.width,
    super.key,
  });

  final SinceWhenMiniReady initialState;
  final double width;

  @override
  State<_TimestampColumnDemo> createState() => _TimestampColumnDemoState();
}

class _TimestampColumnDemoState extends State<_TimestampColumnDemo> {
  late SinceWhenMiniReady _state = widget.initialState;

  void _onEventSelected(DateTime selected) {
    setState(() {
      _state = _state.copyWith(
        eventTimestamp: selected.microsecondsSinceEpoch,
      );
    });
    showToast(
      'onEventSelected: '
      '${TimestampDisplay.format(selected.microsecondsSinceEpoch)}',
    );
  }

  void _onEventCleared() {
    setState(() {
      _state = _state.copyWith(eventTimestamp: null);
    });
    showToast('onEventCleared');
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: widget.width,
            child: Padding(
              padding: const EdgeInsets.all(_demoPadding),
              child: SinceWhenMiniTimestampColumn(
                state: _state,
                onEventSelected: _onEventSelected,
                onEventCleared: _onEventCleared,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
