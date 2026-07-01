// packages/time_spans/lib/src/calendar/month_math.dart

import '../policy/month_policy.dart';
import 'month.dart';

/// Calendar month arithmetic: the single home for adding whole months to a
/// date and for counting the whole months between two dates.
///
/// Both operations resolve a day-of-month that overflows the target month
/// through a [MonthPolicy], and both read month lengths from [Month] so the
/// "last day of month" rule is never re-implemented. The interval types build
/// on these helpers instead of carrying their own copies of the month walk.
abstract final class MonthMath {
  /// Adds [months] whole months to [anchor], resolving an overflowing
  /// day-of-month according to [policy].
  ///
  /// Under [MonthPolicy.clamp] a day that does not exist in the target month
  /// is pulled back to that month's last day (31 January + 1 month →
  /// 28/29 February); under [MonthPolicy.overflow] the surplus days spill into
  /// the following month, matching `DateTime` rollover. The time-of-day and
  /// the UTC flag of [anchor] are preserved. [months] must be non-negative.
  static DateTime addMonths(
    DateTime anchor,
    int months,
    MonthPolicy policy,
  ) {
    final naive = anchor.copyWith(month: anchor.month + months);
    if (policy == MonthPolicy.overflow || naive.day == anchor.day) {
      return naive;
    }
    // The day overflowed into a later month; clamp to the last day of the
    // intended month. Compute the intended year/month from a zero-based index
    // so the year rolls over correctly past December.
    final intendedMonthIndex = anchor.month - 1 + months;
    final targetYear = anchor.year + intendedMonthIndex ~/ Month.values.length;
    final targetMonth = Month.values[intendedMonthIndex % Month.values.length];
    return anchor.copyWith(
      year: targetYear,
      month: targetMonth.index + 1,
      day: targetMonth.lastDay(year: targetYear),
    );
  }

  /// Counts the whole [policy]-adjusted months from [earlier] up to [later].
  ///
  /// Requires `later >= earlier`; the result is always non-negative. The count
  /// is seeded from the raw year/month difference, then corrected by walking
  /// the [addMonths] anchor down past any overshoot and up to the last
  /// anniversary at or before [later].
  static int wholeMonthsBetween(
    DateTime earlier,
    DateTime later,
    MonthPolicy policy,
  ) {
    var months =
        (later.year - earlier.year) * Month.values.length +
        (later.month - earlier.month);
    while (months > 0 && addMonths(earlier, months, policy).isAfter(later)) {
      months--;
    }
    while (!addMonths(earlier, months + 1, policy).isAfter(later)) {
      months++;
    }
    return months;
  }
}
