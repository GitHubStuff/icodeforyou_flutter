//datetime_delta_birthday_test.dart

import 'package:extensions/datetime_ext/datetime_delta.dart' show DateTimeDelta;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime birthday = DateTime(1960, 12, 19, 15, 56, 0).toUtc();

  group('DateTimeDelta Birthday Validation', () {
    test('Birth day', () {
      final dateTimeDelta = DateTimeDelta.delta(
        startTime: birthday,
        endTime: birthday,
      );
      expect(dateTimeDelta.years, isNull);
      expect(dateTimeDelta.months, isNull);
      expect(dateTimeDelta.days, isNull);
      expect(dateTimeDelta.hours, isNull);
      expect(dateTimeDelta.minutes, isNull);
      expect(dateTimeDelta.seconds, isNull);
      expect(dateTimeDelta.milliseconds, isNull);
      expect(dateTimeDelta.microseconds, isNull);
      expect(dateTimeDelta.isFuture, true);
    });

    test('Birth day + 1 minute', () {
      final DateTime oneMinute = DateTime(1960, 12, 19, 15, 57, 0).toUtc();
      final dateTimeDelta = DateTimeDelta.delta(
        startTime: birthday,
        endTime: oneMinute,
      );
      expect(dateTimeDelta.years, 0);
      expect(dateTimeDelta.months, 0);
      expect(dateTimeDelta.days, 0);
      expect(dateTimeDelta.hours, 0);
      expect(dateTimeDelta.minutes, 1);
      expect(dateTimeDelta.seconds, 0);
      expect(dateTimeDelta.milliseconds, 0);
      expect(dateTimeDelta.microseconds, 0);
      expect(dateTimeDelta.isFuture, true);
    });
    test('Birth day + 1 hour', () {
      final DateTime oneHour = DateTime(1960, 12, 19, 16, 56, 0).toUtc();
      final dateTimeDelta = DateTimeDelta.delta(
        startTime: birthday,
        endTime: oneHour,
      );
      expect(dateTimeDelta.years, 0);
      expect(dateTimeDelta.months, 0);
      expect(dateTimeDelta.days, 0);
      expect(dateTimeDelta.hours, 1);
      expect(dateTimeDelta.minutes, 0);
      expect(dateTimeDelta.seconds, 0);
      expect(dateTimeDelta.milliseconds, 0);
      expect(dateTimeDelta.microseconds, 0);
      expect(dateTimeDelta.isFuture, true);
    });

    test('Birth day + 64yrs', () {
      final DateTime sixtyfourYears = DateTime(2024, 12, 19, 15, 56, 0).toUtc();
      final dateTimeDelta = DateTimeDelta.delta(
        startTime: birthday,
        endTime: sixtyfourYears,
      );
      expect(dateTimeDelta.years, 64);
      expect(dateTimeDelta.months, 0);
      expect(dateTimeDelta.days, 0);
      expect(dateTimeDelta.hours, 0);
      expect(dateTimeDelta.minutes, 0);
      expect(dateTimeDelta.seconds, 0);
      expect(dateTimeDelta.milliseconds, 0);
      expect(dateTimeDelta.microseconds, 0);
      expect(dateTimeDelta.isFuture, true);
    });


  });
}
