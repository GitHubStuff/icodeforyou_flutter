// packages/duration_widget/lib/src/event_reporting.dart

import 'package:extensions/duration/duration_fmt.dart' show DurationFormatting;

/// A utility class that calculates the temporal difference and relative
/// direction between an event timestamp and a reference timestamp.
///
/// Use this class to determine whether an event is in the past, present, or
/// future relative to [currentTime], and to generate human-readable duration
/// strings.
///
/// ### Example
///
/// ```dart
/// final reporting = EventReporting(
///   eventTime: DateTime(2026, 1, 1, 10, 0),
///   currentTime: DateTime(2026, 1, 1, 10, 30),
/// );
///
/// print(reporting.eventDirection()); // 'Since'
/// print(reporting.durationString(alwaysShowDays: false)); // '30:00'
/// print(reporting.durationString(alwaysShowDays: true)); // '0 00:30:00'
/// ```
class EventReporting {
  /// Creates an [EventReporting] instance with the specified [eventTime]
  /// and [currentTime].
  const EventReporting({required this.eventTime, required this.currentTime});

  /// The target timestamp of the event.
  final DateTime eventTime;

  /// The reference timestamp representing the current point in time.
  final DateTime currentTime;

  /// Formats the absolute elapsed or remaining duration between [eventTime]
  /// and [currentTime] into a readable string.
  ///
  /// Uses [DurationFormatting.toFormattedString] from `package:extensions`.
  /// When [alwaysShowDays] is `true` the full `D HH:MM:SS` form is always
  /// used, with a `0` day count where there are no whole days; otherwise the
  /// adaptive form is used.
  String durationString({required bool alwaysShowDays}) => eventTime
      .difference(currentTime)
      .abs()
      .toFormattedString(alwaysShowDays: alwaysShowDays);

  /// Returns a descriptive direction label indicating the temporal relation
  /// of [eventTime] relative to [currentTime].
  ///
  /// * Returns `'Since'` if [eventTime] occurred before [currentTime]
  ///   (past event).
  /// * Returns `'Until'` if [eventTime] occurs after [currentTime]
  ///   (future countdown).
  /// * Returns an empty string (`''`) if [eventTime] is identical to
  ///   [currentTime].
  String eventDirection() {
    if (eventTime.isBefore(currentTime)) return 'Since';
    if (eventTime.isAfter(currentTime)) return 'Until';
    return '';
  }
}
