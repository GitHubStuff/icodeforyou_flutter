// extensions/lib/src/datetime_delta.dart
import 'package:extensions/datetime_ext/datetime_unit.dart';
import 'package:flutter/foundation.dart' show immutable;

part '_datetime_difference.dart';

/// Immutable representation of the time delta between two [DateTime] objects.
///
/// Each field is nullable — a `null` value indicates that unit was outside
/// the requested [DateTimeUnit] range or precision.
@immutable
class DateTimeDelta {
  /// Creates a [DateTimeDelta] with the given time components.
  ///
  /// [isFuture] tests whether startTime is before endTime.
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

  /// The year component of the delta, or `null` if outside the requested range.
  final int? years;

  /// The month component of the delta, or `null` if outside the requested
  /// range.
  final int? months;

  /// The day component of the delta, or `null` if outside the requested range.
  final int? days;

  /// The hour component of the delta, or `null` if outside the requested range.
  final int? hours;

  /// The minute component of the delta, or `null` if outside the requested
  /// range.
  final int? minutes;

  /// The second component of the delta, or `null` if outside the requested
  /// range.
  final int? seconds;

  /// The millisecond component of the delta, or `null` if outside the
  /// requested range.
  final int? milliseconds;

  /// The microsecond component of the delta, or `null` if outside the
  /// requested range.
  final int? microseconds;

  /// Whether startTime precedes endTime (i.e. the delta is in the future).
  final bool isFuture;

  /// Calculates the time delta between [startTime] and an optional [endTime].
  ///
  /// Both [startTime] and [endTime] must be UTC — call [DateTime.toUtc]
  /// if needed.
  ///
  /// [firstDateTimeUnit] sets the largest unit to compute.
  /// [precision] sets the smallest unit to compute.
  /// [truncate] controls whether sub-precision remainders are discarded.
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

  /// Returns a human-readable string of the non-zero components,
  /// prefixed with `-` when [isFuture] is `false`.
  ///
  /// Example: `2y 3mo 5d` or `-1h 20m`.
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
      // ignore: unnecessary_brace_in_string_interps document_ignores
      parts.add('${microseconds}μs');
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
