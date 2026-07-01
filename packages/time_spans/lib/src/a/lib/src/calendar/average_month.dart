// packages/time_spans/lib/src/calendar/average_month.dart

/// The true long-run Gregorian average month length, `146097 / 4800` days.
///
/// Exact only at integer multiples of 4800 months; every shorter span wobbles
/// around it according to where leap days fall. Use it when a single,
/// span-agnostic figure is wanted rather than the horizon-tiered estimate of
/// [averageDaysPerMonth].
const double gregorianAverageDaysPerMonth = 30.436875;

/// A rough average number of days per month for a span of [months], picking
/// the approximation tier closest to that horizon.
///
/// This is a deliberate estimate, not a calendar-accurate conversion. The real
/// number of days in a span is path-dependent on the start date (which leap
/// days fall inside the window), so do **not** use this to turn a calendar
/// span into an exact `Duration` when correctness matters — only for
/// amortized, span-agnostic sizing. The tiers are:
///
/// - `<= 12`   months → common year (no leap correction)
/// - `<= 48`   months → Julian 4-year cycle
/// - `<= 1200` months → century span
/// - otherwise        → the full Gregorian cycle ([gregorianAverageDaysPerMonth])
double averageDaysPerMonth(int months) => switch (months) {
  <= 12 => _commonYearAverage,
  <= 48 => _julianCycleAverage,
  <= 1200 => _centuryAverage,
  _ => gregorianAverageDaysPerMonth,
};

/// Average days per month across a single common year: `365 / 12`.
const double _commonYearAverage = 30.416667;

/// Average days per month across a Julian 4-year cycle: `1461 / 48`.
///
/// Overshoots the Gregorian asymptote because it adds a leap day every four
/// years with no century correction.
const double _julianCycleAverage = 30.4375;

/// Average days per month across a 100-year span: `36524 / 1200`.
///
/// Undershoots slightly — the century skips its leap day, but the 400-year
/// restoration has not been applied yet at this horizon.
const double _centuryAverage = 30.436667;
