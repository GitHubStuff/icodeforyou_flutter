// packages/sincewhen_screens/lib/src/widgets/event_timestamp_row.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart'
    show DateTimePickerField;
import 'package:sincewhen_screens/src/util/sincewhen_mini_constants.dart'
    show SinceWhenMiniDimensions;
import 'package:sincewhen_screens/src/util/timestamp_display.dart'
    show TimestampDisplay;

/// {@template event_timestamp_row}
/// The event date/time row: a tappable picker field plus a clear (✕)
/// affordance that renders only while a value is present.
///
/// [eventTimestamp] is microseconds since epoch, or `null` for "no
/// event". Tapping the field opens a [DateTimePickerField] popover; a
/// confirmed pick reaches [onEventSelected]. Dismissing the popover
/// reports `null` from the picker, which means "no selection" and is
/// swallowed here — clearing the value has exactly one path,
/// [onEventCleared] via the ✕.
///
/// Takes plain data and callbacks, no bloc dependencies: pump it with
/// two stub closures to test every behavior.
/// {@endtemplate}
class EventTimestampRow extends StatelessWidget {
  /// {@macro event_timestamp_row}
  const EventTimestampRow({
    required this.eventTimestamp,
    required this.onEventSelected,
    required this.onEventCleared,
    super.key,
  });

  /// Label displayed above the picker field.
  static const String fieldLabel = 'Event';

  /// Tooltip and semantics label of the clear affordance.
  static const String clearTooltip = 'Clear event date/time';

  /// The event instant in microseconds since epoch, or `null`.
  final int? eventTimestamp;

  /// Called with the picked [DateTime] when the popover is confirmed.
  final ValueChanged<DateTime> onEventSelected;

  /// Called when the clear (✕) affordance is pressed.
  final VoidCallback onEventCleared;

  void _onDateTimeSelected(DateTime? selected) {
    // Null is the picker's dismissal signal, not a value: ignore it.
    if (selected != null) {
      onEventSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timestamp = eventTimestamp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fieldLabel, style: theme.textTheme.labelLarge),
        const Gap(SinceWhenMiniDimensions.labelValueGap),
        Row(
          children: [
            Expanded(
              child: DateTimePickerField(
                initialDateTime: timestamp == null
                    ? null
                    : DateTime.fromMicrosecondsSinceEpoch(timestamp),
                onDateTimeSelected: _onDateTimeSelected,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(
                      SinceWhenMiniDimensions.eventFieldBorderRadius,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical:
                          SinceWhenMiniDimensions.eventFieldVerticalPadding,
                      horizontal:
                          SinceWhenMiniDimensions.eventFieldHorizontalPadding,
                    ),
                    child: Text(
                      TimestampDisplay.formatOrPlaceholder(timestamp),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
            ),
            if (timestamp != null)
              IconButton(
                icon: const Icon(Icons.clear),
                tooltip: clearTooltip,
                onPressed: onEventCleared,
              ),
          ],
        ),
      ],
    );
  }
}
