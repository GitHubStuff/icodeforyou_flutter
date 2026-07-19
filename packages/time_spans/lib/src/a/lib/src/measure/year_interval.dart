// packages/time_spans/lib/src/measure/year_interval.dart

import '../calendar/month.dart';
import 'interval.dart';

/// An [Interval] that measures the whole-year span between its endpoints using
/// calendar-anniversary semantics rather than a flat day count.
///
/// A year is counted only when the later endpoint **reaches or passes** the
/// earlier endpoint's calendar anniversary (its same month, day, and
/// time-of-day in a later year). This matches how reminders and calendars
/// treat yearly recurrence, and is intentionally distinct from `Duration`,
/// which has no concept of calendar years.
///
/// ## Normalization
///
/// Both endpoints are converted to UTC before [years] is measured, so
/// daylight-saving transitions, standard-time changes, and fractional
/// timezone offsets never affect the count. Endpoints are compared at full
/// stored precision (down to microseconds); applying any coarser truncation
/// is the caller's responsibility. The inherited [exact] and [order] operate
/// on the endpoints as given.
///
/// ## End-of-month rule
///
/// When the earlier endpoint falls on the **last day of its month**, every
/// anniversary clamps to the last day of that same month in the target year
/// (resolved through [Month.lastDay]). This is the sole source of leap-year
/// drift: a 29-February origin lands on 28-February in common years and
/// 29-February in leap years. An origin that is not its month's last day keeps
/// its literal day, which is valid in every later year.
///
/// ## Example
///
/// ```dart
/// final interval = YearInterval(
///   start: DateTime.utc(2020, 2, 29, 18),
///   finish: DateTime.utc(2021, 2, 28, 18),
/// );
/// interval.years; // 1   (28-Feb-2021 is the clamped anniversary)
/// interval.order; // DateTimeOrder.before
/// ```
final class YearInterval extends Interval {
  /// Creates a year interval between [start] and [finish], preserving the
  /// argument order for [order] and [exact].
  const YearInterval({required DateTime start, required DateTime finish})
    : super(start, finish);

  /// The number of whole calendar-year anniversaries spanned by the interval.
  ///
  /// Always non-negative. An anniversary counts only when [later] reaches or
  /// passes it, honouring the end-of-month rule described on [YearInterval].
  int get years {
    final origin = earlier.toUtc();
    final target = later.toUtc();
    final candidate = target.year - origin.year;
    if (candidate <= 0) return 0;
    final anniversary = _anniversaryOf(origin, candidate);
    return target.isBefore(anniversary) ? candidate - 1 : candidate;
  }

  /// Builds the [yearsAhead]-th anniversary of [origin], in UTC.
  ///
  /// When [origin] is its month's last day the anniversary clamps to the last
  /// day of the target month; otherwise the literal day is preserved. All
  /// sub-day fields are carried through so the comparison stays exact.
  static DateTime _anniversaryOf(DateTime origin, int yearsAhead) {
    final month = Month.fromDateTime(origin);
    final originIsMonthEnd = origin.day == month.lastDay(year: origin.year);
    final targetYear = origin.year + yearsAhead;
    final day = originIsMonthEnd
        ? month.lastDay(year: targetYear)
        : origin.day;
    return DateTime.utc(
      targetYear,
      origin.month,
      day,
      origin.hour,
      origin.minute,
      origin.second,
      origin.millisecond,
      origin.microsecond,
    );
  }
}
