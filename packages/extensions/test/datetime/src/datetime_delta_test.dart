// test/datetime/src/datetime_delta_test.dart
//
// Also exercises the private `_DateTimeDifference` part through
// [DateTimeDelta.delta].

import 'package:extensions/datetime/src/datetime_delta.dart'
    show DateTimeDelta;
import 'package:extensions/datetime/src/datetime_unit.dart' show DateTimeUnit;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeDelta.delta argument validation', () {
    test('throws ArgumentError for a non-UTC startTime', () {
      expect(
        () => DateTimeDelta.delta(startTime: DateTime(2024)),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for a non-UTC endTime', () {
      expect(
        () => DateTimeDelta.delta(
          startTime: DateTime.utc(2024),
          endTime: DateTime(2024, 2),
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError when firstDateTimeUnit is finer than '
        'precision', () {
      expect(
        () => DateTimeDelta.delta(
          startTime: DateTime.utc(2024),
          endTime: DateTime.utc(2024, 2),
          firstDateTimeUnit: DateTimeUnit.second,
          precision: DateTimeUnit.minute,
        ),
        throwsArgumentError,
      );
    });
  });

  group('DateTimeDelta.delta computation', () {
    test('returns an empty future delta for the same moment', () {
      final instant = DateTime.utc(2024, 5, 10);
      final delta = DateTimeDelta.delta(startTime: instant, endTime: instant);
      expect(delta, const DateTimeDelta(isFuture: true));
      expect(delta.toString(), '0');
    });

    test('computes a straight component-wise difference', () {
      final delta = DateTimeDelta.delta(
        startTime: DateTime.utc(2020, 1, 15, 10, 30, 45, 500, 250),
        endTime: DateTime.utc(2023, 3, 20, 14, 45, 50, 700, 400),
        precision: DateTimeUnit.usec,
      );
      expect(
        delta,
        const DateTimeDelta(
          isFuture: true,
          years: 3,
          months: 2,
          days: 5,
          hours: 4,
          minutes: 15,
          seconds: 5,
          milliseconds: 200,
          microseconds: 150,
        ),
      );
    });

    test('borrows through every unit across a year boundary', () {
      final delta = DateTimeDelta.delta(
        startTime: DateTime.utc(2023, 12, 31, 23, 59, 59, 999, 999),
        endTime: DateTime.utc(2024),
        precision: DateTimeUnit.usec,
      );
      expect(
        delta,
        const DateTimeDelta(
          isFuture: true,
          years: 0,
          months: 0,
          days: 0,
          hours: 0,
          minutes: 0,
          seconds: 0,
          milliseconds: 0,
          microseconds: 1,
        ),
      );
    });

    test('borrows days from the previous month length', () {
      final delta = DateTimeDelta.delta(
        startTime: DateTime.utc(2024, 1, 10),
        endTime: DateTime.utc(2024, 3, 5),
      );
      // Day borrow pulls Feb 2024's 29 days: 1 month, 24 days.
      expect(delta.years, 0);
      expect(delta.months, 1);
      expect(delta.days, 24);
    });

    test('swaps operands and reports isFuture false when start is after '
        'end', () {
      final delta = DateTimeDelta.delta(
        startTime: DateTime.utc(2024, 3),
        endTime: DateTime.utc(2024, 1),
      );
      expect(delta.isFuture, isFalse);
      expect(delta.months, 2);
    });

    test('defaults endTime to now in UTC', () {
      final delta = DateTimeDelta.delta(
        startTime: DateTime.now().toUtc().subtract(const Duration(hours: 2)),
      );
      expect(delta.isFuture, isTrue);
      expect(delta.hours, 2);
    });

    test('firstDateTimeUnit nulls out coarser units', () {
      final delta = DateTimeDelta.delta(
        startTime: DateTime.utc(2020, 1, 15, 10),
        endTime: DateTime.utc(2023, 3, 20, 14),
        firstDateTimeUnit: DateTimeUnit.day,
      );
      expect(delta.years, isNull);
      expect(delta.months, isNull);
      expect(delta.days, 5);
      expect(delta.hours, 4);
    });

    test('truncate true zeroes units finer than precision', () {
      final delta = DateTimeDelta.delta(
        startTime: DateTime.utc(2024, 1, 1, 10, 0, 30, 500),
        endTime: DateTime.utc(2024, 1, 1, 11, 30, 45, 700),
        precision: DateTimeUnit.minute,
      );
      expect(delta.hours, 1);
      expect(delta.minutes, 30);
      expect(delta.seconds, 0);
      expect(delta.milliseconds, 0);
      expect(delta.microseconds, 0);
    });

    test('truncate false nulls units finer than precision', () {
      final delta = DateTimeDelta.delta(
        startTime: DateTime.utc(2024, 1, 1, 10),
        endTime: DateTime.utc(2024, 1, 1, 11, 30),
        precision: DateTimeUnit.minute,
        truncate: false,
      );
      expect(delta.minutes, 30);
      expect(delta.seconds, isNull);
      expect(delta.milliseconds, isNull);
      expect(delta.microseconds, isNull);
    });
  });

  group('DateTimeDelta.toString', () {
    test('joins every non-zero component with its unit suffix', () {
      const delta = DateTimeDelta(
        isFuture: true,
        years: 1,
        months: 2,
        days: 3,
        hours: 4,
        minutes: 5,
        seconds: 6,
        milliseconds: 7,
        microseconds: 8,
      );
      expect(delta.toString(), '1y 2mo 3d 4h 5m 6s 7ms 8μs');
    });

    test('prefixes a minus sign for a past delta', () {
      const delta = DateTimeDelta(isFuture: false, hours: 1, minutes: 20);
      expect(delta.toString(), '-1h 20m');
    });

    test('renders 0 when every component is zero or null', () {
      const allZero = DateTimeDelta(
        isFuture: true,
        years: 0,
        months: 0,
        days: 0,
        hours: 0,
        minutes: 0,
        seconds: 0,
        milliseconds: 0,
        microseconds: 0,
      );
      expect(allZero.toString(), '0');
      expect(const DateTimeDelta(isFuture: false).toString(), '0');
    });
  });

  group('DateTimeDelta equality', () {
    const a = DateTimeDelta(isFuture: true, years: 1, days: 2);
    const b = DateTimeDelta(isFuture: true, years: 1, days: 2);
    const c = DateTimeDelta(isFuture: true, years: 1, days: 3);

    test('identical instances are equal', () {
      expect(a == a, isTrue);
    });

    test('field-wise equal instances are equal with matching hashCodes', () {
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('differing fields break equality', () {
      expect(a == c, isFalse);
      expect(
        a == const DateTimeDelta(isFuture: false, years: 1, days: 2),
        isFalse,
      );
    });

    test('a non-DateTimeDelta is never equal', () {
      expect(a == Object(), isFalse);
    });
  });
}
