// lib/src/datetime_delta.dart

import 'package:extensions/datetime_ext/datetime_unit.dart';
import 'package:flutter/foundation.dart' show immutable;

part '_datetime_difference.dart';

/// Immutable class representing a time delta between two DateTime objects.
@immutable
class DateTimeDelta {
  const DateTimeDelta({
    required this.isFuture,
    this.years,
    this.months,
    this.days,
    this.hours,
    this.minutes,
    this.seconds,
    this.milliseconds,
    this.microseconds,
  });

  final int? years;
  final int? months;
  final int? days;
  final int? hours;
  final int? minutes;
  final int? seconds;
  final int? milliseconds;
  final int? microseconds;
  final bool isFuture;

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
