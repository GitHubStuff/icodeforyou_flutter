// packages/duration_widget/lib/duration_widget.dart

import 'package:duration_widget/src/event_reporting.dart';
import 'package:flutter/widgets.dart';

/// A widget that computes and displays a formatted duration string relative
/// to an event timestamp.
///
/// [DurationWidget] uses [EventReporting] internally to calculate the elapsed
/// or remaining time between [currentTime] and [eventTime], rendering the
/// result inside a Flutter [Text] widget.
///
/// ### Example
///
/// ```dart
/// DurationWidget(
///   eventTime: DateTime(2026, 1, 1, 12, 0),
///   currentTime: DateTime(2026, 1, 1, 12, 5),
///   showLeadingZero: true,
/// )
/// ```
///
/// See also:
///
///  * [EventReporting], the underlying utility handling the duration string formatting.
///  * [Text], the leaf widget used to render the resulting text.
class DurationWidget extends StatelessWidget {
  /// Creates a [DurationWidget].
  ///
  /// The [eventTime] and [currentTime] arguments must not be null.
  /// [showLeadingZero] defaults to `false`.
  const DurationWidget({
    required this.eventTime,
    required this.currentTime,
    required this.textStyle,
    super.key,
    this.showLeadingZero = false,
  });

  /// The target timestamp of the event being measured against.
  ///
  /// Depending on whether this timestamp is before or after [currentTime],
  /// the underlying [EventReporting] instance represents an elapsed duration
  /// or a countdown.
  final DateTime eventTime;

  /// The reference timestamp representing the current point in time.
  ///
  /// Typically passed from a ticking timer, state management store, or
  /// [DateTime.now].
  final DateTime currentTime;

  /// The style to display the text
  final TextStyle textStyle;

  /// Whether numeric units less than 10 should be padded with a leading zero.
  ///
  /// Defaults to `false` (e.g., outputs `"5m"` instead of `"05m"`).
  final bool showLeadingZero;

  @override
  Widget build(BuildContext context) {
    final eventReport = EventReporting(
      eventTime: eventTime,
      currentTime: currentTime,
    );

    return Text(
      eventReport.durationString(showLeadingZero: showLeadingZero),
      style: textStyle,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}
