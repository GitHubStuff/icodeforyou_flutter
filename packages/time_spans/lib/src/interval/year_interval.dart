// packages/time_spans/lib/src/interval/year_interval.dart

import 'package:time_spans/src/span.dart' show Span;
import 'package:time_spans/time_spans.dart' show DateTimeOrder;

/// Measures the whole-year span and absolute elapsed time between two
/// [DateTime] instants, using calendar-anniversary semantics rather than a flat
/// day count.
///
/// A year is counted only when the later instant **reaches or passes** the
/// earlier instant's calendar anniversary (its same month, day, and
/// time-of-day in a later year). This matches how reminders and calendars treat
/// yearly recurrence, and it is intentionally distinct from `Duration`, which
/// has no concept of calendar years.
///
/// ## Normalization
///
/// Both inputs are converted to UTC before any measurement, so daylight-saving
/// transitions, standard-time changes, and fractional (half- or quarter-hour)
/// timezone offsets never affect the result. Inputs are compared at their full
/// stored precision (down to microseconds); applying any coarser truncation is
/// the caller's responsibility.
///
/// ## End-of-month rule
///
/// When the start instant falls on the **last day of its month**, every
/// anniversary clamps to the last day of that same month in the target year.
/// This is the sole source of leap-year drift:
///
/// * `29-Feb-2020` is the last day of February, so its anniversary lands on
///   `28-Feb` in common years and on `29-Feb` in leap years.
/// * `28-Feb-2019` is also the last day of February (2019 is common), so its
///   `2020` anniversary clamps **forward** to `29-Feb-2020`; reaching only
///   `28-Feb-2020` therefore counts as zero years.
///
/// A start instant that is *not* its month's last day keeps its literal day,
/// and that literal day is always valid in every later year.
///
/// ## Magnitude semantics
///
/// [years] and [milliseconds] are always non-negative magnitudes describing the
/// size of the span. [order] reports the direction — whether `start` precedes,
/// equals, or follows `finish` — so a reversed pair yields the same [years] and
/// [milliseconds] with [order] set to [DateTimeOrder.after].
///
/// ## Example
///
/// ```dart
/// final interval = YearInterval.of(
///   start: DateTime.utc(2020, 2, 29, 18),
///   finish: DateTime.utc(2021, 2, 28, 18),
/// );
/// interval.years; // 1   (28-Feb-2021 is the clamped anniversary)
/// interval.order; // DateTimeOrder.before
/// ```
class YearInterval {
  /// Measures the interval between [start] and [finish].
  ///
  /// Both inputs are normalized to UTC before measuring. The returned
  /// [YearInterval] reports the span's [YearInterval.years] and
  /// [YearInterval.milliseconds] as non-negative magnitudes, and its
  /// [YearInterval.order] records whether [start] precedes, equals, or follows
  /// [finish]. The argument order therefore affects only [YearInterval.order],
  /// never the magnitudes.
  factory YearInterval.of({
    required DateTime start,
    required DateTime finish,
  }) {
    final startUtc = start.toUtc();
    final finishUtc = finish.toUtc();

    final order = DateTimeOrder.direction(startUtc, finishUtc);
    final milliseconds =
        (finishUtc.millisecondsSinceEpoch - startUtc.millisecondsSinceEpoch)
            .abs();

    final earlier = startUtc.isAfter(finishUtc) ? finishUtc : startUtc;
    final later = startUtc.isAfter(finishUtc) ? startUtc : finishUtc;

    return YearInterval._(
      years: _yearsBetween(earlier, later),
      milliseconds: milliseconds,
      order: order,
    );
  }

  /// Creates an interval from already-computed components.
  ///
  /// Private so that [YearInterval.of] is the single source of truth and no
  /// caller can construct an instance whose [years], [milliseconds], and
  /// [order] disagree with one another.
  const YearInterval._({
    required this.years,
    required this.milliseconds,
    required this.order,
  });

  /// The number of whole calendar-year anniversaries spanned by the interval.
  ///
  /// Always non-negative. An anniversary counts only when the later instant
  /// reaches or passes it, honouring the end-of-month rule described on
  /// [YearInterval].
  final int years;

  /// The absolute elapsed time across the interval, in whole milliseconds.
  ///
  /// Computed from each instant's `millisecondsSinceEpoch`, so any sub-
  /// millisecond component is floored. This is a flat time delta and is
  /// independent of [years]; it does not stop at the last anniversary.
  final int milliseconds;

  /// The temporal direction of `start` relative to `finish`.
  ///
  /// [DateTimeOrder.before] when `start` is earlier, [DateTimeOrder.after]
  /// when `start` is later, and [DateTimeOrder.now] when the two instants are
  /// equal in UTC.
  final DateTimeOrder order;

  /// Counts the whole-year anniversaries of [earlier] that [later] reaches or
  /// passes.
  ///
  /// Requires `later >= earlier` (the caller orders the pair), so the result is
  /// never negative. The candidate count is the raw year difference; it is
  /// reduced by one when the final anniversary in [later]'s year has not yet
  /// been reached.
  static int _yearsBetween(DateTime earlier, DateTime later) {
    final candidate = later.year - earlier.year;
    if (candidate <= Span.kZeroYears) return Span.kZeroYears;

    final startIsEndOfMonth =
        earlier.day == _lastDayOfMonthUtc(earlier.year, earlier.month);
    final anniversary = _anniversaryUtc(
      earlier,
      candidate,
      startIsEndOfMonth: startIsEndOfMonth,
    );

    final reached = !later.isBefore(anniversary);
    return reached ? candidate : candidate - Span.kOneYear;
  }

  /// Builds the [yearsOffset]-th anniversary instant of [earlier], in UTC.
  ///
  /// When [startIsEndOfMonth] is true the day clamps to the last day of the
  /// target month (so a 29-Feb origin lands on 28-Feb in common years);
  /// otherwise the literal day is preserved. All sub-day fields are carried
  /// through at full precision so the anniversary comparison stays exact.
  static DateTime _anniversaryUtc(
    DateTime earlier,
    int yearsOffset, {
    required bool startIsEndOfMonth,
  }) {
    final targetYear = earlier.year + yearsOffset;
    final day = startIsEndOfMonth
        ? _lastDayOfMonthUtc(targetYear, earlier.month)
        : earlier.day;
    return DateTime.utc(
      targetYear,
      earlier.month,
      day,
      earlier.hour,
      earlier.minute,
      earlier.second,
      earlier.millisecond,
      earlier.microsecond,
    );
  }

  /// Returns the last calendar day of [month] in [year].
  ///
  /// Works for every month, including a leap-year February, by asking for day
  /// `0` of the following month, which Dart normalizes to the last day of the
  /// requested month.
  static int _lastDayOfMonthUtc(int year, int month) =>
      DateTime.utc(year, month + Span.kNextMonthOffset, Span.kDayBeforeFirst).day;
}
