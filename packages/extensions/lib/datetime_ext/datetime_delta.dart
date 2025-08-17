// datetime_delta.dart - ORIGINAL ALGORITHM WITH MINIMAL FIXES
// ignore_for_file: omit_local_variable_types

import 'datetime_unit.dart';

typedef TimeMap = Map<String, num>;

(T, T) swap<T>(T a, T b) => (b, a);

/// Immutable class representing a time delta between two DateTime objects.
class DateTimeDelta {
  final int? years;
  final int? months;
  final int? days;
  final int? hours;
  final int? minutes;
  final int? seconds;
  final int? milliseconds;
  final int? microseconds;
  final bool isFuture;

  const DateTimeDelta({
    this.years,
    this.months,
    this.days,
    this.hours,
    this.minutes,
    this.seconds,
    this.milliseconds,
    this.microseconds,
    required this.isFuture,
  });

  /// Factory method to calculate time delta between two DateTime objects.
  /// Both startTime and endTime must be UTC. Use DateTime.toUtc() if needed.
  static DateTimeDelta delta({
    required DateTime startTime,
    DateTime? endTime,
    DateTimeUnit firstDateTimeUnit = DateTimeUnit.year,
    DateTimeUnit precision = DateTimeUnit.second,
    bool truncate = true,
  }) {
    return _DateTimeDifference.delta(
      startTime: startTime,
      endTime: endTime,
      firstDateTimeUnit: firstDateTimeUnit,
      precision: precision,
      truncate: truncate,
    );
  }

  @override
  String toString() {
    final parts = <String>[];

    if (years != null && years! > 0) parts.add('${years}y');
    if (months != null && months! > 0) parts.add('${months}mo');
    if (days != null && days! > 0) parts.add('${days}d');
    if (hours != null && hours! > 0) parts.add('${hours}h');
    if (minutes != null && minutes! > 0) parts.add('${minutes}m');
    if (seconds != null && seconds! > 0) parts.add('${seconds}s');
    if (milliseconds != null && milliseconds! > 0) {
      parts.add('${milliseconds}ms');
    }
    if (microseconds != null && microseconds! > 0) {
      parts.add('$microsecondsμs');
    }

    if (parts.isEmpty) return '0';

    final result = parts.join(' ');
    return isFuture ? result : '-$result';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateTimeDelta &&
          runtimeType == other.runtimeType &&
          years == other.years &&
          months == other.months &&
          days == other.days &&
          hours == other.hours &&
          minutes == other.minutes &&
          seconds == other.seconds &&
          milliseconds == other.milliseconds &&
          microseconds == other.microseconds &&
          isFuture == other.isFuture;

  @override
  int get hashCode =>
      years.hashCode ^
      months.hashCode ^
      days.hashCode ^
      hours.hashCode ^
      minutes.hashCode ^
      seconds.hashCode ^
      milliseconds.hashCode ^
      microseconds.hashCode ^
      isFuture.hashCode;
}

/// Private implementation class for calculating time differences.
/// Only accessible within this library through DateTimeDelta.
class _DateTimeDifference {
  // Private constructor to prevent external instantiation
  _DateTimeDifference._();

  /// Calculate time delta between two DateTime objects.
  /// Both startTime and endTime must be UTC.
  static DateTimeDelta delta({
    required DateTime startTime,
    DateTime? endTime,
    DateTimeUnit firstDateTimeUnit = DateTimeUnit.year,
    DateTimeUnit precision = DateTimeUnit.second,
    bool truncate = true,
  }) {
    endTime = endTime ?? DateTime.now().toUtc();

    // Require UTC inputs - fail fast if not UTC
    assert(startTime.isUtc, 'startTime must be UTC. Use startTime.toUtc()');
    assert(endTime.isUtc, 'endTime must be UTC. Use endTime.toUtc()');

    // Validate that firstDateTimeUnit is not smaller than precision
    const unitHierarchy = [
      DateTimeUnit.year,
      DateTimeUnit.month,
      DateTimeUnit.day,
      DateTimeUnit.hour,
      DateTimeUnit.minute,
      DateTimeUnit.second,
      DateTimeUnit.msec,
      DateTimeUnit.usec,
    ];

    final firstUnitIndex = unitHierarchy.indexOf(firstDateTimeUnit);
    final precisionIndex = unitHierarchy.indexOf(precision);

    assert(
      firstUnitIndex <= precisionIndex,
      'firstDateTimeUnit ($firstDateTimeUnit) cannot be smaller than precision ($precision). '
      'Either increase precision or decrease firstDateTimeUnit.',
    );

    if (firstUnitIndex > precisionIndex) {
      throw ArgumentError(
        'firstDateTimeUnit ($firstDateTimeUnit) cannot be smaller than precision ($precision). '
        'Either set precision to $firstDateTimeUnit or set firstDateTimeUnit to $precision or larger.',
      );
    }

    // Determine direction
    final bool isFuture = !endTime.isBefore(startTime);

    if (startTime.isAtSameMomentAs(endTime)) {
      return DateTimeDelta(isFuture: isFuture);
    }

    // Always calculate from earlier to later, then apply direction at the end
    DateTime calcStart = startTime;
    DateTime calcEnd = endTime;

    if (startTime.isAfter(endTime)) {
      calcStart = endTime;
      calcEnd = startTime;
    }

    // Calculate the time difference step by step
    final result = _calculateTimeDifference(calcStart, calcEnd);

    // Apply fieldSet and precision filtering
    return _applyFiltering(
      result,
      firstDateTimeUnit,
      precision,
      isFuture,
      truncate,
    );
  }

  /// Calculate time difference between two DateTime objects (start < end)
  /// ORIGINAL ALGORITHM - ONLY fix the while loop issue
  static Map<String, int> _calculateTimeDifference(
    DateTime start,
    DateTime end,
  ) {
    int years = end.year - start.year;
    int months = end.month - start.month;
    int days = end.day - start.day;
    int hours = end.hour - start.hour;
    int minutes = end.minute - start.minute;
    int seconds = end.second - start.second;
    int milliseconds = end.millisecond - start.millisecond;
    int microseconds = end.microsecond - start.microsecond;

    // Handle negative microseconds
    if (microseconds < 0) {
      milliseconds--;
      microseconds += 1000;
    }

    // Handle negative milliseconds
    if (milliseconds < 0) {
      seconds--;
      milliseconds += 1000;
    }

    // Handle negative seconds
    if (seconds < 0) {
      minutes--;
      seconds += 60;
    }

    // Handle negative minutes
    if (minutes < 0) {
      hours--;
      minutes += 60;
    }

    // Handle negative hours
    if (hours < 0) {
      days--;
      hours += 24;
    }

    // Handle negative days - FIXED: Use while loop instead of if
    while (days < 0) {
      months--;

      // Get the month that's one month before the end month
      int prevMonth = end.month - 1;
      int prevYear = end.year;

      if (prevMonth <= 0) {
        prevMonth = 12;
        prevYear--;
      }

      final daysInPrevMonth = DateTime(prevYear, prevMonth + 1, 0).day;
      days += daysInPrevMonth;
    }

    // Handle negative months
    if (months < 0) {
      years--;
      months += 12;
    }

    return {
      'years': years,
      'months': months,
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'milliseconds': milliseconds,
      'microseconds': microseconds,
    };
  }

  /// Apply fieldSet and precision filtering to the calculated differences
  /// ORIGINAL LOGIC
  static DateTimeDelta _applyFiltering(
    Map<String, int> differences,
    DateTimeUnit firstDateTimeUnit,
    DateTimeUnit precision,
    bool isFuture,
    bool truncate,
  ) {
    final fieldSet = firstDateTimeUnit.sublist();

    // Define the hierarchy of units from largest to smallest
    const unitHierarchy = [
      DateTimeUnit.year,
      DateTimeUnit.month,
      DateTimeUnit.day,
      DateTimeUnit.hour,
      DateTimeUnit.minute,
      DateTimeUnit.second,
      DateTimeUnit.msec,
      DateTimeUnit.usec,
    ];

    // Map unit names to their differences
    final unitNames = {
      DateTimeUnit.year: 'years',
      DateTimeUnit.month: 'months',
      DateTimeUnit.day: 'days',
      DateTimeUnit.hour: 'hours',
      DateTimeUnit.minute: 'minutes',
      DateTimeUnit.second: 'seconds',
      DateTimeUnit.msec: 'milliseconds',
      DateTimeUnit.usec: 'microseconds',
    };

    int? getValue(DateTimeUnit unit) {
      // Not in fieldSet - always null (filtered out completely)
      if (!fieldSet.contains(unit)) {
        return null;
      }

      // Get the indices of the current unit and precision unit
      final unitIndex = unitHierarchy.indexOf(unit);
      final precisionIndex = unitHierarchy.indexOf(precision);

      // If unit is below precision (larger index = smaller unit)
      if (unitIndex > precisionIndex) {
        return truncate ? 0 : null;
      }

      // In fieldSet and at/above precision - return calculated value
      final unitName = unitNames[unit]!;
      return differences[unitName];
    }

    return DateTimeDelta(
      years: getValue(DateTimeUnit.year),
      months: getValue(DateTimeUnit.month),
      days: getValue(DateTimeUnit.day),
      hours: getValue(DateTimeUnit.hour),
      minutes: getValue(DateTimeUnit.minute),
      seconds: getValue(DateTimeUnit.second),
      milliseconds: getValue(DateTimeUnit.msec),
      microseconds: getValue(DateTimeUnit.usec),
      isFuture: isFuture,
    );
  }
}
