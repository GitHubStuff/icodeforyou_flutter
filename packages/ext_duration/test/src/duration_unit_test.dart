// packages/ext_duration/test/src/duration_unit_test.dart

import 'package:ext_duration/ext_duration.dart' show DurationUnits;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DurationUnits', () {
    group('values', () {
      test('declares every unit from days down to microseconds in order', () {
        expect(DurationUnits.values, [
          DurationUnits.days,
          DurationUnits.hours,
          DurationUnits.minutes,
          DurationUnits.seconds,
          DurationUnits.milliseconds,
          DurationUnits.microseconds,
        ]);
      });
    });

    group('inMicroseconds', () {
      test('days equals Duration.microsecondsPerDay', () {
        expect(
          DurationUnits.days.inMicroseconds,
          Duration.microsecondsPerDay,
        );
      });

      test('hours equals Duration.microsecondsPerHour', () {
        expect(
          DurationUnits.hours.inMicroseconds,
          Duration.microsecondsPerHour,
        );
      });

      test('minutes equals Duration.microsecondsPerMinute', () {
        expect(
          DurationUnits.minutes.inMicroseconds,
          Duration.microsecondsPerMinute,
        );
      });

      test('seconds equals Duration.microsecondsPerSecond', () {
        expect(
          DurationUnits.seconds.inMicroseconds,
          Duration.microsecondsPerSecond,
        );
      });

      test('milliseconds equals Duration.microsecondsPerMillisecond', () {
        expect(
          DurationUnits.milliseconds.inMicroseconds,
          Duration.microsecondsPerMillisecond,
        );
      });

      test('microseconds equals 1', () {
        expect(DurationUnits.microseconds.inMicroseconds, 1);
      });

      test('is strictly decreasing from days to microseconds', () {
        final values = DurationUnits.values
            .map((unit) => unit.inMicroseconds)
            .toList();

        for (var i = 1; i < values.length; i++) {
          expect(
            values[i],
            lessThan(values[i - 1]),
            reason:
                '${DurationUnits.values[i]} must be smaller than '
                '${DurationUnits.values[i - 1]}',
          );
        }
      });
    });

    group('times', () {
      test('builds the requested number of days', () {
        expect(DurationUnits.days.times(2), const Duration(days: 2));
      });

      test('builds the requested number of hours', () {
        expect(DurationUnits.hours.times(5), const Duration(hours: 5));
      });

      test('builds the requested number of minutes', () {
        expect(DurationUnits.minutes.times(90), const Duration(minutes: 90));
      });

      test('builds the requested number of seconds', () {
        expect(DurationUnits.seconds.times(61), const Duration(seconds: 61));
      });

      test('builds the requested number of milliseconds', () {
        expect(
          DurationUnits.milliseconds.times(1500),
          const Duration(milliseconds: 1500),
        );
      });

      test('builds the requested number of microseconds', () {
        expect(
          DurationUnits.microseconds.times(42),
          const Duration(microseconds: 42),
        );
      });

      test('returns Duration.zero for a count of zero', () {
        for (final unit in DurationUnits.values) {
          expect(unit.times(0), Duration.zero, reason: '$unit');
        }
      });

      test('returns a negative duration for a negative count', () {
        expect(DurationUnits.hours.times(-3), const Duration(hours: -3));
        expect(DurationUnits.hours.times(-3).isNegative, isTrue);
      });

      test('is consistent with inMicroseconds for every unit', () {
        for (final unit in DurationUnits.values) {
          expect(
            unit.times(7).inMicroseconds,
            7 * unit.inMicroseconds,
            reason: '$unit',
          );
        }
      });
    });
  });
}
