// packages/time_spans/lib/src/duration/extended_duration_unit.dart

/// Identifies a single calendar component of an `ExtendedDuration`.
///
/// The members form a superset of the units exposed by the core [Duration]
/// type, adding [year], [month], and [week] to the fixed-length units that
/// [Duration] already models. They are declared in descending order of
/// magnitude, from the coarsest ([year]) to the finest ([microsecond]), so
/// iterating the enum walks a duration from its largest component down to its
/// smallest.
///
/// The units fall into two groups:
///
/// - **Calendar-variable** — [year] and [month] have no fixed length. A year
///   spans 365 or 366 days, and a month spans 28 to 31 days, so resolving
///   either to a smaller unit requires a calendar reference together with a
///   policy (such as a `MonthPolicy` or `LeapDayPolicy`). This is exactly why
///   [Duration] omits them.
/// - **Fixed-length** — [week] through [microsecond] each have a constant
///   length and convert between one another by integer factors alone.
///
/// Use a member to name *which* component is being read, formatted, or
/// operated on; the component's magnitude lives on `ExtendedDuration`, not
/// here.
enum ExtendedDurationUnit {
  /// The year unit.
  ///
  /// A calendar-variable unit spanning 365 days in a common year and 366 in a
  /// leap year. Not modelled by [Duration]; resolving it to days or smaller
  /// depends on the surrounding calendar context.
  year,

  /// The month unit.
  ///
  /// A calendar-variable unit spanning 28 to 31 days, depending on the month
  /// and the year. Not modelled by [Duration]; resolving it to a smaller unit
  /// requires a month-length policy.
  month,

  /// The week unit.
  ///
  /// A fixed-length unit equal to 7 [day]s. Not modelled by [Duration],
  /// though it is exactly derivable from it.
  week,

  /// The day unit.
  ///
  /// A fixed-length unit equal to 24 [hour]s. Matches the day modelled by
  /// [Duration], which treats a day as exactly 24 hours and ignores
  /// daylight-saving transitions.
  day,

  /// The hour unit.
  ///
  /// A fixed-length unit equal to 60 [minute]s.
  hour,

  /// The minute unit.
  ///
  /// A fixed-length unit equal to 60 [second]s.
  minute,

  /// The second unit.
  ///
  /// A fixed-length unit equal to 1000 [millisecond]s.
  second,

  /// The millisecond unit.
  ///
  /// A fixed-length unit equal to 1000 [microsecond]s.
  millisecond,

  /// The microsecond unit.
  ///
  /// The finest unit modelled here, and the resolution at which [Duration]
  /// stores its value internally.
  microsecond,
}
