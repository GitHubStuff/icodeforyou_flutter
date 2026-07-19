// extensions/lib/src/datetime_ext/datetime_extension.dart
import 'package:extensions/datetime/src/datetime_unit.dart' show DateTimeUnit;
import 'package:flutter/foundation.dart';

/// Extension on [DateTime] providing uniqueness guarantees, formatting,
/// and precision truncation utilities.
extension DateTimeExt on DateTime {
  static int _lastMicroseconds = 0;

  /// Tracks the maximum observed clock drift in microseconds.
  static int maxDrift = 0;

  /// The microsecond drift threshold above which the method waits for the
  /// system clock to catch up. Configurable for testing.
  @visibleForTesting
  static int driftThreshold = 500;

  /// Returns a [DateTime] guaranteed to be unique across successive calls.
  ///
  /// If the system clock has not advanced since the last call, the returned
  /// value is incremented by one microsecond. When drift exceeds
  /// [driftThreshold], the method yields until the clock catches up.
  ///
  /// [now] returns the current time and is injectable so the method can be
  /// driven by a fake clock in tests; it defaults to [DateTime.now].
  static Future<DateTime> unique({
    DateTime Function() now = DateTime.now,
  }) async {
    int currentMicros = now().microsecondsSinceEpoch;
    if (currentMicros <= _lastMicroseconds) {
      currentMicros = _lastMicroseconds + 1;
      final drift = currentMicros - now().microsecondsSinceEpoch;
      if (maxDrift < drift) {
        maxDrift = drift;
      }
      if (drift > driftThreshold) {
        while (now().microsecondsSinceEpoch < currentMicros) {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        }
        currentMicros = now().microsecondsSinceEpoch;
      }
    }
    _lastMicroseconds = currentMicros;
    return DateTime.fromMicrosecondsSinceEpoch(_lastMicroseconds);
  }

  /// Resets all static state to defaults. Intended for use in tests only.
  @visibleForTesting
  static void reset() {
    _lastMicroseconds = 0;
    maxDrift = 0;
    driftThreshold = 500;
  }

  /// Whether [year] falls on a Gregorian leap year.
  bool get isLeapYear => year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  /// Returns the number of microseconds from this [DateTime] until the start
  /// of the next [unit] boundary.
  ///
  /// "Next" means the first instant at which the requested [unit] rolls over:
  /// `DateTimeUnit.second` counts to the upcoming `.000000` of the next
  /// second, `DateTimeUnit.hour` to the top of the next hour, `DateTimeUnit.day`
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

  /// Builds the next boundary [DateTime] for [unit], preserving this instant's
  /// UTC/local zone. Out-of-range component values (e.g. `second + 1 == 60`)
  /// are normalised by the [DateTime] constructor, which cascades the rollover
  /// up through minutes, hours, days, months, and years as needed.
  DateTime _nextBoundary(DateTimeUnit unit) {
    final make = isUtc ? DateTime.utc : DateTime.new;
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

  /// Returns a formatted timestamp string in `HH:mm:ss.SSS` format.
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
  DateTime truncate({DateTimeUnit atDateTimeUnit = DateTimeUnit.second}) {
    final skipUnits = atDateTimeUnit.next?.sublist() ?? {};
    final m = isUtc ? DateTime.utc : DateTime.new;
    return m(
      skipUnits.contains(DateTimeUnit.year) ? 0 : year,
      skipUnits.contains(DateTimeUnit.month) ? 1 : month,
      skipUnits.contains(DateTimeUnit.day) ? 1 : day,
      skipUnits.contains(DateTimeUnit.hour) ? 0 : hour,
      skipUnits.contains(DateTimeUnit.minute) ? 0 : minute,
      skipUnits.contains(DateTimeUnit.second) ? 0 : second,
      skipUnits.contains(DateTimeUnit.msec) ? 0 : millisecond,
      skipUnits.contains(DateTimeUnit.usec) ? 0 : microsecond,
    );
  }
}
