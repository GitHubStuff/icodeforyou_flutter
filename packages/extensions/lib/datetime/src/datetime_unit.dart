// packages/extensions/lib/datetime/src/datetime_unit.dart

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

  /// Returns all [DateTimeUnit] values from this unit through
  /// [usec], inclusive.
  Set<DateTimeUnit> sublist() {
    final index = DateTimeUnit.values.indexOf(this);
    return Set<DateTimeUnit>.from(DateTimeUnit.values.sublist(index));
  }
}
