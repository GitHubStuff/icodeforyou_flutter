// packages/extensions/lib/datetime/src/datetime_ext.dart
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' show DateFormat;

/// Extension on [DateTime] providing uniqueness guarantees, formatting,
/// and precision truncation utilities.
extension DateTimeExt on DateTime {
  static int _lastMicroseconds = 0;

  /// Default pattern used by [toDisplay]: `Sun 27-Mar-2026 5:09:04 AM`.
  static const String displayPattern = 'EEE dd-MMM-yyyy h:mm:ss a';

  /// Returns a [DateTime] guaranteed to be unique across successive calls.
  ///
  /// [now] returns the current time and is injectable so the method can be
  /// driven by a fake clock in tests; it defaults to [DateTime.now].
  static DateTime unique({
    DateTime Function() now = DateTime.now,
  }) {
    var currentMicros = now().microsecondsSinceEpoch;
    if (currentMicros <= _lastMicroseconds) {
      currentMicros = _lastMicroseconds + 1;
    }
    _lastMicroseconds = currentMicros;
    return DateTime.fromMicrosecondsSinceEpoch(currentMicros);
  }

  /// Resets all static state to defaults. Intended for use in tests only.
  @visibleForTesting
  static void reset() => _lastMicroseconds = 0;

  /// Formats this [DateTime].
  ///
  /// With no argument the cached [displayPattern] formatter is used. Passing
  /// [formatString] builds a one-off [DateFormat] for that pattern.
  String toDisplay([String? formatString]) =>
      DateFormat(formatString ?? displayPattern).format(this);

  /// Whether [year] falls on a Gregorian leap year.
  bool get isLeapYear => year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  /// Returns `true` when the absolute distance between `this` and [other]
  /// is less than or equal to [tolerance].
  ///
  /// The check is symmetric: `a.isWithin(b, tolerance: t)` yields the same
  /// result as `b.isWithin(a, tolerance: t)`. Both instants are compared on
  /// the absolute timeline, so mixing UTC and local [DateTime]s is safe.
  ///
  /// Throws an [ArgumentError] when [tolerance] is negative.
  bool isWithin(
    DateTime other, {
    Duration tolerance = const Duration(
      microseconds: 250,
    ),
  }) {
    if (tolerance.isNegative) {
      throw ArgumentError.value(
        tolerance,
        'tolerance',
        'must be zero or positive',
      );
    }

    final distance = difference(other).abs();

    return distance <= tolerance;
  }

  /// Returns the number of microseconds from this [DateTime] until the start
  /// of the next [unit] boundary.
  ///
  /// "Next" means the first instant at which the requested [unit] rolls over:
  /// `DateTimeUnit.second` counts to the upcoming `.000000` of the next
  /// second, `DateTimeUnit.hour` to the top of next hour, `DateTimeUnit.day`
  /// to the next midnight in this instant's zone, and so on. All finer units
  /// are treated as zero, so the result is always strictly greater than zero —
  /// an instant already sitting exactly on a boundary reports one full unit,
  /// never `0`.
  ///
  /// The boundary is built with the calendar constructor and the elapsed span
  /// is measured with [DateTime.difference], so leap years, month lengths, and
  /// daylight-saving transitions are all handled by [DateTime] itself. UTC vs.
  /// local is preserved from `this`.
  int next(DateTimeUnit unit) =>
      _nextBoundary(unit).difference(this).inMicroseconds;

  /// Repeatedly waits until the next [dateTimeUnit] boundary and runs [task].
  ///
  /// [task] runs on each boundary; returning `false` stops the loop. The wait
  /// is recomputed from the live clock after every tick, so scheduler slop in
  /// one cycle never accumulates into the next. The first tick aligns to `this`
  /// — call on `DateTime.now()` (or a fresh instant) so the opening delay lands
  /// on a real boundary.
  ///
  /// Returns the time basis of the final tick: the instant whose boundary the
  /// loop was waiting on when [task] returned `false`.
  Future<DateTime> repeatEvery(
    DateTimeUnit dateTimeUnit,
    bool Function() task,
  ) async {
    var current = this;
    while (true) {
      await Future<void>.delayed(
        Duration(microseconds: current.next(dateTimeUnit)),
      );
      if (!task()) return current;
      current = isUtc ? DateTime.now().toUtc() : DateTime.now();
    }
  }

  /// Returns a formatted timestamp string in `HH:mm:ss` format, with
  /// `.SSS` appended when [showMilliseconds] is `true`.
  String timeStamp({bool showMilliseconds = false}) {
    final ms = showMilliseconds
        ? '.${millisecond.toString().padLeft(3, '0')}'
        : '';
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}:'
        '${second.toString().padLeft(2, '0')}'
        '$ms';
  }

  /// Truncates this [DateTime] to the precision of [atDateTimeUnit].
  ///
  /// All units finer than [atDateTimeUnit] are zeroed (or set to their
  /// minimum valid value). Preserves UTC vs. local time.
  ///
  /// [DateTimeUnit] is declared coarsest-to-finest, so a unit is kept when
  /// its index is at or below [atDateTimeUnit]'s. Year is the coarsest unit
  /// and is therefore always kept.
  DateTime truncate({DateTimeUnit atDateTimeUnit = DateTimeUnit.second}) {
    final keep = atDateTimeUnit.index;
    int at(DateTimeUnit unit, int value, [int floor = 0]) =>
        unit.index <= keep ? value : floor;
    return _make(
      year,
      at(DateTimeUnit.month, month, 1),
      at(DateTimeUnit.day, day, 1),
      at(DateTimeUnit.hour, hour),
      at(DateTimeUnit.minute, minute),
      at(DateTimeUnit.second, second),
      at(DateTimeUnit.msec, millisecond),
      at(DateTimeUnit.usec, microsecond),
    );
  }

  /// The calendar constructor matching this instant's zone.
  DateTime Function(
    int year, [
    int month,
    int day,
    int hour,
    int minute,
    int second,
    int millisecond,
    int microsecond,
  ])
  get _make => isUtc ? DateTime.utc : DateTime.new;

  /// Builds the next boundary [DateTime] for [unit], preserving this instant's
  /// UTC/local zone. Out-of-range component values (e.g. `second + 1 == 60`)
  /// are normalised by the [DateTime] constructor, which cascades the rollover
  /// up through minutes, hours, days, months, and years as needed.
  DateTime _nextBoundary(DateTimeUnit unit) {
    final make = _make;
    return switch (unit) {
      DateTimeUnit.year => make(year + 1),
      DateTimeUnit.month => make(year, month + 1),
      DateTimeUnit.day => make(year, month, day + 1),
      DateTimeUnit.hour => make(year, month, day, hour + 1),
      DateTimeUnit.minute => make(year, month, day, hour, minute + 1),
      DateTimeUnit.second => make(year, month, day, hour, minute, second + 1),
      DateTimeUnit.msec => make(
        year,
        month,
        day,
        hour,
        minute,
        second,
        millisecond + 1,
      ),
      DateTimeUnit.usec => make(
        year,
        month,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond + 1,
      ),
    };
  }
}
