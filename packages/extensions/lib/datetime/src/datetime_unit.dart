// extensions/lib/src/datetime_unit.dart

/// DateTime unit enumeration with time conversion constants and
/// utility methods.
enum DateTimeUnit {
  /// Calendar year precision.
  year,

  /// Calendar month precision.
  month,

  /// Calendar day precision.
  day,

  /// Hour precision.
  hour,

  /// Minute precision.
  minute,

  /// Second precision.
  second,

  /// Millisecond precision.
  msec,

  /// Microsecond precision.
  usec;

  /// Number of months in a year.
  static const num kMonthsPerYear = 12;

  /// Number of hours in a day.
  static const num kHoursPerDay = 24;

  /// Number of minutes in an hour.
  static const num kMinutesPerHour = 60;

  /// Number of seconds in a minute.
  static const num kSecondsPerMinute = 60;

  /// Number of milliseconds in a second.
  static const num kMsecPerSecond = 1000;

  /// Number of microseconds in a millisecond.
  static const num kUsecPerMsec = 1000;

  /// Placeholder value for months with a variable number of days.
  static const num kDaysPlaceholder = 0;

  /// Number of days in January.
  static const num kDaysJanuary = 31;

  /// Number of days in February (non-leap year).
  static const num kDaysFebruary = 28;

  /// Number of days in February (leap year).
  static const num kDaysFebruaryLeap = 29;

  /// Number of days in March.
  static const num kDaysMarch = 31;

  /// Number of days in April.
  static const num kDaysApril = 30;

  /// Number of days in May.
  static const num kDaysMay = 31;

  /// Number of days in June.
  static const num kDaysJune = 30;

  /// Number of days in July.
  static const num kDaysJuly = 31;

  /// Number of days in August.
  static const num kDaysAugust = 31;

  /// Number of days in September.
  static const num kDaysSeptember = 30;

  /// Number of days in October.
  static const num kDaysOctober = 31;

  /// Number of days in November.
  static const num kDaysNovember = 30;

  /// Number of days in December.
  static const num kDaysDecember = 31;

  /// Creates a local [DateTime] truncated to [truncateAt] precision.
  ///
  /// Defaults to the current system time if [dateTime] is null.
  static DateTime makeLocal(
    DateTime? dateTime, {
    DateTimeUnit truncateAt = DateTimeUnit.second,
  }) => (dateTime ?? DateTime.now()).toLocal().truncate(
    atDateTimeUnit: truncateAt,
  );

  /// Creates a UTC [DateTime] truncated to [truncateAt] precision.
  ///
  /// Defaults to the current system time if [dateTime] is null.
  static DateTime makeUtc(
    DateTime? dateTime, {
    DateTimeUnit truncateAt = DateTimeUnit.second,
  }) =>
      (dateTime ?? DateTime.now()).toUtc().truncate(atDateTimeUnit: truncateAt);

  /// Returns the next [DateTimeUnit] in ascending precision order,
  /// or null if this is already [usec].
  DateTimeUnit? get next {
    if (this == usec) return null;
    final index = DateTimeUnit.values.indexOf(this);
    return DateTimeUnit.values[index + 1];
  }

  /// Returns all [DateTimeUnit] values from this unit through
  /// [usec], inclusive.
  Set<DateTimeUnit> sublist() {
    final index = DateTimeUnit.values.indexOf(this);
    return Set<DateTimeUnit>.from(DateTimeUnit.values.sublist(index));
  }
}

/// Extension on [DateTime] providing truncation to a [DateTimeUnit] precision.
extension DateTimeExtensions on DateTime {
  /// Truncates this [DateTime] to [atDateTimeUnit] precision.
  ///
  /// All smaller units are reset to their minimum values.
  /// Preserves the timezone (UTC vs local) of the original [DateTime].
  DateTime truncate({required DateTimeUnit atDateTimeUnit}) {
    final constructor = isUtc ? DateTime.utc : DateTime.new;
    return switch (atDateTimeUnit) {
      DateTimeUnit.year => constructor(year),
      DateTimeUnit.month => constructor(year, month),
      DateTimeUnit.day => constructor(year, month, day),
      DateTimeUnit.hour => constructor(year, month, day, hour),
      DateTimeUnit.minute => constructor(year, month, day, hour, minute),
      DateTimeUnit.second => constructor(
        year,
        month,
        day,
        hour,
        minute,
        second,
      ),
      DateTimeUnit.msec => constructor(
        year,
        month,
        day,
        hour,
        minute,
        second,
        millisecond,
      ),
      DateTimeUnit.usec => constructor(
        year,
        month,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      ),
    };
  }
}
