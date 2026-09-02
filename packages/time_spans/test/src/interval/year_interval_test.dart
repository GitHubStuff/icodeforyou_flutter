// packages/time_spans/test/src/interval/year_interval_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:time_spans/src/interval/year_interval.dart';
import 'package:time_spans/time_spans.dart' show DateTimeOrder;

void main() {
  group('YearInterval', () {
    group('Ordering and Magnitudes', () {
      test('correctly measures when start is before finish', () {
        final start = DateTime.utc(2020, 1, 1);
        final finish = DateTime.utc(2021, 1, 1);
        final interval = YearInterval.of(start: start, finish: finish);

        expect(interval.years, 1);
        expect(interval.order, DateTimeOrder.before);
        expect(
          interval.milliseconds,
          31622400000,
        ); // 366 days in ms (2020 is a leap year)
      });

      test('correctly measures when start is after finish', () {
        final start = DateTime.utc(2021, 1, 1);
        final finish = DateTime.utc(2020, 1, 1);
        final interval = YearInterval.of(start: start, finish: finish);

        expect(interval.years, 1); // Magnitude is always positive
        expect(interval.order, DateTimeOrder.after);
        expect(
          interval.milliseconds,
          31622400000,
        ); // Magnitude is always positive
      });

      test('correctly measures when start equals finish', () {
        final time = DateTime.utc(2020, 1, 1);
        final interval = YearInterval.of(start: time, finish: time);

        expect(interval.years, 0);
        expect(interval.order, DateTimeOrder.now);
        expect(interval.milliseconds, 0);
      });

      test('normalizes timezones to UTC before comparison', () {
        // Two DateTime objects representing the exact same moment but in different timezones
        final local = DateTime(2020, 1, 1, 12, 0, 0);
        final utc = local.toUtc();

        final interval = YearInterval.of(start: local, finish: utc);

        expect(interval.order, DateTimeOrder.now);
        expect(interval.years, 0);
        expect(interval.milliseconds, 0);
      });
    });

    group('_yearsBetween Anniversary Logic', () {
      test('returns 0 if candidate years <= 0 (same year)', () {
        final start = DateTime.utc(2020, 5, 1);
        final finish = DateTime.utc(2020, 10, 1);
        final interval = YearInterval.of(start: start, finish: finish);

        expect(interval.years, 0);
      });

      test(
        'decrements candidate if anniversary is not yet reached by a single microsecond',
        () {
          final start = DateTime.utc(2020, 5, 15, 10, 0, 0, 0, 10);
          final finish = DateTime.utc(2021, 5, 15, 10, 0, 0, 0, 9);
          final interval = YearInterval.of(start: start, finish: finish);

          expect(interval.years, 0);
        },
      );

      test('accepts candidate if anniversary is exactly reached', () {
        final start = DateTime.utc(2020, 5, 15, 10, 0, 0, 0, 10);
        final finish = DateTime.utc(2021, 5, 15, 10, 0, 0, 0, 10);
        final interval = YearInterval.of(start: start, finish: finish);

        expect(interval.years, 1);
      });

      test('accepts candidate if anniversary is passed', () {
        final start = DateTime.utc(2020, 5, 15);
        final finish = DateTime.utc(2021, 5, 16);
        final interval = YearInterval.of(start: start, finish: finish);

        expect(interval.years, 1);
      });
    });

    group('End-of-month Rule', () {
      test('start on non-end-of-month preserves literal day', () {
        final start = DateTime.utc(
          2020,
          2,
          28,
        ); // Not end of month (2020 is a leap year)
        final finish = DateTime.utc(2021, 2, 28);
        final interval = YearInterval.of(start: start, finish: finish);

        expect(interval.years, 1); // Reaches 28th to 28th
      });

      test(
        'start on Feb 29 (end-of-month) clamps to Feb 28 in common years',
        () {
          final start = DateTime.utc(2020, 2, 29, 18);
          final finish = DateTime.utc(
            2021,
            2,
            28,
            18,
          ); // Has reached clamped anniversary
          final interval = YearInterval.of(start: start, finish: finish);

          expect(interval.years, 1);
        },
      );

      test(
        'start on Feb 28 in common year (end-of-month) clamps to Feb 29 in leap years',
        () {
          final start = DateTime.utc(2019, 2, 28, 18);
          // The clamped anniversary in 2020 is Feb 29, so reaching only Feb 28 means
          // the anniversary has NOT been reached yet.
          final finish = DateTime.utc(2020, 2, 28, 18);
          final interval = YearInterval.of(start: start, finish: finish);

          expect(interval.years, 0);
        },
      );

      test(
        'start on Feb 28 in common year (end-of-month) clamps to Feb 29 in leap years (reached)',
        () {
          final start = DateTime.utc(2019, 2, 28, 18);
          final finish = DateTime.utc(
            2020,
            2,
            29,
            18,
          ); // Has reached clamped anniversary
          final interval = YearInterval.of(start: start, finish: finish);

          expect(interval.years, 1);
        },
      );

      test(
        'start on month with 31 days clamps safely to 31 in the next year',
        () {
          final start = DateTime.utc(2020, 1, 31);
          final finish = DateTime.utc(2021, 1, 31);
          final interval = YearInterval.of(start: start, finish: finish);

          expect(interval.years, 1);
        },
      );
    });
  });
}
