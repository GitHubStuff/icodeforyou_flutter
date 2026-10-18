// packages/ext_duration/lib/src/duration_unit.dart
/// A single unit of a [Duration].
enum DurationUnits {
  /// Whole days.
  days,

  /// Whole hours.
  hours,

  /// Whole minutes.
  minutes,

  /// Whole seconds.
  seconds,

  /// Whole milliseconds.
  milliseconds,

  /// Whole microseconds — the [Duration] base unit.
  microseconds;

  /// This unit expressed in microseconds, the [Duration] base unit.
  int get inMicroseconds => switch (this) {
    days => Duration.microsecondsPerDay,
    hours => Duration.microsecondsPerHour,
    minutes => Duration.microsecondsPerMinute,
    seconds => Duration.microsecondsPerSecond,
    milliseconds => Duration.microsecondsPerMillisecond,
    microseconds => 1,
  };

  /// Builds a [Duration] of [count] of this unit.
  Duration times(int count) => Duration(microseconds: count * inMicroseconds);
}
