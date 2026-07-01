// lib/src/_datetime_difference.dart

part of 'datetime_delta.dart';

class _DateTimeDifference {
  _DateTimeDifference._(); // coverage:ignore-line

  static const List<DateTimeUnit> _unitHierarchy = [
    DateTimeUnit.year,
    DateTimeUnit.month,
    DateTimeUnit.day,
    DateTimeUnit.hour,
    DateTimeUnit.minute,
    DateTimeUnit.second,
    DateTimeUnit.msec,
    DateTimeUnit.usec,
  ];

  static const Map<DateTimeUnit, String> _unitNames = {
    DateTimeUnit.year: 'years',
    DateTimeUnit.month: 'months',
    DateTimeUnit.day: 'days',
    DateTimeUnit.hour: 'hours',
    DateTimeUnit.minute: 'minutes',
    DateTimeUnit.second: 'seconds',
    DateTimeUnit.msec: 'milliseconds',
    DateTimeUnit.usec: 'microseconds',
  };

  static DateTimeDelta delta({
    required DateTime startTime,
    DateTime? endTime,
    DateTimeUnit firstDateTimeUnit = DateTimeUnit.year,
    DateTimeUnit precision = DateTimeUnit.second,
    bool truncate = true,
  }) {
    final resolvedEnd = endTime ?? DateTime.now().toUtc();

    if (!startTime.isUtc) {
      throw ArgumentError(
        'startTime must be UTC. Use startTime.toUtc(). '
        'Current timezone offset: ${startTime.timeZoneOffset}',
      );
    }

    if (!resolvedEnd.isUtc) {
      throw ArgumentError(
        'endTime must be UTC. Use endTime.toUtc(). '
        'Current timezone offset: ${resolvedEnd.timeZoneOffset}',
      );
    }

    final firstUnitIndex = _unitHierarchy.indexOf(firstDateTimeUnit);
    final precisionIndex = _unitHierarchy.indexOf(precision);

    if (firstUnitIndex > precisionIndex) {
      throw ArgumentError(
        'firstDateTimeUnit ($firstDateTimeUnit) cannot be smaller than '
        'precision ($precision). Either set precision to $firstDateTimeUnit '
        'or set firstDateTimeUnit to $precision or larger.',
      );
    }

    final bool isFuture = !resolvedEnd.isBefore(startTime);

    if (startTime.isAtSameMomentAs(resolvedEnd)) {
      return DateTimeDelta(isFuture: isFuture);
    }

    final calcStart = startTime.isAfter(resolvedEnd) ? resolvedEnd : startTime;
    final calcEnd = startTime.isAfter(resolvedEnd) ? startTime : resolvedEnd;

    final result = _calculateTimeDifference(calcStart, calcEnd);

    return _applyFiltering(
      result,
      firstDateTimeUnit,
      precision,
      isFuture,
      truncate,
    );
  }

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

    if (microseconds < 0) {
      milliseconds--;
      microseconds += 1000;
    }
    if (milliseconds < 0) {
      seconds--;
      milliseconds += 1000;
    }
    if (seconds < 0) {
      minutes--;
      seconds += 60;
    }
    if (minutes < 0) {
      hours--;
      minutes += 60;
    }
    if (hours < 0) {
      days--;
      hours += 24;
    }

    while (days < 0) {
      months--;
      int prevMonth = end.month - 1;
      int prevYear = end.year;
      if (prevMonth <= 0) {
        prevMonth = 12;
        prevYear--;
      }
      days += DateTime(prevYear, prevMonth + 1, 0).day;
    }

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

  static DateTimeDelta _applyFiltering(
    Map<String, int> differences,
    DateTimeUnit firstDateTimeUnit,
    DateTimeUnit precision,
    bool isFuture,
    bool truncate,
  ) {
    final fieldSet = firstDateTimeUnit.sublist();

    int? getValue(DateTimeUnit unit) {
      if (!fieldSet.contains(unit)) return null;

      final unitIndex = _unitHierarchy.indexOf(unit);
      final precisionIndex = _unitHierarchy.indexOf(precision);

      if (unitIndex > precisionIndex) return truncate ? 0 : null;

      return differences[_unitNames[unit]!];
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
