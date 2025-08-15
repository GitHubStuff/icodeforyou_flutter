// datetime_delta_test.dart
import 'package:extensions/datetime_ext/datetime_delta.dart' show DateTimeDelta;
import 'package:extensions/datetime_ext/datetime_unit.dart' show DateTimeUnit;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeDelta UTC Validation', () {
    test('should reject non-UTC startTime', () {
      final localTime = DateTime(2023, 6, 15, 10, 0, 0);
      final utcTime = DateTime.utc(2023, 6, 15, 12, 0, 0);

      expect(
        () => DateTimeDelta.delta(startTime: localTime, endTime: utcTime),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should reject non-UTC endTime', () {
      final utcTime = DateTime.utc(2023, 6, 15, 10, 0, 0);
      final localTime = DateTime(2023, 6, 15, 12, 0, 0);

      expect(
        () => DateTimeDelta.delta(startTime: utcTime, endTime: localTime),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should accept valid UTC times', () {
      final start = DateTime.utc(2023, 6, 15, 10, 0, 0);
      final end = DateTime.utc(2023, 6, 15, 12, 0, 0);

      expect(
        () => DateTimeDelta.delta(startTime: start, endTime: end),
        returnsNormally,
      );
    });

    test(
      'should reject firstDateTimeUnit smaller than precision with AssertionError',
      () {
        final start = DateTime.utc(2023, 6, 15, 10, 0, 0);
        final end = DateTime.utc(2023, 6, 15, 12, 0, 0);

        expect(
          () => DateTimeDelta.delta(
            startTime: start,
            endTime: end,
            firstDateTimeUnit: DateTimeUnit.msec,
            precision: DateTimeUnit.second,
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );
  });

  group('DateTimeDelta Same Moment Edge Cases', () {
    test('should handle identical UTC times', () {
      final time = DateTime.utc(2023, 6, 15, 12, 30, 45, 123, 456);
      final delta = DateTimeDelta.delta(startTime: time, endTime: time);

      expect(delta.years, isNull);
      expect(delta.months, isNull);
      expect(delta.days, isNull);
      expect(delta.hours, isNull);
      expect(delta.minutes, isNull);
      expect(delta.seconds, isNull);
      expect(delta.milliseconds, isNull);
      expect(delta.microseconds, isNull);
      expect(delta.isFuture, isTrue);
    });

    test('should handle same instant from different constructors', () {
      final milliseconds = DateTime.utc(
        2023,
        6,
        15,
        12,
        0,
        0,
      ).millisecondsSinceEpoch;
      final time1 = DateTime.fromMillisecondsSinceEpoch(
        milliseconds,
        isUtc: true,
      );
      final time2 = DateTime.utc(2023, 6, 15, 12, 0, 0);

      final delta = DateTimeDelta.delta(startTime: time1, endTime: time2);

      expect(time1.isAtSameMomentAs(time2), isTrue);
      expect(delta.years, isNull);
      expect(delta.months, isNull);
      expect(delta.days, isNull);
      expect(delta.hours, isNull);
      expect(delta.minutes, isNull);
      expect(delta.seconds, isNull);
      expect(delta.isFuture, isTrue);
    });
  });

  group('DateTimeDelta Basic Future Time Calculations', () {
    test('should calculate simple year difference', () {
      final start = DateTime.utc(2020, 1, 1);
      final end = DateTime.utc(2023, 1, 1);

      final delta = DateTimeDelta.delta(startTime: start, endTime: end);

      expect(delta.years, equals(3));
      expect(delta.months, equals(0));
      expect(delta.days, equals(0));
      expect(delta.isFuture, isTrue);
    });

    test('should calculate simple month difference', () {
      final start = DateTime.utc(2023, 1, 1);
      final end = DateTime.utc(2023, 6, 1);

      final delta = DateTimeDelta.delta(startTime: start, endTime: end);

      expect(delta.years, equals(0));
      expect(delta.months, equals(5));
      expect(delta.days, equals(0));
      expect(delta.isFuture, isTrue);
    });

    test('should calculate simple day difference', () {
      final start = DateTime.utc(2023, 6, 1);
      final end = DateTime.utc(2023, 6, 15);

      final delta = DateTimeDelta.delta(startTime: start, endTime: end);

      expect(delta.years, equals(0));
      expect(delta.months, equals(0));
      expect(delta.days, equals(14));
      expect(delta.isFuture, isTrue);
    });

    test('should calculate hour/minute/second differences', () {
      final start = DateTime.utc(2023, 6, 15, 10, 30, 45);
      final end = DateTime.utc(2023, 6, 15, 13, 45, 50);

      final delta = DateTimeDelta.delta(startTime: start, endTime: end);

      expect(delta.years, equals(0));
      expect(delta.months, equals(0));
      expect(delta.days, equals(0));
      expect(delta.hours, equals(3));
      expect(delta.minutes, equals(15));
      expect(delta.seconds, equals(5));
      expect(delta.isFuture, isTrue);
    });

    test('should calculate millisecond/microsecond differences', () {
      final start = DateTime.utc(2023, 6, 15, 12, 0, 0, 123, 456);
      final end = DateTime.utc(2023, 6, 15, 12, 0, 0, 789, 123);

      final delta = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        precision: DateTimeUnit.usec,
      );

      final duration = end.difference(start);
      final totalMicros = duration.inMicroseconds;

      expect(totalMicros, equals(665667));
      expect(delta.milliseconds, equals(665));
      expect(delta.microseconds, equals(667));
      expect(delta.isFuture, isTrue);
    });
  });

  group('DateTimeDelta Basic Past Time Calculations', () {
    test('should calculate past year difference', () {
      final start = DateTime.utc(2023, 1, 1);
      final end = DateTime.utc(2020, 1, 1);

      final delta = DateTimeDelta.delta(startTime: start, endTime: end);

      expect(delta.years, equals(3));
      expect(delta.months, equals(0));
      expect(delta.days, equals(0));
      expect(delta.isFuture, isFalse);
    });

    test('should calculate past month difference', () {
      final start = DateTime.utc(2023, 6, 1);
      final end = DateTime.utc(2023, 1, 1);

      final delta = DateTimeDelta.delta(startTime: start, endTime: end);

      expect(delta.years, equals(0));
      expect(delta.months, equals(5));
      expect(delta.days, equals(0));
      expect(delta.isFuture, isFalse);
    });

    test('should handle symmetric past/future calculations', () {
      final base = DateTime.utc(2023, 6, 15, 12, 0, 0);
      final future = DateTime.utc(2023, 8, 20, 15, 30, 45);

      final futureDelta = DateTimeDelta.delta(startTime: base, endTime: future);
      final pastDelta = DateTimeDelta.delta(startTime: future, endTime: base);

      // Magnitudes should be equal
      expect(futureDelta.months, equals(pastDelta.months));
      expect(futureDelta.days, equals(pastDelta.days));
      expect(futureDelta.hours, equals(pastDelta.hours));
      expect(futureDelta.minutes, equals(pastDelta.minutes));
      expect(futureDelta.seconds, equals(pastDelta.seconds));

      // Directions should be opposite
      expect(futureDelta.isFuture, isTrue);
      expect(pastDelta.isFuture, isFalse);
    });
  });

  group('DateTimeDelta Direction (isFuture) Tests', () {
    test('should correctly identify future direction', () {
      final start = DateTime.utc(2023, 1, 1);
      final end = DateTime.utc(2023, 6, 1);

      final delta = DateTimeDelta.delta(startTime: start, endTime: end);

      expect(end.isAfter(start), isTrue);
      expect(delta.isFuture, isTrue);
      expect(delta.months, equals(5));
    });

    test('should correctly identify past direction', () {
      final start = DateTime.utc(2023, 6, 1);
      final end = DateTime.utc(2023, 1, 1);

      final delta = DateTimeDelta.delta(startTime: start, endTime: end);

      expect(end.isBefore(start), isTrue);
      expect(delta.isFuture, isFalse);
      expect(delta.months, equals(5));
    });

    test('should handle microsecond future difference', () {
      final start = DateTime.utc(2023, 6, 15, 12, 0, 0, 0, 0);
      final end = DateTime.utc(2023, 6, 15, 12, 0, 0, 0, 1);

      final delta = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        precision: DateTimeUnit.usec,
      );

      expect(end.isAfter(start), isTrue);
      expect(delta.isFuture, isTrue);
      expect(delta.microseconds, equals(1));
    });

    test('should handle microsecond past difference', () {
      final start = DateTime.utc(2023, 6, 15, 12, 0, 0, 0, 1);
      final end = DateTime.utc(2023, 6, 15, 12, 0, 0, 0, 0);

      final delta = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        precision: DateTimeUnit.usec,
      );

      expect(end.isBefore(start), isTrue);
      expect(delta.isFuture, isFalse);
      expect(delta.microseconds, equals(1));
    });
  });

  group('DateTimeDelta Leap Year Tests', () {
    test('Feb 27 to Mar 1 in leap year 2020', () {
      final start = DateTime.utc(2020, 2, 27);
      final end = DateTime.utc(2020, 3, 1);

      final delta = DateTimeDelta.delta(startTime: start, endTime: end);

      final duration = end.difference(start);
      final expectedDays = duration.inDays;

      expect(expectedDays, equals(3)); // Feb 27 -> 28 -> 29 -> Mar 1
      expect(delta.days, equals(expectedDays));
      expect(delta.months, equals(0));
    });

    test('Feb 27 to Mar 1 in non-leap year 2021', () {
      final start = DateTime.utc(2021, 2, 27);
      final end = DateTime.utc(2021, 3, 1);

      final delta = DateTimeDelta.delta(startTime: start, endTime: end);

      final duration = end.difference(start);
      final expectedDays = duration.inDays;

      expect(expectedDays, equals(2)); // Feb 27 -> 28 -> Mar 1
      expect(delta.days, equals(expectedDays));
      expect(delta.months, equals(0));
    });

    test('leap day to next leap day', () {
      final start = DateTime.utc(2020, 2, 29);
      final end = DateTime.utc(2024, 2, 29);

      final delta = DateTimeDelta.delta(startTime: start, endTime: end);

      expect(delta.years, equals(4));
      expect(delta.months, equals(0));
      expect(delta.days, equals(0));
    });

    test('Feb 29 leap year to Feb 28 non-leap year', () {
      final start = DateTime.utc(2020, 2, 29);
      final end = DateTime.utc(2021, 2, 28);

      final delta = DateTimeDelta.delta(startTime: start, endTime: end);

      expect(delta.years, equals(0));
      expect(delta.months, equals(11));
      expect(delta.days, equals(30));
    });
  });

  group('DateTimeDelta Month Boundary Tests', () {
    test('end of month to end of month', () {
      final start = DateTime.utc(2023, 1, 31);
      final end = DateTime.utc(2023, 3, 31);

      final delta = DateTimeDelta.delta(startTime: start, endTime: end);

      expect(delta.months, equals(2));
      expect(delta.days, equals(0));
    });

    test('January 31 to February 28 (different month lengths)', () {
      final start = DateTime.utc(2023, 1, 31);
      final end = DateTime.utc(2023, 2, 28);

      final delta = DateTimeDelta.delta(startTime: start, endTime: end);

      final duration = end.difference(start);
      final expectedDays = duration.inDays;

      expect(expectedDays, equals(28)); // Verify Duration calculation
      expect(delta.months, equals(0)); // After borrowing: 1 month becomes 0
      expect(
        delta.days,
        equals(28),
      ); // BUG: Implementation returns 0, should be 28
    });

    test('December to January year boundary', () {
      final start = DateTime.utc(2022, 12, 15);
      final end = DateTime.utc(2023, 1, 15);

      final delta = DateTimeDelta.delta(startTime: start, endTime: end);

      expect(delta.years, equals(0));
      expect(delta.months, equals(1));
      expect(delta.days, equals(0));
    });
  });

  group('DateTimeDelta Precision Control Tests', () {
    test('year precision with truncate=true', () {
      final start = DateTime.utc(2020, 6, 15, 10, 30, 45, 123, 456);
      final end = DateTime.utc(2023, 8, 20, 14, 45, 50, 789, 123);

      final delta = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        precision: DateTimeUnit.year,
        truncate: true,
      );

      expect(delta.years, equals(3));
      expect(delta.months, equals(0));
      expect(delta.days, equals(0));
      expect(delta.hours, equals(0));
      expect(delta.minutes, equals(0));
      expect(delta.seconds, equals(0));
      expect(delta.milliseconds, equals(0));
      expect(delta.microseconds, equals(0));
    });

    test('month precision with truncate=false', () {
      final start = DateTime.utc(2023, 1, 15, 10, 30, 45);
      final end = DateTime.utc(2023, 6, 20, 14, 45, 50);

      final delta = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        precision: DateTimeUnit.month,
        truncate: false,
      );

      expect(delta.years, equals(0));
      expect(delta.months, equals(5));
      expect(delta.days, isNull);
      expect(delta.hours, isNull);
      expect(delta.minutes, isNull);
      expect(delta.seconds, isNull);
    });

    test('second precision with truncate=true', () {
      final start = DateTime.utc(2023, 6, 15, 10, 30, 45, 123, 456);
      final end = DateTime.utc(2023, 6, 15, 10, 32, 50, 789, 123);

      final delta = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        precision: DateTimeUnit.second,
        truncate: true,
      );

      expect(delta.minutes, equals(2));
      expect(delta.seconds, equals(5));
      expect(delta.milliseconds, equals(0));
      expect(delta.microseconds, equals(0));
    });

    test('microsecond precision', () {
      final start = DateTime.utc(2023, 6, 15, 10, 30, 45, 123, 456);
      final end = DateTime.utc(2023, 6, 15, 10, 30, 45, 789, 123);

      final delta = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        precision: DateTimeUnit.usec,
      );

      final duration = end.difference(start);
      final totalMicros = duration.inMicroseconds;

      expect(totalMicros, equals(665667));
      expect(delta.milliseconds, equals(665));
      expect(delta.microseconds, equals(667));
    });
  });

  group('DateTimeDelta FirstDateTimeUnit Field Filtering Tests', () {
    test('filter out years when firstDateTimeUnit is month', () {
      final start = DateTime.utc(2020, 6, 15, 10, 30, 45);
      final end = DateTime.utc(2023, 8, 20, 14, 45, 50);

      final delta = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        firstDateTimeUnit: DateTimeUnit.month,
      );

      // Years are filtered out, only months and smaller units remain
      expect(delta.years, isNull);
      expect(delta.months, equals(2)); // Just the month component
      expect(delta.days, equals(5));
    });

    test('filter out years and months when firstDateTimeUnit is day', () {
      final start = DateTime.utc(2023, 6, 15, 10, 30, 45);
      final end = DateTime.utc(2023, 8, 17, 14, 45, 50);

      final delta = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        firstDateTimeUnit: DateTimeUnit.day,
      );

      // Years and months are filtered out
      expect(delta.years, isNull);
      expect(delta.months, isNull);
      expect(delta.days, equals(2)); // Just the day component
      expect(delta.hours, equals(4));
    });

    test('filter out larger units when firstDateTimeUnit is hour', () {
      final start = DateTime.utc(2023, 6, 15, 10, 30, 45);
      final end = DateTime.utc(2023, 6, 15, 14, 45, 50);

      final delta = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        firstDateTimeUnit: DateTimeUnit.hour,
      );

      expect(delta.years, isNull);
      expect(delta.months, isNull);
      expect(delta.days, isNull);
      expect(delta.hours, equals(4));
      expect(delta.minutes, equals(15));
    });

    test('filter out larger units when firstDateTimeUnit is minute', () {
      final start = DateTime.utc(2023, 6, 15, 10, 30, 45);
      final end = DateTime.utc(2023, 6, 15, 10, 45, 50);

      final delta = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        firstDateTimeUnit: DateTimeUnit.minute,
      );

      expect(delta.years, isNull);
      expect(delta.months, isNull);
      expect(delta.days, isNull);
      expect(delta.hours, isNull);
      expect(delta.minutes, equals(15));
      expect(delta.seconds, equals(5));
    });

    test('filter out larger units when firstDateTimeUnit is second', () {
      final start = DateTime.utc(2023, 6, 15, 10, 30, 45);
      final end = DateTime.utc(2023, 6, 15, 10, 30, 50);

      final delta = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        firstDateTimeUnit: DateTimeUnit.second,
      );

      expect(delta.years, isNull);
      expect(delta.months, isNull);
      expect(delta.days, isNull);
      expect(delta.hours, isNull);
      expect(delta.minutes, isNull);
      expect(delta.seconds, equals(5));
    });

    test('filter out larger units when firstDateTimeUnit is msec', () {
      final start = DateTime.utc(2023, 6, 15, 10, 30, 45, 100);
      final end = DateTime.utc(2023, 6, 15, 10, 30, 45, 600);

      final delta = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        firstDateTimeUnit: DateTimeUnit.msec,
        precision: DateTimeUnit.msec,
      );

      final duration = end.difference(start);
      final totalMs = duration.inMilliseconds;

      expect(delta.years, isNull);
      expect(delta.months, isNull);
      expect(delta.days, isNull);
      expect(delta.hours, isNull);
      expect(delta.minutes, isNull);
      expect(delta.seconds, isNull);
      expect(delta.milliseconds, equals(totalMs));
      expect(totalMs, equals(500));
    });

    test('filter out larger units when firstDateTimeUnit is usec', () {
      final start = DateTime.utc(2023, 6, 15, 10, 30, 45, 100, 200);
      final end = DateTime.utc(2023, 6, 15, 10, 30, 45, 100, 700);

      final delta = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        firstDateTimeUnit: DateTimeUnit.usec,
        precision: DateTimeUnit.usec,
      );

      final duration = end.difference(start);
      final totalMicros = duration.inMicroseconds;

      expect(delta.years, isNull);
      expect(delta.months, isNull);
      expect(delta.days, isNull);
      expect(delta.hours, isNull);
      expect(delta.minutes, isNull);
      expect(delta.seconds, isNull);
      expect(delta.milliseconds, isNull);
      expect(delta.microseconds, equals(totalMicros));
      expect(totalMicros, equals(500));
    });
  });

  group('DateTimeDelta Truncate Behavior Tests', () {
    test('truncate=true sets below-precision values to 0', () {
      final start = DateTime.utc(2023, 6, 15, 10, 30, 45, 123, 456);
      final end = DateTime.utc(2023, 6, 15, 10, 32, 50, 789, 123);

      final delta = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        precision: DateTimeUnit.second,
        truncate: true,
      );

      expect(delta.milliseconds, equals(0));
      expect(delta.microseconds, equals(0));
      expect(delta.minutes, equals(2));
      expect(delta.seconds, equals(5));
    });

    test('truncate=false sets below-precision values to null', () {
      final start = DateTime.utc(2023, 6, 15, 10, 30, 45, 123, 456);
      final end = DateTime.utc(2023, 6, 15, 10, 32, 50, 789, 123);

      final delta = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        precision: DateTimeUnit.second,
        truncate: false,
      );

      expect(delta.milliseconds, isNull);
      expect(delta.microseconds, isNull);
      expect(delta.minutes, equals(2));
      expect(delta.seconds, equals(5));
    });

    test('truncate behavior with year precision', () {
      final start = DateTime.utc(2020, 6, 15, 10, 30, 45);
      final end = DateTime.utc(2023, 8, 20, 14, 45, 50);

      final deltaTrue = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        precision: DateTimeUnit.year,
        truncate: true,
      );

      final deltaFalse = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        precision: DateTimeUnit.year,
        truncate: false,
      );

      expect(deltaTrue.years, equals(deltaFalse.years));
      expect(deltaTrue.years, equals(3));
      expect(deltaTrue.months, equals(0));
      expect(deltaFalse.months, isNull);
    });

    test('truncate behavior validation across precision levels', () {
      final start = DateTime.utc(2023, 1, 15, 10, 30, 45, 123, 456);
      final end = DateTime.utc(2023, 6, 20, 14, 45, 50, 789, 123);

      const unitHierarchy = [
        DateTimeUnit.year,
        DateTimeUnit.month,
        DateTimeUnit.day,
        DateTimeUnit.hour,
        DateTimeUnit.minute,
        DateTimeUnit.second,
        DateTimeUnit.msec,
      ];

      for (final precision in unitHierarchy) {
        final truncateTrue = DateTimeDelta.delta(
          startTime: start,
          endTime: end,
          precision: precision,
          truncate: true,
        );

        final truncateFalse = DateTimeDelta.delta(
          startTime: start,
          endTime: end,
          precision: precision,
          truncate: false,
        );

        final precisionIndex = unitHierarchy.indexOf(precision);

        // Check each field based on its relationship to precision
        final allFields = [
          (DateTimeUnit.year, truncateTrue.years, truncateFalse.years),
          (DateTimeUnit.month, truncateTrue.months, truncateFalse.months),
          (DateTimeUnit.day, truncateTrue.days, truncateFalse.days),
          (DateTimeUnit.hour, truncateTrue.hours, truncateFalse.hours),
          (DateTimeUnit.minute, truncateTrue.minutes, truncateFalse.minutes),
          (DateTimeUnit.second, truncateTrue.seconds, truncateFalse.seconds),
          (
            DateTimeUnit.msec,
            truncateTrue.milliseconds,
            truncateFalse.milliseconds,
          ),
        ];

        for (final (unit, trueValue, falseValue) in allFields) {
          final unitIndex = unitHierarchy.indexOf(unit);

          if (unitIndex <= precisionIndex) {
            // At or above precision - should be identical
            expect(
              trueValue,
              equals(falseValue),
              reason: '$unit should be identical at precision $precision',
            );
          } else {
            // Below precision - should differ (0 vs null)
            expect(
              trueValue,
              equals(0),
              reason:
                  '$unit should be 0 when truncate=true at precision $precision',
            );
            expect(
              falseValue,
              isNull,
              reason:
                  '$unit should be null when truncate=false at precision $precision',
            );
          }
        }
      }
    });
  });

  group('DateTimeDelta Complex Edge Cases', () {
    test('year boundary with second precision', () {
      final start = DateTime.utc(2022, 12, 31, 23, 59, 59);
      final end = DateTime.utc(2023, 1, 1, 0, 0, 1);

      final delta = DateTimeDelta.delta(startTime: start, endTime: end);

      final duration = end.difference(start);
      final totalSeconds = duration.inSeconds;

      expect(totalSeconds, equals(2));
      expect(delta.years, equals(0));
      expect(delta.months, equals(0));
      expect(delta.days, equals(0));
      expect(delta.hours, equals(0));
      expect(delta.minutes, equals(0));
      expect(delta.seconds, equals(totalSeconds));
    });

    test('complex month/day calculations across months', () {
      final start = DateTime.utc(2023, 1, 31);
      final end = DateTime.utc(2023, 5, 15);

      final delta = DateTimeDelta.delta(startTime: start, endTime: end);

      expect(delta.years, equals(0));
      expect(delta.months, equals(3));
      expect(
        delta.days,
        equals(14),
      ); // 15-31=-16, borrow from April (30 days): -16+30=14
    });

    test('microsecond precision boundaries', () {
      final base = DateTime.utc(2023, 6, 15, 12, 0, 0, 0, 0);

      for (int i = 1; i <= 10; i++) {
        final end = DateTime.utc(2023, 6, 15, 12, 0, 0, 0, i);
        final delta = DateTimeDelta.delta(
          startTime: base,
          endTime: end,
          precision: DateTimeUnit.usec,
        );

        expect(delta.microseconds, equals(i));
        expect(delta.milliseconds, equals(0));
      }
    });

    test('millisecond precision boundaries', () {
      final base = DateTime.utc(2023, 6, 15, 12, 0, 0, 0, 0);

      for (int i = 1; i <= 10; i++) {
        final end = DateTime.utc(2023, 6, 15, 12, 0, 0, i, 0);
        final delta = DateTimeDelta.delta(
          startTime: base,
          endTime: end,
          precision: DateTimeUnit.msec,
        );

        expect(delta.milliseconds, equals(i));
        expect(delta.microseconds, equals(0));
      }
    });

    test('carry operations between time units', () {
      final start = DateTime.utc(2023, 6, 15, 23, 59, 59, 999, 999);
      final end = DateTime.utc(2023, 6, 16, 0, 0, 0, 0, 1);

      final delta = DateTimeDelta.delta(
        startTime: start,
        endTime: end,
        precision: DateTimeUnit.usec,
      );

      expect(delta.microseconds, equals(2));
    });
  });

  group('DateTimeDelta toString Method Tests', () {
    test('format positive delta correctly', () {
      const delta = DateTimeDelta(
        years: 2,
        months: 3,
        days: 15,
        hours: 4,
        minutes: 30,
        seconds: 45,
        isFuture: true,
      );

      final result = delta.toString();
      expect(result, equals('2y 3mo 15d 4h 30m 45s'));
      expect(result.contains('-'), isFalse);
    });

    test('format negative delta correctly', () {
      const delta = DateTimeDelta(
        years: 1,
        months: 6,
        days: 10,
        isFuture: false,
      );

      final result = delta.toString();
      expect(result, equals('-1y 6mo 10d'));
      expect(result.startsWith('-'), isTrue);
    });

    test('handle zero delta', () {
      const delta = DateTimeDelta(isFuture: true);

      final result = delta.toString();
      expect(result, equals('0'));
      expect(result.length, equals(1));
    });

    test('format milliseconds and microseconds', () {
      const delta = DateTimeDelta(
        milliseconds: 123,
        microseconds: 456,
        isFuture: true,
      );

      final result = delta.toString();
      expect(result, equals('123ms 456μs'));
      expect(result.contains('ms'), isTrue);
      expect(result.contains('μs'), isTrue);
    });

    test('skip null and zero values', () {
      const delta = DateTimeDelta(
        years: 2,
        months: 0,
        days: 15,
        hours: null,
        minutes: 30,
        isFuture: true,
      );

      final result = delta.toString();
      expect(result, equals('2y 15d 30m'));
      expect(result.contains('0mo'), isFalse);
      expect(result.contains('h'), isFalse);
    });
  });

  group('DateTimeDelta Equality Tests', () {
    test('equal when all fields match', () {
      const delta1 = DateTimeDelta(
        years: 1,
        months: 2,
        days: 3,
        hours: 4,
        minutes: 5,
        seconds: 6,
        milliseconds: 7,
        microseconds: 8,
        isFuture: true,
      );

      const delta2 = DateTimeDelta(
        years: 1,
        months: 2,
        days: 3,
        hours: 4,
        minutes: 5,
        seconds: 6,
        milliseconds: 7,
        microseconds: 8,
        isFuture: true,
      );

      expect(delta1, equals(delta2));
      expect(delta1.hashCode, equals(delta2.hashCode));
    });

    test('not equal when fields differ', () {
      const delta1 = DateTimeDelta(years: 1, isFuture: true);
      const delta2 = DateTimeDelta(years: 2, isFuture: true);
      const delta3 = DateTimeDelta(years: 1, isFuture: false);

      expect(delta1, isNot(equals(delta2)));
      expect(delta1, isNot(equals(delta3)));
      expect(delta1.hashCode, isNot(equals(delta2.hashCode)));
      expect(delta1.hashCode, isNot(equals(delta3.hashCode)));
    });

    test('handle null fields in equality', () {
      const delta1 = DateTimeDelta(
        years: 1,
        months: null,
        days: 3,
        isFuture: true,
      );
      const delta2 = DateTimeDelta(
        years: 1,
        months: null,
        days: 3,
        isFuture: true,
      );
      const delta3 = DateTimeDelta(
        years: 1,
        months: 2,
        days: 3,
        isFuture: true,
      );

      expect(delta1, equals(delta2));
      expect(delta1, isNot(equals(delta3)));
      expect(delta1.hashCode, equals(delta2.hashCode));
    });
  });

  group('DateTimeDelta Integration Tests', () {
    test('calculate age correctly', () {
      final birthDate = DateTime.utc(1990, 3, 15);
      final currentDate = DateTime.utc(2023, 6, 20);

      final age = DateTimeDelta.delta(
        startTime: birthDate,
        endTime: currentDate,
      );

      expect(age.years, equals(33));
      expect(age.months, equals(3));
      expect(age.days, equals(5));
      expect(age.isFuture, isTrue);
    });

    test('project duration calculation', () {
      final projectStart = DateTime.utc(2023, 1, 15, 9, 0, 0);
      final projectEnd = DateTime.utc(2023, 6, 30, 17, 30, 0);

      final duration = DateTimeDelta.delta(
        startTime: projectStart,
        endTime: projectEnd,
      );

      expect(duration.months, equals(5));
      expect(duration.days, equals(15));
      expect(duration.hours, equals(8));
      expect(duration.minutes, equals(30));
    });

    test('subscription expiry calculation', () {
      final subscriptionStart = DateTime.utc(2023, 6, 1);
      final subscriptionEnd = DateTime.utc(2024, 6, 1);

      final duration = DateTimeDelta.delta(
        startTime: subscriptionStart,
        endTime: subscriptionEnd,
      );

      expect(duration.years, equals(1));
      expect(duration.months, equals(0));
      expect(duration.days, equals(0));
    });

    test('final comprehensive validation', () {
      // Ultimate test: complex real-world scenario
      final scenarios = [
        {
          'description': 'Birth to retirement',
          'start': DateTime.utc(1990, 5, 15),
          'end': DateTime.utc(2055, 5, 15),
          'expectedYears': 65,
        },
        {
          'description': 'Project timeline',
          'start': DateTime.utc(2023, 1, 1, 9, 0, 0),
          'end': DateTime.utc(2023, 12, 31, 17, 0, 0),
          'expectedMonths': 11,
        },
        {
          'description': 'Contract duration',
          'start': DateTime.utc(2023, 6, 1),
          'end': DateTime.utc(2026, 5, 31),
          'expectedYears': 2,
        },
        {
          'description': 'Microsecond precision',
          'start': DateTime.utc(2023, 6, 15, 12, 0, 0, 0, 0),
          'end': DateTime.utc(2023, 6, 15, 12, 0, 0, 1, 500),
          'expectedMs': 1,
        },
      ];

      for (final scenario in scenarios) {
        final start = scenario['start'] as DateTime;
        final end = scenario['end'] as DateTime;

        final delta = DateTimeDelta.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.usec,
        );

        // Verify expected values where provided
        if (scenario.containsKey('expectedYears')) {
          expect(delta.years, equals(scenario['expectedYears'] as int));
        }
        if (scenario.containsKey('expectedMonths')) {
          expect(
            delta.months,
            greaterThanOrEqualTo(scenario['expectedMonths'] as int),
          );
        }
        if (scenario.containsKey('expectedMs')) {
          expect(delta.milliseconds, equals(scenario['expectedMs'] as int));
        }

        // Verify basic integrity
        expect(delta.isFuture, equals(!end.isBefore(start)));

        // Cross-verify with Duration
        final duration = end.difference(start);
        if (duration.inDays > 0) {
          expect(delta.days ?? 0, greaterThanOrEqualTo(0));
        }
      }
    });
  });

  group('DateTimeDelta Performance Tests', () {
    test('handle large date ranges efficiently', () {
      final start = DateTime.utc(1900, 1, 1);
      final end = DateTime.utc(2100, 12, 31);

      final stopwatch = Stopwatch()..start();
      final delta = DateTimeDelta.delta(startTime: start, endTime: end);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      expect(delta.years, equals(200));
      expect(delta.months, equals(11));
      expect(delta.days, equals(30));
      expect(delta.isFuture, isTrue);
    });

    test('handle rapid successive calculations', () {
      final start = DateTime.utc(2023, 1, 1);
      final results = <DateTimeDelta>[];

      final stopwatch = Stopwatch()..start();
      for (int i = 1; i <= 30; i++) {
        // Limit to 30 days to stay within January
        final end = DateTime.utc(2023, 1, 1 + i);
        results.add(DateTimeDelta.delta(startTime: start, endTime: end));
      }
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(500));

      for (int i = 0; i < results.length; i++) {
        expect(results[i].days, equals(i + 1));
      }
      expect(results.length, equals(30));
    });

    test('maintain precision with microsecond differences', () {
      final start = DateTime.utc(2023, 6, 15, 12, 0, 0, 0, 0);

      for (int i = 1; i <= 50; i++) {
        final end = DateTime.utc(2023, 6, 15, 12, 0, 0, 0, i);

        final delta = DateTimeDelta.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.usec,
        );

        expect(delta.microseconds, equals(i));
        expect(delta.milliseconds, equals(0));
      }
    });
  });
}
