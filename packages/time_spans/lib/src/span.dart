// packages/time_spans/lib/src/spans.dart

class Span {
  /// February, the only month whose length varies between years.
  static const int kFebruary = 2;

  /// March, the rollover month for the [LeapDayPolicy.mar1] convention.
  static const int kMarch = 3;

  /// The 29th, the leap day that only exists in leap years.
  static const int kLeapDay = 29;

  /// The 28th, the [LeapDayPolicy.feb28] birthday in common years.
  static const int kFeb28 = 28;

  /// The 1st, the [LeapDayPolicy.mar1] birthday in common years.
  static const int kMar1 = 1;

  /// The age reported when no birthday has been reached.
  static const int kZeroYears = 0;

  /// The single-year decrement applied before this year's birthday.
  static const int kOneYear = 1;

  /// The offset from February to the following month.
  static const int kMonthAfterFebruary = 1;

  /// The offset from a month to the month that follows it.
  static const int kNextMonthOffset = 1;

  /// The day index that, against the following month, resolves to the last day
  /// of the current month (day `0` rolls back to the prior month's end).
  static const int kDayBeforeFirst = 0;

  /// Average days per month for a single common year: 365 / 12.
  ///
  /// Use this when the span is short enough that leap days are noise.
  static const double kCommonYearAvg = 30.416667;

  /// Average days per month across a Julian 4-year cycle: 1461 / 48.
  ///
  /// Overshoots the true Gregorian asymptote because it adds a leap day
  /// every 4 years with no century correction.
  static const double kJulianCycleAvg = 30.437500;

  /// Average days per month across a 100-year span: 36524 / 1200.
  ///
  /// Undershoots slightly — the century skips its leap day, but the
  /// 400-year restoration hasn't been applied yet at this horizon.
  static const double kCenturyAvg = 30.436667;

  /// Average days per month across a full Gregorian cycle: 146097 / 4800.
  ///
  /// The true long-run value. Exact only at integer multiples of 4800
  /// months; every other span wobbles around it by leap-day placement.
  static const double kGregorianCycleAvg = 30.436875;

  /// Number of months in a year
  static const int kMonthsPerYear = 12;

  static const int kDaysPerWeek = 7;
  static const int kHoursPerDay = 24;
  static const int kMinutesPerHour = 60;
  static const int kSecondsPerMinute = 60;
  static const int kMillisecondsPerSecond = 1000;
  static const int kMicrosecondsPerMillisecond = 1000;
}
