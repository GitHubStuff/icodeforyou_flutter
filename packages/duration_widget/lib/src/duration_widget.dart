// packages/duration_widget/lib/src/duration_widget.dart

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
///   textStyle: const TextStyle(fontSize: 24),
///   alwaysShowDays: true,
/// )
/// ```
///
/// See also:
///
///  * [EventReporting], the underlying utility handling the duration string
///    formatting.
///  * [Text], the leaf widget used to render the resulting text.
class DurationWidget extends StatelessWidget {
  /// Creates a [DurationWidget].
  ///
  /// [alwaysShowDays] defaults to `false`.
  const DurationWidget({
    required this.eventTime,
    required this.currentTime,
    required this.textStyle,
    super.key,
    this.alwaysShowDays = false,
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

  /// Whether to always render the full `D HH:MM:SS` form, with a `0` day
  /// count where there are no whole days.
  ///
  /// Defaults to `false`, which uses the adaptive form (e.g. `05:00` for a
  /// five-minute duration rather than `0 00:05:00`). Set to `true` when a
  /// column of durations must align regardless of magnitude.
  final bool alwaysShowDays;

  @override
  Widget build(BuildContext context) {
    final eventReport = EventReporting(
      eventTime: eventTime,
      currentTime: currentTime,
    );

    return Text(
      eventReport.durationString(alwaysShowDays: alwaysShowDays),
      style: textStyle,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}
