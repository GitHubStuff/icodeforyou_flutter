// packages/time_spans/lib/time_spans.dart

/// Calendar-aware durations, periods, intervals, and ages.
library;

export 'src/calendar/average_month.dart'
    show averageDaysPerMonth, gregorianAverageDaysPerMonth;
export 'src/calendar/month.dart' show Month;
export 'src/calendar/year.dart' show Year;
export 'src/comparison/datetime_order.dart' show DateTimeOrder;
export 'src/duration/extended_duration.dart' show ExtendedDuration;
export 'src/duration/extended_duration_unit.dart' show ExtendedDurationUnit;
export 'src/measure/interval.dart' show Interval;
export 'src/measure/legal_age.dart' show LegalAge;
export 'src/measure/month_interval.dart' show MonthInterval;
export 'src/measure/year_interval.dart' show YearInterval;
export 'src/policy/leap_day_policy.dart' show LeapDayPolicy;
export 'src/policy/month_policy.dart' show MonthPolicy;
