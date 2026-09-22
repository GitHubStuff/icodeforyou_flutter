// packages/sincewhen_screens/lib/src/widgets/sincewhen_mini_timestamp_column.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sincewhen_screens/src/cubit/state.dart' show SinceWhenMiniReady;
import 'package:sincewhen_screens/src/util/sincewhen_mini_constants.dart'
    show SinceWhenMiniDimensions;
import 'package:sincewhen_screens/src/util/timestamp_display.dart'
    show TimestampDisplay;
import 'package:sincewhen_screens/src/widgets/event_timestamp_row.dart'
    show EventTimestampRow;
import 'package:sincewhen_screens/src/widgets/timestamp_row.dart'
    show TimestampRow;

/// {@template since_when_mini_timestamp_column}
/// The temporal (left) column of the since-when-mini screen.
///
/// A pure projection of [SinceWhenMiniReady]: the three lifecycle
/// stamps and the sequence number render read-only via [TimestampRow];
/// the event instant renders via [EventTimestampRow], whose callbacks
/// are forwarded untouched to [onEventSelected] and [onEventCleared].
///
/// No bloc dependencies and no imposed sizing — it lays out to its
/// content, so it drops into the landscape two-column body today and a
/// stacked small-screen layout later without change.
/// {@endtemplate}
class SinceWhenMiniTimestampColumn extends StatelessWidget {
  /// {@macro since_when_mini_timestamp_column}
  const SinceWhenMiniTimestampColumn({
    required this.state,
    required this.onEventSelected,
    required this.onEventCleared,
    super.key,
  });

  /// Label of the created-timestamp row.
  static const String createdLabel = 'Created';

  /// Label of the reviewed-timestamp row.
  static const String reviewedLabel = 'Reviewed';

  /// Label of the edited-timestamp row.
  static const String editedLabel = 'Edited';

  /// Label of the sequence-number row.
  static const String sequenceLabel = 'Sequence';

  /// The ready draft this column projects.
  final SinceWhenMiniReady state;

  /// Forwarded to [EventTimestampRow.onEventSelected].
  final ValueChanged<DateTime> onEventSelected;

  /// Forwarded to [EventTimestampRow.onEventCleared].
  final VoidCallback onEventCleared;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TimestampRow(
          label: createdLabel,
          value: TimestampDisplay.format(state.createdTimestamp),
        ),
        const Gap(SinceWhenMiniDimensions.timestampRowGap),
        TimestampRow(
          label: reviewedLabel,
          value: TimestampDisplay.format(state.reviewedTimestamp),
        ),
        const Gap(SinceWhenMiniDimensions.timestampRowGap),
        TimestampRow(
          label: editedLabel,
          value: TimestampDisplay.format(state.editedTimestamp),
        ),
        const Gap(SinceWhenMiniDimensions.timestampRowGap),
        EventTimestampRow(
          eventTimestamp: state.eventTimestamp,
          onEventSelected: onEventSelected,
          onEventCleared: onEventCleared,
        ),
        const Gap(SinceWhenMiniDimensions.timestampRowGap),
        TimestampRow(
          label: sequenceLabel,
          value: '${state.sequenceNumber}',
        ),
      ],
    );
  }
}
