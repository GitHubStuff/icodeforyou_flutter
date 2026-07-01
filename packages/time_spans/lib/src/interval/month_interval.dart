// packages/time_spans/lib/src/duration/month_duration.dart
// ignore_for_file: public_member_api_docs

import 'package:time_spans/src/policy/month_policy.dart' show MonthPolicy;
import 'package:time_spans/src/span.dart' show Span;

class MonthInterval {
  /// interval [start]..[finish].
  ///
  /// Internally counts the whole months, lands on the final monthly anniversary
  /// at or before the later endpoint, and returns the microseconds from the
  /// earlier endpoint up to that anniversary — i.e. the slice of the interval
  /// the complete months actually consume. Always >= 0 and order-independent.
  ///
  /// The leftover partial month (the tail past the last anniversary) is:
  /// `finish.difference(start).inMicroseconds.abs() - microsecondMonths(...)`.
  static int microsecondMonths(
    DateTime start,
    DateTime finish, [
    MonthPolicy policy = MonthPolicy.clamp,
  ]) {
    final earlier = start.isAfter(finish) ? finish : start;
    final later = start.isAfter(finish) ? start : finish;
    var months =
        (later.year - earlier.year) * Span.kMonthsPerYear +
        (later.month - earlier.month);
    while (months > 0 && _addMonths(earlier, months, policy).isAfter(later)) {
      months--;
    }
    while (!_addMonths(earlier, months + 1, policy).isAfter(later)) {
      months++;
    }

    final anchor = _addMonths(earlier, months, policy);
    return anchor.difference(earlier).inMicroseconds;
  }

  /// Whole calendar months from [start] up to [asOf], clamped (a Jan-31 anchor
  /// lands on Feb 28 / Feb 29).
  ///
  /// Date-only: the time-of-day of both arguments is ignored. Directional:
  /// positive when [asOf] is on or past the monthly anniversary of [start],
  /// negative when [asOf] precedes [start].
  static int completedMonths(DateTime start, DateTime asOf) {
    var months =
        (asOf.year - start.year) * Span.kMonthsPerYear +
        (asOf.month - start.month);
    if (asOf.day < _clampedDay(start.day, asOf.year, asOf.month)) {
      months--;
    }
    return months;
  }

  /// Whole calendar years from [start] up to [asOf] — age, yearly
  /// anniversaries, completed contract years.
  ///
  /// A Feb-29 anchor rolls its anniversary to Feb 28 in non-leap years
  /// (clamped convention). Date-only and directional, inheriting both from
  /// [completedMonths].
  static int completedYears(DateTime start, DateTime asOf) =>
      completedMonths(start, asOf) ~/ Span.kMonthsPerYear;

  /// The day [day] resolves to within [year]/[month], pulled back to that
  /// month's last day when it would overflow. Day 0 of the following month IS
  /// that last day.
  static int _clampedDay(int day, int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return day < lastDay ? day : lastDay;
  }

  /// Counts the number of whole [MonthPolicy]-adjusted months between [start]
  /// and [finish].
  ///
  /// Returns 0 when both refer to the same instant.
  static int monthCounter({
    required DateTime start,
    required DateTime finish,
    required MonthPolicy monthPolicy,
  }) {
    if (start.isAtSameMomentAs(finish)) return 0;
    if (start.isAfter(finish)) {
      return monthCounter(
        start: finish,
        finish: start,
        monthPolicy: monthPolicy,
      ).abs();
    }

    var months =
        (finish.year - start.year) * Span.kMonthsPerYear +
        (finish.month - start.month);

    while (months > 0 &&
        _addMonths(start, months, monthPolicy).isAfter(finish)) {
      months--;
    }
    while (!_addMonths(start, months + 1, monthPolicy).isAfter(finish)) {
      months++;
    }
    return -months;
  }

  /// Adds [months] whole months to [anchor], resolving an overflowing
  /// day-of-month according to [policy].
  static DateTime _addMonths(DateTime anchor, int months, MonthPolicy policy) {
    final target = anchor.copyWith(month: anchor.month + months);
    if (policy == MonthPolicy.overflow || target.day == anchor.day) {
      return target;
    }
    // The day overflowed into a later month; clamp to the last day of the
    // intended month. Day 0 of the following month IS that last day.
    final lastDay = DateTime(anchor.year, anchor.month + months + 1, 0).day;
    return anchor.copyWith(month: anchor.month + months, day: lastDay);
  }

  /// Returns a rough average number of days per month for a span of
  /// [months], picking the approximation tier closest to that horizon.
  ///
  /// This is a deliberate estimate, not a calendar-accurate conversion.
  /// The real days-in-a-span is path-dependent on the start date (which
  /// leap days fall inside the window), so do **not** use this to turn a
  /// `Period` into a `Duration` when correctness matters — only for
  /// amortized, span-agnostic sizing.
  ///
  /// Tiers mirror the standard breakdown:
  /// - `<= 12`   months -> common year (no leap correction)
  /// - `<= 48`   months -> Julian 4-year cycle
  /// - `<= 1200` months -> century span
  /// - else            -> full Gregorian cycle (the asymptote)
  static double averageDaysPerMonth(int months) => switch (months) {
    <= 12 => Span.kCommonYearAvg,
    <= 48 => Span.kJulianCycleAvg,
    <= 1200 => Span.kCenturyAvg,
    _ => Span.kGregorianCycleAvg,
  };
}
