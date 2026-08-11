// test/datetime/src/datetime_unit_test.dart

import 'package:extensions/datetime/src/datetime_unit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeUnit constants', () {
    test('carry the calendar conversion values', () {
      expect(DateTimeUnit.kMonthsPerYear, 12);
      expect(DateTimeUnit.kHoursPerDay, 24);
      expect(DateTimeUnit.kMinutesPerHour, 60);
      expect(DateTimeUnit.kSecondsPerMinute, 60);
      expect(DateTimeUnit.kMsecPerSecond, 1000);
      expect(DateTimeUnit.kUsecPerMsec, 1000);
      expect(DateTimeUnit.kDaysPlaceholder, 0);
    });

    test('carry the per-month day counts', () {
      expect(DateTimeUnit.kDaysJanuary, 31);
      expect(DateTimeUnit.kDaysFebruary, 28);
      expect(DateTimeUnit.kDaysFebruaryLeap, 29);
      expect(DateTimeUnit.kDaysMarch, 31);
      expect(DateTimeUnit.kDaysApril, 30);
      expect(DateTimeUnit.kDaysMay, 31);
      expect(DateTimeUnit.kDaysJune, 30);
      expect(DateTimeUnit.kDaysJuly, 31);
      expect(DateTimeUnit.kDaysAugust, 31);
      expect(DateTimeUnit.kDaysSeptember, 30);
      expect(DateTimeUnit.kDaysOctober, 31);
      expect(DateTimeUnit.kDaysNovember, 30);
      expect(DateTimeUnit.kDaysDecember, 31);
    });
  });

  group('DateTimeUnit.makeLocal', () {
    test('converts a provided UTC instant to local, second precision', () {
      final source = DateTime.utc(2024, 5, 10, 12, 30, 45, 500, 250);
      final result = DateTimeUnit.makeLocal(source);
      expect(result.isUtc, isFalse);
      expect(result.millisecond, 0);
      expect(result.microsecond, 0);
      expect(
        result,
        source.toLocal().truncate(atDateTimeUnit: DateTimeUnit.second),
      );
    });

    test('defaults to now when the instant is null', () {
      final before = DateTime.now();
      final result = DateTimeUnit.makeLocal(null);
      final after = DateTime.now();
      expect(result.isUtc, isFalse);
      expect(result.millisecond, 0);
      expect(result.microsecond, 0);
      expect(
        result.isAfter(before.subtract(const Duration(seconds: 2))),
        isTrue,
      );
      expect(result.isBefore(after.add(const Duration(seconds: 2))), isTrue);
    });

    test('honors a coarser truncation unit', () {
      final source = DateTime.utc(2024, 5, 10, 12, 30, 45);
      final result = DateTimeUnit.makeLocal(
        source,
        truncateAt: DateTimeUnit.day,
      );
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
    });
  });

  group('DateTimeUnit.makeUtc', () {
    test('converts a provided local instant to UTC, second precision', () {
      final source = DateTime(2024, 5, 10, 12, 30, 45, 500, 250);
      final result = DateTimeUnit.makeUtc(source);
      expect(result.isUtc, isTrue);
      expect(result.millisecond, 0);
      expect(result.microsecond, 0);
      expect(
        result,
        source.toUtc().truncate(atDateTimeUnit: DateTimeUnit.second),
      );
    });

    test('defaults to now when the instant is null', () {
      final result = DateTimeUnit.makeUtc(null);
      expect(result.isUtc, isTrue);
      expect(result.millisecond, 0);
      expect(result.microsecond, 0);
    });
  });

  group('DateTimeUnit.next', () {
    test('steps through the hierarchy in ascending precision order', () {
      expect(DateTimeUnit.year.next, DateTimeUnit.month);
      expect(DateTimeUnit.month.next, DateTimeUnit.day);
      expect(DateTimeUnit.day.next, DateTimeUnit.hour);
      expect(DateTimeUnit.hour.next, DateTimeUnit.minute);
      expect(DateTimeUnit.minute.next, DateTimeUnit.second);
      expect(DateTimeUnit.second.next, DateTimeUnit.msec);
      expect(DateTimeUnit.msec.next, DateTimeUnit.usec);
    });

    test('returns null for the finest unit', () {
      expect(DateTimeUnit.usec.next, isNull);
    });
  });

  group('DateTimeUnit.sublist', () {
    test('returns this unit through usec inclusive', () {
      expect(DateTimeUnit.second.sublist(), {
        DateTimeUnit.second,
        DateTimeUnit.msec,
        DateTimeUnit.usec,
      });
    });

    test('returns all units from year', () {
      expect(DateTimeUnit.year.sublist(), DateTimeUnit.values.toSet());
    });

    test('returns only usec from usec', () {
      expect(DateTimeUnit.usec.sublist(), {DateTimeUnit.usec});
    });
  });

  group('DateTimeExtensions.truncate', () {
    final utc = DateTime.utc(2024, 5, 10, 12, 30, 45, 500, 250);

    test('truncates to each unit, preserving UTC', () {
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.year),
        DateTime.utc(2024),
      );
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.month),
        DateTime.utc(2024, 5),
      );
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.day),
        DateTime.utc(2024, 5, 10),
      );
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.hour),
        DateTime.utc(2024, 5, 10, 12),
      );
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.minute),
        DateTime.utc(2024, 5, 10, 12, 30),
      );
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.second),
        DateTime.utc(2024, 5, 10, 12, 30, 45),
      );
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.msec),
        DateTime.utc(2024, 5, 10, 12, 30, 45, 500),
      );
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.usec),
        DateTime.utc(2024, 5, 10, 12, 30, 45, 500, 250),
      );
    });

    test('preserves local time zone', () {
      final local = DateTime(2024, 5, 10, 12, 30, 45, 500, 250);
      final result = local.truncate(atDateTimeUnit: DateTimeUnit.minute);
      expect(result.isUtc, isFalse);
      expect(result, DateTime(2024, 5, 10, 12, 30));
    });
  });
}
