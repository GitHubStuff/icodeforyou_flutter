// datetime_unit_test.dart
import 'package:extensions/datetime_ext/datetime_ext.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeUnit', () {
    group('enum values', () {
      test('should contain all expected enum values', () {
        // Arrange & Act
        final values = DateTimeUnit.values;

        // Assert
        expect(values, hasLength(8));
        expect(values, contains(DateTimeUnit.year));
        expect(values, contains(DateTimeUnit.month));
        expect(values, contains(DateTimeUnit.day));
        expect(values, contains(DateTimeUnit.hour));
        expect(values, contains(DateTimeUnit.minute));
        expect(values, contains(DateTimeUnit.second));
        expect(values, contains(DateTimeUnit.msec));
        expect(values, contains(DateTimeUnit.usec));
      });
    });

    group('constants', () {
      test('should have correct time conversion constants', () {
        // Assert
        expect(DateTimeUnit.kMonthsPerYear, equals(12));
        expect(DateTimeUnit.kHoursPerDay, equals(24));
        expect(DateTimeUnit.kMinutesPerHour, equals(60));
        expect(DateTimeUnit.kSecondsPerMinute, equals(60));
        expect(DateTimeUnit.kMsecPerSecond, equals(1000));
        expect(DateTimeUnit.kUsecPerMsec, equals(1000));
      });

      test('should have correct days per month constants', () {
        // Assert
        expect(DateTimeUnit.kDaysPlaceholder, equals(0));
        expect(DateTimeUnit.kDaysJanuary, equals(31));
        expect(DateTimeUnit.kDaysFebruary, equals(28));
        expect(DateTimeUnit.kDaysFebruaryLeap, equals(29));
        expect(DateTimeUnit.kDaysMarch, equals(31));
        expect(DateTimeUnit.kDaysApril, equals(30));
        expect(DateTimeUnit.kDaysMay, equals(31));
        expect(DateTimeUnit.kDaysJune, equals(30));
        expect(DateTimeUnit.kDaysJuly, equals(31));
        expect(DateTimeUnit.kDaysAugust, equals(31));
        expect(DateTimeUnit.kDaysSeptember, equals(30));
        expect(DateTimeUnit.kDaysOctober, equals(31));
        expect(DateTimeUnit.kDaysNovember, equals(30));
        expect(DateTimeUnit.kDaysDecember, equals(31));
      });
    });

    group('makeLocal', () {
      test(
        'should create local DateTime with default truncateAt when dateTime is null',
        () {
          // Act
          final result = DateTimeUnit.makeLocal(null);

          // Assert
          expect(result.isUtc, isFalse);
          expect(result, isA<DateTime>());
        },
      );

      test(
        'should create local DateTime with custom truncateAt when dateTime is null',
        () {
          // Act
          final result = DateTimeUnit.makeLocal(
            null,
            truncateAt: DateTimeUnit.minute,
          );

          // Assert
          expect(result.isUtc, isFalse);
          expect(result, isA<DateTime>());
        },
      );

      test(
        'should convert provided DateTime to local with default truncateAt',
        () {
          // Arrange
          final inputDateTime = DateTime.utc(
            2023,
            12,
            25,
            14,
            30,
            45,
            123,
            456,
          );

          // Act
          final result = DateTimeUnit.makeLocal(inputDateTime);

          // Assert
          expect(result.isUtc, isFalse);
          expect(result.year, equals(2023));
          expect(result.month, equals(12));
          expect(result.day, equals(25));
        },
      );

      test(
        'should convert provided DateTime to local with custom truncateAt',
        () {
          // Arrange
          final inputDateTime = DateTime.utc(
            2023,
            12,
            25,
            14,
            30,
            45,
            123,
            456,
          );

          // Act
          final result = DateTimeUnit.makeLocal(
            inputDateTime,
            truncateAt: DateTimeUnit.hour,
          );

          // Assert
          expect(result.isUtc, isFalse);
          expect(result.year, equals(2023));
          expect(result.month, equals(12));
          expect(result.day, equals(25));
        },
      );

      test('should handle already local DateTime', () {
        // Arrange
        final localDateTime = DateTime(2023, 12, 25, 14, 30, 45);

        // Act
        final result = DateTimeUnit.makeLocal(localDateTime);

        // Assert
        expect(result.isUtc, isFalse);
        expect(result.year, equals(2023));
        expect(result.month, equals(12));
        expect(result.day, equals(25));
      });
    });

    group('makeUtc', () {
      test(
        'should create UTC DateTime with default truncateAt when dateTime is null',
        () {
          // Act
          final result = DateTimeUnit.makeUtc(null);

          // Assert
          expect(result.isUtc, isTrue);
          expect(result, isA<DateTime>());
        },
      );

      test(
        'should create UTC DateTime with custom truncateAt when dateTime is null',
        () {
          // Act
          final result = DateTimeUnit.makeUtc(
            null,
            truncateAt: DateTimeUnit.minute,
          );

          // Assert
          expect(result.isUtc, isTrue);
          expect(result, isA<DateTime>());
        },
      );

      test(
        'should convert provided DateTime to UTC with default truncateAt',
        () {
          // Arrange
          final inputDateTime = DateTime(2023, 12, 25, 14, 30, 45, 123, 456);

          // Act
          final result = DateTimeUnit.makeUtc(inputDateTime);

          // Assert
          expect(result.isUtc, isTrue);
          expect(result.year, equals(2023));
          expect(result.month, equals(12));
          expect(result.day, equals(25));
        },
      );

      test(
        'should convert provided DateTime to UTC with custom truncateAt',
        () {
          // Arrange
          final inputDateTime = DateTime(2023, 12, 25, 14, 30, 45, 123, 456);

          // Act
          final result = DateTimeUnit.makeUtc(
            inputDateTime,
            truncateAt: DateTimeUnit.day,
          );

          // Assert
          expect(result.isUtc, isTrue);
          expect(result.year, equals(2023));
          expect(result.month, equals(12));
          expect(result.day, equals(25));
        },
      );

      test('should handle already UTC DateTime', () {
        // Arrange
        final utcDateTime = DateTime.utc(2023, 12, 25, 14, 30, 45);

        // Act
        final result = DateTimeUnit.makeUtc(utcDateTime);

        // Assert
        expect(result.isUtc, isTrue);
        expect(result.year, equals(2023));
        expect(result.month, equals(12));
        expect(result.day, equals(25));
      });
    });

    group('next getter', () {
      test('should return next enum value for year', () {
        // Act
        final result = DateTimeUnit.year.next;

        // Assert
        expect(result, equals(DateTimeUnit.month));
      });

      test('should return next enum value for month', () {
        // Act
        final result = DateTimeUnit.month.next;

        // Assert
        expect(result, equals(DateTimeUnit.day));
      });

      test('should return next enum value for day', () {
        // Act
        final result = DateTimeUnit.day.next;

        // Assert
        expect(result, equals(DateTimeUnit.hour));
      });

      test('should return next enum value for hour', () {
        // Act
        final result = DateTimeUnit.hour.next;

        // Assert
        expect(result, equals(DateTimeUnit.minute));
      });

      test('should return next enum value for minute', () {
        // Act
        final result = DateTimeUnit.minute.next;

        // Assert
        expect(result, equals(DateTimeUnit.second));
      });

      test('should return next enum value for second', () {
        // Act
        final result = DateTimeUnit.second.next;

        // Assert
        expect(result, equals(DateTimeUnit.msec));
      });

      test('should return next enum value for msec', () {
        // Act
        final result = DateTimeUnit.msec.next;

        // Assert
        expect(result, equals(DateTimeUnit.usec));
      });

      test('should return null for usec as it is the last enum value', () {
        // Act
        final result = DateTimeUnit.usec.next;

        // Assert
        expect(result, isNull);
      });
    });

    group('sublist', () {
      test('should return all enum values starting from year', () {
        // Act
        final result = DateTimeUnit.year.sublist();

        // Assert
        expect(result, hasLength(8));
        expect(
          result,
          containsAll([
            DateTimeUnit.year,
            DateTimeUnit.month,
            DateTimeUnit.day,
            DateTimeUnit.hour,
            DateTimeUnit.minute,
            DateTimeUnit.second,
            DateTimeUnit.msec,
            DateTimeUnit.usec,
          ]),
        );
      });

      test('should return subset starting from month', () {
        // Act
        final result = DateTimeUnit.month.sublist();

        // Assert
        expect(result, hasLength(7));
        expect(
          result,
          containsAll([
            DateTimeUnit.month,
            DateTimeUnit.day,
            DateTimeUnit.hour,
            DateTimeUnit.minute,
            DateTimeUnit.second,
            DateTimeUnit.msec,
            DateTimeUnit.usec,
          ]),
        );
        expect(result, isNot(contains(DateTimeUnit.year)));
      });

      test('should return subset starting from day', () {
        // Act
        final result = DateTimeUnit.day.sublist();

        // Assert
        expect(result, hasLength(6));
        expect(
          result,
          containsAll([
            DateTimeUnit.day,
            DateTimeUnit.hour,
            DateTimeUnit.minute,
            DateTimeUnit.second,
            DateTimeUnit.msec,
            DateTimeUnit.usec,
          ]),
        );
      });

      test('should return subset starting from hour', () {
        // Act
        final result = DateTimeUnit.hour.sublist();

        // Assert
        expect(result, hasLength(5));
        expect(
          result,
          containsAll([
            DateTimeUnit.hour,
            DateTimeUnit.minute,
            DateTimeUnit.second,
            DateTimeUnit.msec,
            DateTimeUnit.usec,
          ]),
        );
      });

      test('should return subset starting from minute', () {
        // Act
        final result = DateTimeUnit.minute.sublist();

        // Assert
        expect(result, hasLength(4));
        expect(
          result,
          containsAll([
            DateTimeUnit.minute,
            DateTimeUnit.second,
            DateTimeUnit.msec,
            DateTimeUnit.usec,
          ]),
        );
      });

      test('should return subset starting from second', () {
        // Act
        final result = DateTimeUnit.second.sublist();

        // Assert
        expect(result, hasLength(3));
        expect(
          result,
          containsAll([
            DateTimeUnit.second,
            DateTimeUnit.msec,
            DateTimeUnit.usec,
          ]),
        );
      });

      test('should return subset starting from msec', () {
        // Act
        final result = DateTimeUnit.msec.sublist();

        // Assert
        expect(result, hasLength(2));
        expect(result, containsAll([DateTimeUnit.msec, DateTimeUnit.usec]));
      });

      test('should return single element set for usec', () {
        // Act
        final result = DateTimeUnit.usec.sublist();

        // Assert
        expect(result, hasLength(1));
        expect(result, contains(DateTimeUnit.usec));
      });

      test('should return Set type', () {
        // Act
        final result = DateTimeUnit.year.sublist();

        // Assert
        expect(result, isA<Set<DateTimeUnit>>());
      });
    });
  });

  group('DateTimeOrdering', () {
    group('enum values', () {
      test('should contain all expected enum values', () {
        // Arrange & Act
        final values = DateTimeOrdering.values;

        // Assert
        expect(values, hasLength(3));
        expect(values, contains(DateTimeOrdering.before));
        expect(values, contains(DateTimeOrdering.now));
        expect(values, contains(DateTimeOrdering.after));
      });
    });

    group('direction', () {
      test('should return before when startEvent is before endEvent', () {
        // Arrange
        final startEvent = DateTime(2023, 12, 25, 10, 0, 0);
        final endEvent = DateTime(2023, 12, 25, 11, 0, 0);

        // Act
        final result = DateTimeOrdering.direction(startEvent, endEvent);

        // Assert
        expect(result, equals(DateTimeOrdering.before));
      });

      test('should return after when startEvent is after endEvent', () {
        // Arrange
        final startEvent = DateTime(2023, 12, 25, 11, 0, 0);
        final endEvent = DateTime(2023, 12, 25, 10, 0, 0);

        // Act
        final result = DateTimeOrdering.direction(startEvent, endEvent);

        // Assert
        expect(result, equals(DateTimeOrdering.after));
      });

      test('should return now when startEvent equals endEvent', () {
        // Arrange
        final startEvent = DateTime(2023, 12, 25, 10, 0, 0);
        final endEvent = DateTime(2023, 12, 25, 10, 0, 0);

        // Act
        final result = DateTimeOrdering.direction(startEvent, endEvent);

        // Assert
        expect(result, equals(DateTimeOrdering.now));
      });

      test('should handle microsecond precision differences', () {
        // Arrange
        final startEvent = DateTime.fromMicrosecondsSinceEpoch(1000000);
        final endEvent = DateTime.fromMicrosecondsSinceEpoch(1000001);

        // Act
        final result = DateTimeOrdering.direction(startEvent, endEvent);

        // Assert
        expect(result, equals(DateTimeOrdering.before));
      });

      test('should handle UTC and local time comparisons', () {
        // Arrange
        final startEventUtc = DateTime.utc(2023, 12, 25, 10, 0, 0);
        final endEventLocal = DateTime(
          2023,
          12,
          25,
          15,
          0,
          0,
        ); // Assuming different timezone

        // Act
        final result = DateTimeOrdering.direction(startEventUtc, endEventLocal);

        // Assert
        expect(result, isA<DateTimeOrdering>());
      });

      test('should handle edge case with same microsecond precision', () {
        // Arrange
        final microseconds = 1703505600000000;
        final startEvent = DateTime.fromMicrosecondsSinceEpoch(microseconds);
        final endEvent = DateTime.fromMicrosecondsSinceEpoch(microseconds);

        // Act
        final result = DateTimeOrdering.direction(startEvent, endEvent);

        // Assert
        expect(result, equals(DateTimeOrdering.now));
      });
    });
  });
}
