// packages/time_spans/test/src/interval/month_interval_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:time_spans/src/interval/month_interval.dart';
import 'package:time_spans/src/policy/month_policy.dart';
import 'package:time_spans/src/span.dart';

void main() {
  group('MonthInterval', () {
    group('microsecondMonths', () {
      test('returns 0 when start and finish are the same', () {
        final t = DateTime(2024, 1, 15);
        expect(MonthInterval.microsecondMonths(t, t), 0);
      });

      test('calculates microseconds correctly for exactly 1 month', () {
        final start = DateTime(2024, 1, 15);
        final finish = DateTime(2024, 2, 15);
        final expected = finish.difference(start).inMicroseconds;

        expect(MonthInterval.microsecondMonths(start, finish), expected);
      });

      test('swaps start and finish if start is after finish', () {
        final start = DateTime(2024, 2, 15);
        final finish = DateTime(2024, 1, 15);
        final expected = start.difference(finish).inMicroseconds;

        expect(MonthInterval.microsecondMonths(start, finish), expected);
      });

      test(
        'decrements internal months if _addMonths overshoots the later date',
        () {
          // From Jan 31 to Mar 1.
          // Base month difference is 2. _addMonths(Jan 31, 2) is Mar 31, which overshoots Mar 1.
          // The algorithm must decrement back to 1 month.
          // _addMonths(Jan 31, 1, clamp) is Feb 29 (since 2024 is a leap year).
          final start = DateTime(2024, 1, 31);
          final finish = DateTime(2024, 3, 1);

          // Expected is the exact microsecond span from Jan 31 to Feb 29.
          final expected = DateTime(
            2024,
            2,
            29,
          ).difference(start).inMicroseconds;

          expect(MonthInterval.microsecondMonths(start, finish), expected);
        },
      );
    });

    group('completedMonths', () {
      test('returns exact month count when asOf day is exact or later', () {
        expect(
          MonthInterval.completedMonths(
            DateTime(2024, 1, 15),
            DateTime(2024, 2, 15),
          ),
          1,
        );
        expect(
          MonthInterval.completedMonths(
            DateTime(2024, 1, 15),
            DateTime(2024, 2, 16),
          ),
          1,
        );
      });

      test(
        'decrements month count if asOf day is earlier than the clamped start day',
        () {
          expect(
            MonthInterval.completedMonths(
              DateTime(2024, 1, 15),
              DateTime(2024, 2, 14),
            ),
            0,
          );
        },
      );

      test(
        'handles clamped days correctly in a leap year (e.g. Jan 31 to Feb 29)',
        () {
          expect(
            MonthInterval.completedMonths(
              DateTime(2024, 1, 31),
              DateTime(2024, 2, 29),
            ),
            1,
          );
        },
      );

      test(
        'handles clamped days correctly in a common year (e.g. Jan 31 to Feb 28)',
        () {
          expect(
            MonthInterval.completedMonths(
              DateTime(2023, 1, 31),
              DateTime(2023, 2, 28),
            ),
            1,
          );
          expect(
            MonthInterval.completedMonths(
              DateTime(2023, 1, 31),
              DateTime(2023, 2, 27),
            ),
            0,
          );
        },
      );

      test(
        'returns mathematically expected negative values for backward spans',
        () {
          // These assertions document the function's specific directional math
          // when traversing backwards mathematically.
          expect(
            MonthInterval.completedMonths(
              DateTime(2024, 2, 15),
              DateTime(2024, 1, 16),
            ),
            -1,
          );
          expect(
            MonthInterval.completedMonths(
              DateTime(2024, 2, 15),
              DateTime(2024, 1, 14),
            ),
            -2,
          );
        },
      );
    });

    group('completedYears', () {
      test('returns whole years accurately using completedMonths division', () {
        expect(
          MonthInterval.completedYears(
            DateTime(2000, 1, 1),
            DateTime(2002, 1, 1),
          ),
          2,
        );
        expect(
          MonthInterval.completedYears(
            DateTime(2000, 1, 1),
            DateTime(2001, 12, 31),
          ),
          1,
        );
        expect(
          MonthInterval.completedYears(
            DateTime(2000, 1, 1),
            DateTime(1998, 1, 1),
          ),
          -2,
        );
      });
    });

    group('monthCounter', () {
      test('returns 0 when start and finish are the exact same moment', () {
        final t = DateTime(2024, 1, 1);
        expect(
          MonthInterval.monthCounter(
            start: t,
            finish: t,
            monthPolicy: MonthPolicy.clamp,
          ),
          0,
        );
      });

      test('returns negative months when start is before finish', () {
        final start = DateTime(2024, 1, 15);
        final finish = DateTime(2024, 2, 15);
        expect(
          MonthInterval.monthCounter(
            start: start,
            finish: finish,
            monthPolicy: MonthPolicy.clamp,
          ),
          -1,
        );
      });

      test(
        'returns positive months when start is after finish (recurses and uses absolute value)',
        () {
          final start = DateTime(2024, 2, 15);
          final finish = DateTime(2024, 1, 15);
          expect(
            MonthInterval.monthCounter(
              start: start,
              finish: finish,
              monthPolicy: MonthPolicy.clamp,
            ),
            1,
          );
        },
      );

      test(
        'handles overshoot decrements correctly with MonthPolicy.overflow',
        () {
          // Base month difference from Jan 31 to Mar 1 is 2.
          // _addMonths(Jan 31, 2) -> Mar 31. isAfter(Mar 1) -> True.
          // months decrements to 1.
          // _addMonths(Jan 31, 1, overflow) -> Mar 2 (since 2024 is a leap year, Dart overflows Feb 31 to Mar 2).
          // Mar 2 isAfter Mar 1 -> True.
          // months decrements to 0.
          final start = DateTime(2024, 1, 31);
          final finish = DateTime(2024, 3, 1);

          expect(
            MonthInterval.monthCounter(
              start: start,
              finish: finish,
              monthPolicy: MonthPolicy.overflow,
            ),
            0,
          );
        },
      );

      test('handles overshoot decrements correctly with MonthPolicy.clamp', () {
        final start = DateTime(2024, 1, 31);
        final finish = DateTime(2024, 3, 1);

        // Jan 31 + 2 clamped -> Mar 31 (decrements to 1)
        // Jan 31 + 1 clamped -> Feb 29 (which is <= Mar 1).
        // Algorithm returns -1.
        expect(
          MonthInterval.monthCounter(
            start: start,
            finish: finish,
            monthPolicy: MonthPolicy.clamp,
          ),
          -1,
        );
      });
    });

    group('averageDaysPerMonth', () {
      test(
        'returns the correct highly-precise average for each duration tier',
        () {
          expect(MonthInterval.averageDaysPerMonth(6), Span.kCommonYearAvg);
          expect(MonthInterval.averageDaysPerMonth(12), Span.kCommonYearAvg);

          expect(MonthInterval.averageDaysPerMonth(13), Span.kJulianCycleAvg);
          expect(MonthInterval.averageDaysPerMonth(48), Span.kJulianCycleAvg);

          expect(MonthInterval.averageDaysPerMonth(49), Span.kCenturyAvg);
          expect(MonthInterval.averageDaysPerMonth(1200), Span.kCenturyAvg);

          expect(
            MonthInterval.averageDaysPerMonth(1201),
            Span.kGregorianCycleAvg,
          );
          expect(
            MonthInterval.averageDaysPerMonth(5000),
            Span.kGregorianCycleAvg,
          );
        },
      );
    });
  });
}
