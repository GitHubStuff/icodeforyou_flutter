// packages/ext_duration/test/src/duration_units_test.dart

import 'package:ext_duration/src/duration_units.dart';
import 'package:test/test.dart';

void main() {
  group('DurationUnits', () {
    group('inMicroseconds', () {
      test('days', () {
        expect(DurationUnits.days.inMicroseconds, Duration.microsecondsPerDay);
      });

      test('hours', () {
        expect(
          DurationUnits.hours.inMicroseconds,
          Duration.microsecondsPerHour,
        );
      });

      test('minutes', () {
        expect(
          DurationUnits.minutes.inMicroseconds,
          Duration.microsecondsPerMinute,
        );
      });

      test('seconds', () {
        expect(
          DurationUnits.seconds.inMicroseconds,
          Duration.microsecondsPerSecond,
        );
      });

      test('milliseconds', () {
        expect(
          DurationUnits.milliseconds.inMicroseconds,
          Duration.microsecondsPerMillisecond,
        );
      });

      test('microseconds is the base unit', () {
        expect(DurationUnits.microseconds.inMicroseconds, 1);
      });

      test('units are strictly decreasing in declaration order', () {
        final sizes = DurationUnits.values.map((u) => u.inMicroseconds);
        for (var i = 1; i < sizes.length; i++) {
          expect(sizes.elementAt(i), lessThan(sizes.elementAt(i - 1)));
        }
      });
    });

    group('times', () {
      test('days', () {
        expect(DurationUnits.days.times(2), const Duration(days: 2));
      });

      test('hours', () {
        expect(DurationUnits.hours.times(3), const Duration(hours: 3));
      });

      test('minutes', () {
        expect(DurationUnits.minutes.times(45), const Duration(minutes: 45));
      });

      test('seconds', () {
        expect(DurationUnits.seconds.times(90), const Duration(seconds: 90));
      });

      test('milliseconds', () {
        expect(
          DurationUnits.milliseconds.times(250),
          const Duration(milliseconds: 250),
        );
      });

      test('microseconds', () {
        expect(
          DurationUnits.microseconds.times(7),
          const Duration(microseconds: 7),
        );
      });

      test('zero count yields Duration.zero', () {
        for (final unit in DurationUnits.values) {
          expect(unit.times(0), Duration.zero, reason: unit.name);
        }
      });

      test('negative count yields a negative duration', () {
        expect(DurationUnits.hours.times(-1), const Duration(hours: -1));
        expect(DurationUnits.hours.times(-1).isNegative, isTrue);
      });

      test('count of one equals inMicroseconds', () {
        for (final unit in DurationUnits.values) {
          expect(
            unit.times(1).inMicroseconds,
            unit.inMicroseconds,
            reason: unit.name,
          );
        }
      });
    });
  });
}
