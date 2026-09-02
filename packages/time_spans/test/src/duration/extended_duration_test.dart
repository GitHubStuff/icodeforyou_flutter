// packages/time_spans/test/src/duration/extended_duration_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:time_spans/src/duration/extended_duration.dart';

void main() {
  group('ExtendedDuration', () {
    group('from(Duration)', () {
      test('parses a positive duration into sub-month components', () {
        const duration = Duration(
          days: 10,
          hours: 5,
          minutes: 15,
          seconds: 30,
          milliseconds: 500,
          microseconds: 250,
        );
        final ed = ExtendedDuration.from(duration);

        // Calendar fields should be strictly 0/null
        expect(ed.years, 0);
        expect(ed.months, 0);
        expect(ed.resolvedYearDays, isNull);
        expect(ed.resolvedMonthDays, isNull);

        // Time fields should be correctly decomposed
        expect(ed.weeks, 1);
        expect(ed.days, 3);
        expect(ed.hours, 5);
        expect(ed.minutes, 15);
        expect(ed.seconds, 30);
        expect(ed.milliseconds, 500);
        expect(ed.microseconds, 250);
      });

      test(
        'parses a negative duration correctly, preserving the shared sign',
        () {
          const duration = Duration(
            days: -10,
            hours: -5,
          );
          final ed = ExtendedDuration.from(duration);

          expect(ed.weeks, -1);
          expect(ed.days, -3);
          expect(ed.hours, -5);
        },
      );
    });

    group('period()', () {
      test(
        'normalizes months into years and unanchored time into sub-month fields',
        () {
          final ed = ExtendedDuration.period(
            years: 1,
            months: 15, // 1 year, 3 months -> total 2 years, 3 months
            weeks: 1,
            days: 10, // 1 week, 3 days -> total 2 weeks, 3 days
            hours: 25, // 1 day, 1 hour -> total 2 weeks, 4 days, 1 hour
            minutes: 61,
            seconds: 61,
            milliseconds: 1001,
            microseconds: 1001,
          );

          expect(ed.years, 2);
          expect(ed.months, 3);
          expect(ed.weeks, 2);
          expect(ed.days, 4);
          expect(ed.hours, 2);
          expect(ed.minutes, 2);
          expect(ed.seconds, 2);
          expect(ed.milliseconds, 2);
          expect(ed.microseconds, 1);
        },
      );

      test('handles negative periods natively', () {
        final ed = ExtendedDuration.period(
          months: -15,
          days: -10,
        );

        expect(ed.years, -1);
        expect(ed.months, -3);
        expect(ed.weeks, -1);
        expect(ed.days, -3);
      });
    });

    group('toDuration() and _calendarDays resolution', () {
      test('is exact when all calendar fields are resolved', () {
        final ed = ExtendedDuration.ofComponents(
          years: 1,
          months: 2,
          weeks: 1,
          days: 2,
          resolvedYearDays: 365,
          resolvedMonthDays: 60,
        );

        final duration = ed.toDuration();

        // 365 (years) + 60 (months) + 7 (1 week) + 2 (days) = 434
        expect(duration.inDays, 434);
      });

      test('falls back to estimate when ONLY year is unresolved', () {
        final ed = ExtendedDuration.ofComponents(
          years: 1, // Unresolved, invokes averageDaysPerMonth(12)
          months: 1,
          resolvedYearDays: null,
          resolvedMonthDays: 30, // Resolved
        );

        final duration = ed.toDuration();
        // 1 year (estimated) + 30 days = ~395 days
        expect(duration.inDays, greaterThan(365));
        expect(duration.inDays, lessThan(400));
      });

      test('falls back to estimate when ONLY month is unresolved', () {
        final ed = ExtendedDuration.ofComponents(
          years: 1,
          months: 2, // Unresolved, invokes averageDaysPerMonth(2)
          resolvedYearDays: 365, // Resolved
          resolvedMonthDays: null,
        );

        final duration = ed.toDuration();
        // 365 days + 2 months (estimated) = ~425 days
        expect(duration.inDays, greaterThan(400));
        expect(duration.inDays, lessThan(435));
      });

      test('uses pure estimate when both year and month are unresolved', () {
        final ed = ExtendedDuration.ofComponents(
          years: 1,
          months: 2,
          resolvedYearDays: null,
          resolvedMonthDays: null,
        );

        final duration = ed.toDuration();
        // 14 months estimated = ~426 days
        expect(duration.inDays, greaterThan(400));
        expect(duration.inDays, lessThan(435));
      });

      test('bypasses estimate logic safely when unresolvedMonths is 0', () {
        final ed = ExtendedDuration.ofComponents(
          years: 0,
          months: 0,
          weeks: 2,
          resolvedYearDays: null,
          resolvedMonthDays: null,
        );

        // Since years and months are 0, unresolvedMonths == 0
        final duration = ed.toDuration();
        expect(duration.inDays, 14);
      });
    });

    group('Equatable overrides', () {
      test('supports value equality', () {
        final ed1 = ExtendedDuration.period(years: 1, days: 5);
        final ed2 = ExtendedDuration.period(years: 1, days: 5);
        final ed3 = ExtendedDuration.period(years: 1, days: 6);

        expect(ed1, equals(ed2));
        expect(ed1, isNot(equals(ed3)));
      });

      test('supports stringify', () {
        final ed = ExtendedDuration.period(years: 1);

        expect(ed.stringify, isTrue);
        expect(ed.toString(), contains('ExtendedDuration'));
        expect(ed.props.length, 11);
      });
    });
  });
}
