// packages/duration_widget/lib/src/event_reporting.dart

import 'package:extensions/duration/duration_fmt.dart' show DurationFormatting;

/// A utility class that calculates the temporal difference and relative
/// direction between an event timestamp and a reference timestamp.
///
/// Use this class to determine whether an event is in the past, present, or future
/// relative to [currentTime], and to generate human-readable duration strings.
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
/// print(reporting.durationString(showLeadingZero: true)); // '00:30:00' (depending on format)
/// ```
class EventReporting {
  /// Creates an [EventReporting] instance with the specified [eventTime] and [currentTime].
  const EventReporting({required this.eventTime, required this.currentTime});

  /// The target timestamp of the event.
  final DateTime eventTime;

  /// The reference timestamp representing the current point in time.
  final DateTime currentTime;

  /// Formats the absolute elapsed or remaining duration between [eventTime]
  /// and [currentTime] into a readable string.
  ///
  /// Uses [DurationFormatting.toFormattedString] from `package:extensions`.
  /// If [showLeadingZero] is `true`, single-digit units are padded with a leading zero.
  String durationString({required bool showLeadingZero}) => eventTime
      .difference(currentTime)
      .abs()
      .toFormattedString(showLeadingZero: showLeadingZero);

  /// Returns a descriptive direction label indicating the temporal relation
  /// of [eventTime] relative to [currentTime].
  ///
  /// * Returns `'Since'` if [eventTime] occurred before [currentTime] (past event).
  /// * Returns `'Until'` if [eventTime] occurs after [currentTime] (future countdown).
  /// * Returns an empty string (`''`) if [eventTime] is identical to [currentTime].
  String eventDirection() {
    if (eventTime.isBefore(currentTime)) return 'Since';
    if (eventTime.isAfter(currentTime)) return 'Until';
    return '';
  }
}
