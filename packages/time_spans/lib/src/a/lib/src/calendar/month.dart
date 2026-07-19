// packages/time_spans/lib/src/calendar/month.dart

import 'year.dart';

/// A month of the Gregorian calendar, carrying its own length in days.
///
/// Members are declared in calendar order, from [january] to [december]. Each
/// is constructed with its common-year (non-leap) length; the leap-aware
/// length and the last calendar day are resolved through [daysInMonth] and
/// [lastDay], both of which defer to [Year] for the leap rule so the rule
/// lives in exactly one place.
///
/// Note that [index] is zero-based — `Month.january.index` is `0`, not `1`.
/// To interoperate with [DateTime], whose month numbers are one-based
/// (`DateTime.january == 1`), use [Month.fromDateTime] or add one to the
/// index rather than relying on the ordinal directly.
enum Month {
  /// The month of January, which always has 31 days.
  january(31),

  /// The month of February, which has 28 days in a common year and 29 in a
  /// leap year.
  february(28),

  /// The month of March, which always has 31 days.
  march(31),

  /// The month of April, which always has 30 days.
  april(30),

  /// The month of May, which always has 31 days.
  may(31),

  /// The month of June, which always has 30 days.
  june(30),

  /// The month of July, which always has 31 days.
  july(31),

  /// The month of August, which always has 31 days.
  august(31),

  /// The month of September, which always has 30 days.
  september(30),

  /// The month of October, which always has 31 days.
  october(31),

  /// The month of November, which always has 30 days.
  november(30),

  /// The month of December, which always has 31 days.
  december(31),
  ;

  /// Creates a month with its [commonYearDays] length.
  const Month(this.commonYearDays);

  /// The [Month] that [dateTime] falls in.
  ///
  /// Reads the one-based [DateTime.month] and maps it onto the zero-based
  /// [index], so a `DateTime` in March returns [Month.march].
  static Month fromDateTime(DateTime dateTime) => values[dateTime.month - 1];

  /// The number of days this month has in a common (non-leap) year.
  ///
  /// For every month except [february] this is also the leap-year length;
  /// [february] is `28` here and `29` in a leap year. Prefer [daysInMonth] or
  /// [lastDay] when the year's leapness matters, and read this field only for
  /// the fixed common-year length.
  final int commonYearDays;

  /// The number of days in this month for a year of the given leapness.
  ///
  /// Returns [commonYearDays] for every month except [february], which
  /// returns `29` when [isLeapYear] is `true`. The leap rule itself is not
  /// evaluated here — pass an already-resolved [isLeapYear], or call [lastDay]
  /// to have [Year] resolve it.
  int daysInMonth({required bool isLeapYear}) =>
      this == Month.february && isLeapYear ? 29 : commonYearDays;

  /// The last calendar day of this month in [year].
  ///
  /// Resolves the year's leapness through [Year] — the canonical leap rule —
  /// so 29 February is reported only in leap years. This is the single source
  /// of "last day of month" for the package; interval and age logic call it
  /// rather than re-deriving month lengths.
  int lastDay({required int year}) =>
      daysInMonth(isLeapYear: Year(year).isLeapYear);
}
