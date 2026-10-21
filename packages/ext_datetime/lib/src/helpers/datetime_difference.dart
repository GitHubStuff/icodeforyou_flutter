// packages/ext_datetime/lib/src/helpers/datetime_difference.dart

import 'package:ext_datetime/ext_datetime.dart' show DateTimeUnit;
import 'package:ext_datetime/src/datetime_delta.dart' show DateTimeDelta;

/// Computes the calendar-aware difference between two UTC [DateTime]s as a
/// [DateTimeDelta].
///
/// Unlike [DateTime.difference], which yields a flat [Duration], this class
/// decomposes the gap into human-readable calendar components — years,
/// months, days, hours, minutes, seconds, milliseconds, and microseconds —
/// the way a person would describe it ("2 years, 3 months, 4 days ago").
///
/// The result honours real calendar rules: month lengths vary, February has
/// 28 or 29 days, and borrowing cascades correctly from microseconds all the
/// way up to years.
///
/// ## Usage
///
/// ```dart
/// final delta = DateTimeDifference.delta(
///   startTime: DateTime.utc(2024, 1, 15, 10, 30),
///   endTime: DateTime.utc(2026, 3, 20, 8, 15),
/// );
/// // delta.years == 2, delta.months == 2, delta.days == 4,
/// // delta.hours == 21, delta.minutes == 45, delta.seconds == 0
/// ```
///
/// ## UTC requirement
///
/// Both inputs **must** be UTC. Local-zone instants are rejected with an
/// [ArgumentError] because daylight-saving transitions would make the
/// component arithmetic ambiguous. Convert with [DateTime.toUtc] first.
///
/// This class is a static namespace and cannot be instantiated.
class DateTimeDifference {
  /// Private constructor: this class exposes only static members.
  DateTimeDifference._(); // coverage:ignore-line

  /// Every [DateTimeUnit], ordered coarsest to finest.
  ///
  /// Used to compare two units by magnitude via [List.indexOf]: a lower
  /// index is a coarser unit. Mirrors the declaration order of
  /// [DateTimeUnit] itself.
  static const List<DateTimeUnit> _unitHierarchy = [
    DateTimeUnit.year,
    DateTimeUnit.month,
    DateTimeUnit.day,
    DateTimeUnit.hour,
    DateTimeUnit.minute,
    DateTimeUnit.second,
    DateTimeUnit.msec,
    DateTimeUnit.usec,
  ];

  /// Maps each [DateTimeUnit] to the key used for it in the component map
  /// returned by [_calculateTimeDifference].
  ///
  /// Keeps the string keys in one place so [_applyFiltering] never has to
  /// spell them out.
  static const Map<DateTimeUnit, String> _unitNames = {
    DateTimeUnit.year: 'years',
    DateTimeUnit.month: 'months',
    DateTimeUnit.day: 'days',
    DateTimeUnit.hour: 'hours',
    DateTimeUnit.minute: 'minutes',
    DateTimeUnit.second: 'seconds',
    DateTimeUnit.msec: 'milliseconds',
    DateTimeUnit.usec: 'microseconds',
  };

  /// Returns the calendar difference between [startTime] and [endTime] as a
  /// [DateTimeDelta].
  ///
  /// ### Parameters
  ///
  /// * [startTime] — the reference instant. Must be UTC.
  /// * [endTime] — the instant to compare against. Defaults to
  ///   `DateTime.now().toUtc()` when omitted. Must be UTC when supplied.
  /// * [firstDateTimeUnit] — the coarsest unit to report. Units coarser than
  ///   this are omitted from the result (their fields are `null`). Defaults
  ///   to [DateTimeUnit.year], i.e. report everything.
  /// * [precision] — the finest unit to report. Units finer than this are
  ///   either zeroed or omitted, depending on [truncate]. Defaults to
  ///   [DateTimeUnit.second].
  /// * [truncate] — controls what happens to units finer than [precision].
  ///   When `true` (the default) they are reported as `0`; when `false` they
  ///   are reported as `null`. Units coarser than [firstDateTimeUnit] are
  ///   always `null` regardless of this flag.
  ///
  /// ### Direction
  ///
  /// The returned [DateTimeDelta.isFuture] is `true` when [endTime] is at or
  /// after [startTime], and `false` when [endTime] precedes it. The component
  /// magnitudes are always non-negative; direction is carried solely by
  /// [DateTimeDelta.isFuture]. Internally the two instants are reordered so
  /// the arithmetic always runs from the earlier to the later.
  ///
  /// ### Identical instants
  ///
  /// When [startTime] and [endTime] are the same moment, a [DateTimeDelta]
  /// with no components set (only [DateTimeDelta.isFuture]) is returned
  /// without running the component arithmetic.
  ///
  /// ### Calendar semantics
  ///
  /// Components are computed field-by-field with borrowing, so a day
  /// shortfall borrows the length of the month *preceding* [endTime]'s month,
  /// not a fixed 30 days. See [_calculateTimeDifference] for the algorithm.
  ///
  /// ### Errors
  ///
  /// Throws [ArgumentError] when:
  ///
  /// * [startTime] is not UTC.
  /// * [endTime] is supplied and is not UTC.
  /// * [firstDateTimeUnit] is finer than [precision] — e.g. asking for
  ///   `firstDateTimeUnit: DateTimeUnit.minute` with
  ///   `precision: DateTimeUnit.hour` would leave nothing to report.
  ///
  /// ### Example
  ///
  /// ```dart
  /// // Report only days and finer, down to minutes, dropping seconds.
  /// final delta = DateTimeDifference.delta(
  ///   startTime: DateTime.utc(2026, 10, 1),
  ///   endTime: DateTime.utc(2026, 10, 21, 14, 30, 45),
  ///   firstDateTimeUnit: DateTimeUnit.day,
  ///   precision: DateTimeUnit.minute,
  ///   truncate: false,
  /// );
  /// // delta.years == null, delta.months == null,
  /// // delta.days == 20, delta.hours == 14, delta.minutes == 30,
  /// // delta.seconds == null (truncate: false)
  /// ```
  static DateTimeDelta delta({
    required DateTime startTime,
    DateTime? endTime,
    DateTimeUnit firstDateTimeUnit = DateTimeUnit.year,
    DateTimeUnit precision = DateTimeUnit.second,
    bool truncate = true,
  }) {
    final resolvedEnd = endTime ?? DateTime.now().toUtc();

    if (!startTime.isUtc) {
      throw ArgumentError(
        'startTime must be UTC. Use startTime.toUtc(). '
        'Current timezone offset: ${startTime.timeZoneOffset}',
      );
    }

    if (!resolvedEnd.isUtc) {
      throw ArgumentError(
        'endTime must be UTC. Use endTime.toUtc(). '
        'Current timezone offset: ${resolvedEnd.timeZoneOffset}',
      );
    }

    final firstUnitIndex = _unitHierarchy.indexOf(firstDateTimeUnit);
    final precisionIndex = _unitHierarchy.indexOf(precision);

    if (firstUnitIndex > precisionIndex) {
      throw ArgumentError(
        'firstDateTimeUnit ($firstDateTimeUnit) cannot be smaller than '
        'precision ($precision). Either set precision to $firstDateTimeUnit '
        'or set firstDateTimeUnit to $precision or larger.',
      );
    }

    final isFuture = !resolvedEnd.isBefore(startTime);

    if (startTime.isAtSameMomentAs(resolvedEnd)) {
      return DateTimeDelta(isFuture: isFuture);
    }

    final calcStart = startTime.isAfter(resolvedEnd) ? resolvedEnd : startTime;
    final calcEnd = startTime.isAfter(resolvedEnd) ? startTime : resolvedEnd;

    final result = _calculateTimeDifference(calcStart, calcEnd);

    return _applyFiltering(
      result,
      firstDateTimeUnit,
      precision,
      isFuture,
      truncate,
    );
  }

  /// Decomposes the span from [start] to [end] into calendar components.
  ///
  /// [start] must not be after [end]; [delta] guarantees this by reordering
  /// its inputs before calling here.
  ///
  /// ### Algorithm
  ///
  /// Each component is first computed as a raw field subtraction
  /// (`end.field - start.field`). Negative results are then resolved by
  /// borrowing from the next coarser unit, cascading from finest to coarsest:
  ///
  /// 1. Negative microseconds borrow 1 millisecond (+1000 µs).
  /// 2. Negative milliseconds borrow 1 second (+1000 ms).
  /// 3. Negative seconds borrow 1 minute (+60 s).
  /// 4. Negative minutes borrow 1 hour (+60 min).
  /// 5. Negative hours borrow 1 day (+24 h).
  /// 6. Negative days borrow 1 month, adding the number of days in the month
  ///    *preceding* [end]'s month. This runs in a loop because a single
  ///    borrow is not always enough (e.g. a 31-day shortfall against a
  ///    28-day February). The `DateTime(year, month + 1, 0)` idiom resolves
  ///    to the last day of `month`, giving its length.
  /// 7. Negative months borrow 1 year (+12 months).
  ///
  /// Every component in the returned map is therefore non-negative and
  /// within its natural range.
  ///
  /// ### Returns
  ///
  /// A map keyed by the plural unit names in [_unitNames]
  /// (`'years'`, `'months'`, …, `'microseconds'`).
  static Map<String, int> _calculateTimeDifference(
    DateTime start,
    DateTime end,
  ) {
    var years = end.year - start.year;
    var months = end.month - start.month;
    var days = end.day - start.day;
    var hours = end.hour - start.hour;
    var minutes = end.minute - start.minute;
    var seconds = end.second - start.second;
    var milliseconds = end.millisecond - start.millisecond;
    var microseconds = end.microsecond - start.microsecond;

    if (microseconds < 0) {
      milliseconds--;
      microseconds += 1000;
    }
    if (milliseconds < 0) {
      seconds--;
      milliseconds += 1000;
    }
    if (seconds < 0) {
      minutes--;
      seconds += 60;
    }
    if (minutes < 0) {
      hours--;
      minutes += 60;
    }
    if (hours < 0) {
      days--;
      hours += 24;
    }

    while (days < 0) {
      months--;
      var prevMonth = end.month - 1;
      var prevYear = end.year;
      if (prevMonth <= 0) {
        prevMonth = 12;
        prevYear--;
      }
      days += DateTime(prevYear, prevMonth + 1, 0).day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return {
      'years': years,
      'months': months,
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'milliseconds': milliseconds,
      'microseconds': microseconds,
    };
  }

  /// Projects the raw component map from [_calculateTimeDifference] onto a
  /// [DateTimeDelta], applying the caller's reporting window.
  ///
  /// For each [DateTimeUnit] the value is resolved as follows:
  ///
  /// * Units coarser than [firstDateTimeUnit] — i.e. not in
  ///   `firstDateTimeUnit.sublist()` — are **omitted** (`null`).
  /// * Units finer than [precision] are **zeroed** when [truncate] is `true`,
  ///   or **omitted** (`null`) when it is `false`.
  /// * Every other unit carries its computed value from [differences].
  ///
  /// [isFuture] is passed straight through to [DateTimeDelta.isFuture].
  ///
  /// This is a pure projection: it never alters magnitudes, only decides
  /// which ones are visible.
  static DateTimeDelta _applyFiltering(
    Map<String, int> differences,
    DateTimeUnit firstDateTimeUnit,
    DateTimeUnit precision,
    bool isFuture,
    bool truncate,
  ) {
    final fieldSet = firstDateTimeUnit.sublist();

    /// Resolves the reported value for [unit] per the rules documented on
    /// the enclosing method.
    int? getValue(DateTimeUnit unit) {
      if (!fieldSet.contains(unit)) return null;

      final unitIndex = _unitHierarchy.indexOf(unit);
      final precisionIndex = _unitHierarchy.indexOf(precision);

      if (unitIndex > precisionIndex) return truncate ? 0 : null;

      return differences[_unitNames[unit]!];
    }

    return DateTimeDelta(
      years: getValue(DateTimeUnit.year),
      months: getValue(DateTimeUnit.month),
      days: getValue(DateTimeUnit.day),
      hours: getValue(DateTimeUnit.hour),
      minutes: getValue(DateTimeUnit.minute),
      seconds: getValue(DateTimeUnit.second),
      milliseconds: getValue(DateTimeUnit.msec),
      microseconds: getValue(DateTimeUnit.usec),
      isFuture: isFuture,
    );
  }
}
