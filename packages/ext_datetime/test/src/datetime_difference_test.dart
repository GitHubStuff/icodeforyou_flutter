// packages/ext_datetime/test/src/datetime_difference_test.dart

import 'package:ext_datetime/ext_datetime.dart';
import 'package:ext_datetime/src/helpers/datetime_difference.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a fully-populated [DateTimeDelta] (every unit non-null) so a whole
/// result can be asserted in one `expect`. Unspecified units default to zero.
DateTimeDelta allUnits({
  int years = 0,
  int months = 0,
  int days = 0,
  int hours = 0,
  int minutes = 0,
  int seconds = 0,
  int milliseconds = 0,
  int microseconds = 0,
  bool isFuture = true,
}) => DateTimeDelta(
  isFuture: isFuture,
  years: years,
  months: months,
  days: days,
  hours: hours,
  minutes: minutes,
  seconds: seconds,
  milliseconds: milliseconds,
  microseconds: microseconds,
);

/// Computes the delta at full (microsecond) precision so every component is
/// visible.
DateTimeDelta full(DateTime start, DateTime end) => DateTimeDifference.delta(
  startTime: start,
  endTime: end,
  precision: DateTimeUnit.usec,
);

/// Reads the component of [delta] that corresponds to [unit].
int? fieldOf(DateTimeDelta delta, DateTimeUnit unit) => switch (unit) {
  DateTimeUnit.year => delta.years,
  DateTimeUnit.month => delta.months,
  DateTimeUnit.day => delta.days,
  DateTimeUnit.hour => delta.hours,
  DateTimeUnit.minute => delta.minutes,
  DateTimeUnit.second => delta.seconds,
  DateTimeUnit.msec => delta.milliseconds,
  DateTimeUnit.usec => delta.microseconds,
};

void main() {
  group('DateTimeDifference.delta', () {
    group('argument validation', () {
      test('rejects a local startTime', () {
        expect(
          () => DateTimeDifference.delta(
            startTime: DateTime(2026),
            endTime: DateTime.utc(2026, 1, 2),
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('startTime must be UTC'),
            ),
          ),
        );
      });

      test('rejects a local endTime', () {
        expect(
          () => DateTimeDifference.delta(
            startTime: DateTime.utc(2026),
            endTime: DateTime(2026, 1, 2),
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('endTime must be UTC'),
            ),
          ),
        );
      });

      test('checks startTime before endTime when both are local', () {
        expect(
          () => DateTimeDifference.delta(
            startTime: DateTime(2026),
            endTime: DateTime(2026, 1, 2),
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('startTime must be UTC'),
            ),
          ),
        );
      });

      test('a local instant converted with toUtc is accepted', () {
        final start = DateTime(2026).toUtc();
        final end = DateTime(2026, 1, 2).toUtc();
        expect(
          () => DateTimeDifference.delta(startTime: start, endTime: end),
          returnsNormally,
        );
      });

      test('rejects firstDateTimeUnit finer than precision', () {
        expect(
          () => DateTimeDifference.delta(
            startTime: DateTime.utc(2026),
            endTime: DateTime.utc(2026, 1, 2),
            firstDateTimeUnit: DateTimeUnit.minute,
            precision: DateTimeUnit.hour,
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              allOf(
                contains('cannot be smaller than'),
                contains('DateTimeUnit.minute'),
                contains('DateTimeUnit.hour'),
              ),
            ),
          ),
        );
      });

      test('rejects every invalid (firstDateTimeUnit, precision) pair', () {
        for (final first in DateTimeUnit.values) {
          for (final precision in DateTimeUnit.values) {
            if (first.index <= precision.index) continue;
            expect(
              () => DateTimeDifference.delta(
                startTime: DateTime.utc(2026),
                endTime: DateTime.utc(2026, 1, 2),
                firstDateTimeUnit: first,
                precision: precision,
              ),
              throwsArgumentError,
              reason: 'first=$first precision=$precision',
            );
          }
        }
      });

      test('accepts firstDateTimeUnit equal to precision', () {
        for (final unit in DateTimeUnit.values) {
          expect(
            () => DateTimeDifference.delta(
              startTime: DateTime.utc(2026),
              endTime: DateTime.utc(2026, 1, 2),
              firstDateTimeUnit: unit,
              precision: unit,
            ),
            returnsNormally,
            reason: '$unit',
          );
        }
      });

      test('UTC validation runs before unit validation', () {
        expect(
          () => DateTimeDifference.delta(
            startTime: DateTime(2026),
            firstDateTimeUnit: DateTimeUnit.minute,
            precision: DateTimeUnit.hour,
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('startTime must be UTC'),
            ),
          ),
        );
      });

      test('unit validation runs even when the instants are identical', () {
        final instant = DateTime.utc(2026);
        expect(
          () => DateTimeDifference.delta(
            startTime: instant,
            endTime: instant,
            firstDateTimeUnit: DateTimeUnit.usec,
            precision: DateTimeUnit.year,
          ),
          throwsArgumentError,
        );
      });
    });

    group('endTime defaults to now', () {
      test('a past startTime yields a future-pointing delta', () {
        final result = DateTimeDifference.delta(startTime: DateTime.utc(2000));
        expect(result.isFuture, isTrue);
        expect(result.years, greaterThanOrEqualTo(26));
      });

      test('a future startTime yields a past-pointing delta', () {
        final result = DateTimeDifference.delta(startTime: DateTime.utc(2100));
        expect(result.isFuture, isFalse);
        expect(result.years, greaterThanOrEqualTo(73));
      });

      test('honours filtering with a defaulted endTime', () {
        final result = DateTimeDifference.delta(
          startTime: DateTime.utc(2000),
          firstDateTimeUnit: DateTimeUnit.day,
          precision: DateTimeUnit.hour,
          truncate: false,
        );
        expect(result.years, isNull);
        expect(result.months, isNull);
        expect(result.days, isNotNull);
        expect(result.hours, isNotNull);
        expect(result.minutes, isNull);
        expect(result.seconds, isNull);
        expect(result.milliseconds, isNull);
        expect(result.microseconds, isNull);
      });
    });

    group('identical instants', () {
      test('return a delta with every component null and isFuture true', () {
        final instant = DateTime.utc(2026, 10, 21, 12, 34, 56, 789, 123);
        final result = DateTimeDifference.delta(
          startTime: instant,
          endTime: instant,
        );
        expect(result, const DateTimeDelta(isFuture: true));
      });

      test('stay null regardless of precision and truncate', () {
        final instant = DateTime.utc(2026);
        final truncated = DateTimeDifference.delta(
          startTime: instant,
          endTime: instant,
          precision: DateTimeUnit.usec,
        );
        final untruncated = DateTimeDifference.delta(
          startTime: instant,
          endTime: instant,
          precision: DateTimeUnit.year,
          truncate: false,
        );
        expect(truncated, const DateTimeDelta(isFuture: true));
        expect(untruncated, const DateTimeDelta(isFuture: true));
      });

      test('two distinct but same-moment objects count as identical', () {
        final a = DateTime.utc(2026, 5, 5, 5, 5, 5, 5, 5);
        final b = DateTime.fromMicrosecondsSinceEpoch(
          a.microsecondsSinceEpoch,
          isUtc: true,
        );
        expect(identical(a, b), isFalse);
        expect(
          DateTimeDifference.delta(startTime: a, endTime: b),
          const DateTimeDelta(isFuture: true),
        );
      });

      test('render as 0', () {
        final instant = DateTime.utc(2026);
        expect(
          DateTimeDifference.delta(
            startTime: instant,
            endTime: instant,
          ).toString(),
          '0',
        );
      });
    });

    group('direction', () {
      final earlier = DateTime.utc(2024, 1, 15, 10, 30, 45, 123, 456);
      final later = DateTime.utc(2026, 3, 20, 8, 15, 20, 100, 200);

      test('start before end is future', () {
        expect(full(earlier, later).isFuture, isTrue);
      });

      test('start after end is past', () {
        expect(full(later, earlier).isFuture, isFalse);
      });

      test('magnitudes are identical in both directions', () {
        final forward = full(earlier, later);
        final backward = full(later, earlier);
        for (final unit in DateTimeUnit.values) {
          expect(
            fieldOf(forward, unit),
            fieldOf(backward, unit),
            reason: '$unit',
          );
        }
      });

      test('magnitudes are never negative in either direction', () {
        for (final delta in [full(earlier, later), full(later, earlier)]) {
          for (final unit in DateTimeUnit.values) {
            expect(
              fieldOf(delta, unit),
              greaterThanOrEqualTo(0),
              reason: '$unit',
            );
          }
        }
      });

      test('a one-microsecond past delta', () {
        final start = DateTime.utc(2026, 1, 1, 0, 0, 0, 0, 1);
        final end = DateTime.utc(2026);
        expect(full(start, end), allUnits(microseconds: 1, isFuture: false));
      });

      test('backward deltas are equal to forward deltas except direction', () {
        final forward = full(earlier, later);
        final backward = full(later, earlier);
        expect(forward, isNot(equals(backward)));
        expect(
          allUnits(
            years: forward.years!,
            months: forward.months!,
            days: forward.days!,
            hours: forward.hours!,
            minutes: forward.minutes!,
            seconds: forward.seconds!,
            milliseconds: forward.milliseconds!,
            microseconds: forward.microseconds!,
            isFuture: false,
          ),
          backward,
        );
      });
    });

    group('exact unit spans with no borrowing', () {
      test('one microsecond', () {
        expect(
          full(DateTime.utc(2026), DateTime.utc(2026, 1, 1, 0, 0, 0, 0, 1)),
          allUnits(microseconds: 1),
        );
      });

      test('one millisecond', () {
        expect(
          full(DateTime.utc(2026), DateTime.utc(2026, 1, 1, 0, 0, 0, 1)),
          allUnits(milliseconds: 1),
        );
      });

      test('one second', () {
        expect(
          full(DateTime.utc(2026), DateTime.utc(2026, 1, 1, 0, 0, 1)),
          allUnits(seconds: 1),
        );
      });

      test('one minute', () {
        expect(
          full(DateTime.utc(2026), DateTime.utc(2026, 1, 1, 0, 1)),
          allUnits(minutes: 1),
        );
      });

      test('one hour', () {
        expect(
          full(DateTime.utc(2026), DateTime.utc(2026, 1, 1, 1)),
          allUnits(hours: 1),
        );
      });

      test('one day', () {
        expect(
          full(DateTime.utc(2026), DateTime.utc(2026, 1, 2)),
          allUnits(days: 1),
        );
      });

      test('one month', () {
        expect(
          full(DateTime.utc(2026), DateTime.utc(2026, 2)),
          allUnits(months: 1),
        );
      });

      test('one year', () {
        expect(
          full(DateTime.utc(2026), DateTime.utc(2027)),
          allUnits(years: 1),
        );
      });

      test('exact multi-year anniversary', () {
        expect(
          full(
            DateTime.utc(2020, 5, 5, 5, 5, 5),
            DateTime.utc(2023, 5, 5, 5, 5, 5),
          ),
          allUnits(years: 3),
        );
      });

      test('one hundred years', () {
        expect(
          full(
            DateTime.utc(1926, 10, 21, 14, 30),
            DateTime.utc(2026, 10, 21, 14, 30),
          ),
          allUnits(years: 100),
        );
      });

      test('every component populated without any borrow', () {
        expect(
          full(
            DateTime.utc(2020, 1, 1, 1, 1, 1, 1, 1),
            DateTime.utc(2021, 2, 2, 2, 2, 2, 2, 2),
          ),
          allUnits(
            years: 1,
            months: 1,
            days: 1,
            hours: 1,
            minutes: 1,
            seconds: 1,
            milliseconds: 1,
            microseconds: 1,
          ),
        );
      });

      test('maximum values of every sub-month component', () {
        expect(
          full(
            DateTime.utc(2026),
            DateTime.utc(2026, 1, 31, 23, 59, 59, 999, 999),
          ),
          allUnits(
            days: 30,
            hours: 23,
            minutes: 59,
            seconds: 59,
            milliseconds: 999,
            microseconds: 999,
          ),
        );
      });
    });

    group('borrowing, one level at a time', () {
      test('microseconds borrow from milliseconds', () {
        expect(
          full(
            DateTime.utc(2026, 1, 1, 0, 0, 0, 5, 900),
            DateTime.utc(2026, 1, 1, 0, 0, 0, 6, 100),
          ),
          allUnits(microseconds: 200),
        );
      });

      test('milliseconds borrow from seconds', () {
        expect(
          full(
            DateTime.utc(2026, 1, 1, 0, 0, 0, 900),
            DateTime.utc(2026, 1, 1, 0, 0, 1, 100),
          ),
          allUnits(milliseconds: 200),
        );
      });

      test('seconds borrow from minutes', () {
        expect(
          full(
            DateTime.utc(2026, 1, 1, 0, 0, 50),
            DateTime.utc(2026, 1, 1, 0, 1, 10),
          ),
          allUnits(seconds: 20),
        );
      });

      test('minutes borrow from hours', () {
        expect(
          full(
            DateTime.utc(2026, 1, 1, 0, 50),
            DateTime.utc(2026, 1, 1, 1, 10),
          ),
          allUnits(minutes: 20),
        );
      });

      test('hours borrow from days', () {
        expect(
          full(DateTime.utc(2026, 1, 1, 22), DateTime.utc(2026, 1, 2, 2)),
          allUnits(hours: 4),
        );
      });

      test('days borrow from months (single borrow)', () {
        expect(
          full(DateTime.utc(2026, 1, 25), DateTime.utc(2026, 2, 5)),
          allUnits(days: 11),
        );
      });

      test('months borrow from years', () {
        expect(
          full(DateTime.utc(2025, 11, 10), DateTime.utc(2026, 2, 10)),
          allUnits(months: 3),
        );
      });
    });

    group('borrowing, cascades', () {
      test('full cascade from microseconds up through years', () {
        expect(
          full(
            DateTime.utc(2025, 12, 31, 23, 59, 59, 999, 999),
            DateTime.utc(2026),
          ),
          allUnits(microseconds: 1),
        );
      });

      test('microsecond borrow cascades into a month borrow across a year', () {
        expect(
          full(
            DateTime.utc(2025, 12, 31, 23, 59, 59, 999, 999),
            DateTime.utc(2026, 2),
          ),
          allUnits(months: 1, microseconds: 1),
        );
      });

      test('hour borrow cascades into a day borrow', () {
        expect(
          full(DateTime.utc(2026, 2, 28, 23), DateTime.utc(2026, 3, 1, 1)),
          allUnits(hours: 2),
        );
      });

      test('regression: hour borrow forces a double day borrow', () {
        // Jan 31 23:00 -> Mar 1 00:00 is 28 days 1 hour. The naive single
        // borrow against February (28 days) still leaves days negative, so a
        // second borrow must consult January (31 days), not February again.
        expect(
          full(DateTime.utc(2026, 1, 31, 23), DateTime.utc(2026, 3)),
          allUnits(days: 28, hours: 1),
        );
      });

      test('regression: minute and hour borrows force a double day borrow', () {
        expect(
          full(DateTime.utc(2026, 1, 31, 23, 59), DateTime.utc(2026, 3)),
          allUnits(days: 28, minutes: 1),
        );
      });

      test('regression: double day borrow in a leap year', () {
        // Jan 31 23:00 -> Mar 1 00:00 in 2024 is 29 days 1 hour.
        expect(
          full(DateTime.utc(2024, 1, 31, 23), DateTime.utc(2024, 3)),
          allUnits(days: 29, hours: 1),
        );
      });

      test('day borrow across the January/December year boundary', () {
        expect(
          full(DateTime.utc(2025, 12, 20), DateTime.utc(2026, 1, 5)),
          allUnits(days: 16),
        );
      });

      test('day borrow across the year boundary with an hour borrow', () {
        expect(
          full(DateTime.utc(2025, 12, 20, 18), DateTime.utc(2026, 1, 5, 6)),
          allUnits(days: 15, hours: 12),
        );
      });

      test(
        'hour borrow across the year boundary resolves to a whole month',
        () {
          // Dec 31 23:00 -> Feb 1 00:00: the hour borrow leaves days at -31,
          // which January's 31 days absorb exactly, so one month and one hour.
          expect(
            full(DateTime.utc(2025, 12, 31, 23), DateTime.utc(2026, 2)),
            allUnits(months: 1, hours: 1),
          );
        },
      );

      test('regression: double day borrow against a 30-day month', () {
        // Mar 31 23:00 -> May 1 00:00: April (30) leaves -1, so the second
        // borrow must consult March (31), yielding 30 days 1 hour.
        expect(
          full(DateTime.utc(2026, 3, 31, 23), DateTime.utc(2026, 5)),
          allUnits(days: 30, hours: 1),
        );
      });
    });

    group('calendar edge cases', () {
      test('Jan 31 to Feb 28 (common year) is 28 days', () {
        expect(
          full(DateTime.utc(2026, 1, 31), DateTime.utc(2026, 2, 28)),
          allUnits(days: 28),
        );
      });

      test('Jan 31 to Mar 1 (common year) is 29 days, not 1 month 1 day', () {
        expect(
          full(DateTime.utc(2026, 1, 31), DateTime.utc(2026, 3)),
          allUnits(days: 29),
        );
      });

      test('Jan 31 to Mar 1 (leap year) is 30 days', () {
        expect(
          full(DateTime.utc(2024, 1, 31), DateTime.utc(2024, 3)),
          allUnits(days: 30),
        );
      });

      test('Jan 31 to Feb 29 (leap year) is 29 days', () {
        expect(
          full(DateTime.utc(2024, 1, 31), DateTime.utc(2024, 2, 29)),
          allUnits(days: 29),
        );
      });

      test('Feb 29 to the following Feb 28 is 11 months 30 days', () {
        expect(
          full(DateTime.utc(2024, 2, 29), DateTime.utc(2025, 2, 28)),
          allUnits(months: 11, days: 30),
        );
      });

      test('Feb 29 to the following Mar 1 is exactly 1 year', () {
        expect(
          full(DateTime.utc(2024, 2, 29), DateTime.utc(2025, 3)),
          allUnits(years: 1),
        );
      });

      test('Feb 29 to Feb 29 four years later is exactly 4 years', () {
        expect(
          full(DateTime.utc(2024, 2, 29), DateTime.utc(2028, 2, 29)),
          allUnits(years: 4),
        );
      });

      test('Feb 28 to Mar 1 in a leap year is 2 days', () {
        expect(
          full(DateTime.utc(2024, 2, 28), DateTime.utc(2024, 3)),
          allUnits(days: 2),
        );
      });

      test('Feb 28 to Mar 1 in a common year is 1 day', () {
        expect(
          full(DateTime.utc(2026, 2, 28), DateTime.utc(2026, 3)),
          allUnits(days: 1),
        );
      });

      test('Nov 30 to Dec 1 is 1 day', () {
        expect(
          full(DateTime.utc(2026, 11, 30), DateTime.utc(2026, 12)),
          allUnits(days: 1),
        );
      });

      test('Dec 31 to Jan 1 is 1 day across the year boundary', () {
        expect(
          full(DateTime.utc(2025, 12, 31), DateTime.utc(2026)),
          allUnits(days: 1),
        );
      });

      test('borrow against a 30-day month', () {
        expect(
          full(DateTime.utc(2026, 4, 25), DateTime.utc(2026, 5, 5)),
          allUnits(days: 10),
        );
      });

      test('Mar 31 to Apr 30 is 30 days', () {
        expect(
          full(DateTime.utc(2026, 3, 31), DateTime.utc(2026, 4, 30)),
          allUnits(days: 30),
        );
      });

      test('Mar 31 to May 1 is reported as 1 month', () {
        expect(
          full(DateTime.utc(2026, 3, 31), DateTime.utc(2026, 5)),
          allUnits(months: 1),
        );
      });

      test('1900 is not a leap year: Jan 31 to Mar 1 is 29 days', () {
        expect(
          full(DateTime.utc(1900, 1, 31), DateTime.utc(1900, 3)),
          allUnits(days: 29),
        );
      });

      test('2000 is a leap year: Jan 31 to Mar 1 is 30 days', () {
        expect(
          full(DateTime.utc(2000, 1, 31), DateTime.utc(2000, 3)),
          allUnits(days: 30),
        );
      });

      test('2100 is not a leap year: Feb 28 to Mar 1 is 1 day', () {
        expect(
          full(DateTime.utc(2100, 2, 28), DateTime.utc(2100, 3)),
          allUnits(days: 1),
        );
      });

      test('from the Unix epoch', () {
        expect(
          full(
            DateTime.utc(1970),
            DateTime.utc(2026, 10, 21, 12, 34, 56, 789, 123),
          ),
          allUnits(
            years: 56,
            months: 9,
            days: 20,
            hours: 12,
            minutes: 34,
            seconds: 56,
            milliseconds: 789,
            microseconds: 123,
          ),
        );
      });

      test('pre-epoch instants', () {
        expect(
          full(DateTime.utc(1969, 12, 31, 23, 59, 59), DateTime.utc(1970)),
          allUnits(seconds: 1),
        );
      });

      test('documented usage example', () {
        expect(
          DateTimeDifference.delta(
            startTime: DateTime.utc(2024, 1, 15, 10, 30),
            endTime: DateTime.utc(2026, 3, 20, 8, 15),
          ),
          allUnits(years: 2, months: 2, days: 4, hours: 21, minutes: 45),
        );
      });

      test('documented filtering example', () {
        expect(
          DateTimeDifference.delta(
            startTime: DateTime.utc(2026, 10),
            endTime: DateTime.utc(2026, 10, 21, 14, 30, 45),
            firstDateTimeUnit: DateTimeUnit.day,
            precision: DateTimeUnit.minute,
            truncate: false,
          ),
          const DateTimeDelta(
            isFuture: true,
            days: 20,
            hours: 14,
            minutes: 30,
          ),
        );
      });

      test('every day-of-month start against the first of the next month', () {
        // Walks each start day in January and checks the day count is the
        // plain calendar distance to Feb 1 — no month is ever reported.
        for (var day = 1; day <= 31; day++) {
          final result = full(
            DateTime.utc(2026, 1, day),
            DateTime.utc(2026, 2),
          );
          expect(result.months, day == 1 ? 1 : 0, reason: 'Jan $day');
          expect(result.days, day == 1 ? 0 : 32 - day, reason: 'Jan $day');
        }
      });

      test('every month start to the same day next month is 1 month', () {
        for (var month = 1; month <= 12; month++) {
          final start = DateTime.utc(2026, month, 15);
          final end = DateTime.utc(2026, month + 1, 15);
          expect(full(start, end), allUnits(months: 1), reason: 'month $month');
        }
      });

      test(
        'day counts agree with DateTime.difference for whole days inside a month',
        () {
          for (var offset = 1; offset < 28; offset++) {
            final start = DateTime.utc(2026, 3);
            final end = start.add(Duration(days: offset));
            expect(full(start, end), allUnits(days: offset), reason: '$offset');
          }
        },
      );
    });

    group('filtering: firstDateTimeUnit', () {
      final start = DateTime.utc(2020, 1, 1, 1, 1, 1, 1, 1);
      final end = DateTime.utc(2021, 2, 2, 2, 2, 2, 2, 2);

      test('year (default) reports everything', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.usec,
        );
        expect(
          result,
          allUnits(
            years: 1,
            months: 1,
            days: 1,
            hours: 1,
            minutes: 1,
            seconds: 1,
            milliseconds: 1,
            microseconds: 1,
          ),
        );
      });

      test('month drops years', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          firstDateTimeUnit: DateTimeUnit.month,
          precision: DateTimeUnit.usec,
        );
        expect(result.years, isNull);
        expect(result.months, 1);
        expect(result.microseconds, 1);
      });

      test('day drops years and months', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          firstDateTimeUnit: DateTimeUnit.day,
          precision: DateTimeUnit.usec,
        );
        expect(result.years, isNull);
        expect(result.months, isNull);
        expect(result.days, 1);
      });

      test('hour drops days and coarser', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          firstDateTimeUnit: DateTimeUnit.hour,
          precision: DateTimeUnit.usec,
        );
        expect(result.days, isNull);
        expect(result.hours, 1);
      });

      test('minute drops hours and coarser', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          firstDateTimeUnit: DateTimeUnit.minute,
          precision: DateTimeUnit.usec,
        );
        expect(result.hours, isNull);
        expect(result.minutes, 1);
      });

      test('second drops minutes and coarser', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          firstDateTimeUnit: DateTimeUnit.second,
          precision: DateTimeUnit.usec,
        );
        expect(result.minutes, isNull);
        expect(result.seconds, 1);
      });

      test('msec drops seconds and coarser', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          firstDateTimeUnit: DateTimeUnit.msec,
          precision: DateTimeUnit.usec,
        );
        expect(result.seconds, isNull);
        expect(result.milliseconds, 1);
      });

      test('usec reports only microseconds', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          firstDateTimeUnit: DateTimeUnit.usec,
          precision: DateTimeUnit.usec,
        );
        expect(
          result,
          const DateTimeDelta(isFuture: true, microseconds: 1),
        );
      });

      test('dropping coarse units never redistributes their magnitude', () {
        // Starting at days does NOT fold the year and month into the day count.
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          firstDateTimeUnit: DateTimeUnit.day,
        );
        expect(result.days, 1);
      });

      test('coarse units are null even with truncate true', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          firstDateTimeUnit: DateTimeUnit.hour,
        );
        expect(result.years, isNull);
        expect(result.months, isNull);
        expect(result.days, isNull);
      });
    });

    group('filtering: precision with truncate true (default)', () {
      final start = DateTime.utc(2020, 1, 1, 1, 1, 1, 1, 1);
      final end = DateTime.utc(2021, 2, 2, 2, 2, 2, 2, 2);

      test('second (default) zeroes msec and usec', () {
        final result = DateTimeDifference.delta(startTime: start, endTime: end);
        expect(result.seconds, 1);
        expect(result.milliseconds, 0);
        expect(result.microseconds, 0);
      });

      test('year zeroes everything but years', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.year,
        );
        expect(result, allUnits(years: 1));
      });

      test('month zeroes day and finer', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.month,
        );
        expect(result, allUnits(years: 1, months: 1));
      });

      test('day zeroes hour and finer', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.day,
        );
        expect(result, allUnits(years: 1, months: 1, days: 1));
      });

      test('hour zeroes minute and finer', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.hour,
        );
        expect(result, allUnits(years: 1, months: 1, days: 1, hours: 1));
      });

      test('minute zeroes second and finer', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.minute,
        );
        expect(
          result,
          allUnits(years: 1, months: 1, days: 1, hours: 1, minutes: 1),
        );
      });

      test('msec zeroes only usec', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.msec,
        );
        expect(result.milliseconds, 1);
        expect(result.microseconds, 0);
      });

      test('usec zeroes nothing', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.usec,
        );
        expect(result.microseconds, 1);
      });

      test('truncation discards, never rounds', () {
        final result = DateTimeDifference.delta(
          startTime: DateTime.utc(2026),
          endTime: DateTime.utc(2026, 1, 1, 0, 0, 59, 999, 999),
          precision: DateTimeUnit.minute,
        );
        expect(result.minutes, 0);
        expect(result.seconds, 0);
      });
    });

    group('filtering: precision with truncate false', () {
      final start = DateTime.utc(2020, 1, 1, 1, 1, 1, 1, 1);
      final end = DateTime.utc(2021, 2, 2, 2, 2, 2, 2, 2);

      test('second nulls msec and usec', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          truncate: false,
        );
        expect(result.seconds, 1);
        expect(result.milliseconds, isNull);
        expect(result.microseconds, isNull);
      });

      test('year nulls everything but years', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.year,
          truncate: false,
        );
        expect(result, const DateTimeDelta(isFuture: true, years: 1));
      });

      test('month nulls day and finer', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.month,
          truncate: false,
        );
        expect(
          result,
          const DateTimeDelta(isFuture: true, years: 1, months: 1),
        );
      });

      test('day nulls hour and finer', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.day,
          truncate: false,
        );
        expect(
          result,
          const DateTimeDelta(isFuture: true, years: 1, months: 1, days: 1),
        );
      });

      test('hour nulls minute and finer', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.hour,
          truncate: false,
        );
        expect(
          result,
          const DateTimeDelta(
            isFuture: true,
            years: 1,
            months: 1,
            days: 1,
            hours: 1,
          ),
        );
      });

      test('minute nulls second and finer', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.minute,
          truncate: false,
        );
        expect(
          result,
          const DateTimeDelta(
            isFuture: true,
            years: 1,
            months: 1,
            days: 1,
            hours: 1,
            minutes: 1,
          ),
        );
      });

      test('msec nulls only usec', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.msec,
          truncate: false,
        );
        expect(result.milliseconds, 1);
        expect(result.microseconds, isNull);
      });

      test('usec nulls nothing', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.usec,
          truncate: false,
        );
        expect(result.microseconds, 1);
      });

      test('truncate false has no effect on units within the window', () {
        final truncated = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.hour,
        );
        final untruncated = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.hour,
          truncate: false,
        );
        expect(untruncated.years, truncated.years);
        expect(untruncated.months, truncated.months);
        expect(untruncated.days, truncated.days);
        expect(untruncated.hours, truncated.hours);
      });
    });

    group('filtering: combined windows', () {
      final start = DateTime.utc(2020, 1, 1, 1, 1, 1, 1, 1);
      final end = DateTime.utc(2021, 2, 2, 2, 2, 2, 2, 2);

      test('single-unit window (day/day) with truncate', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          firstDateTimeUnit: DateTimeUnit.day,
          precision: DateTimeUnit.day,
        );
        expect(
          result,
          const DateTimeDelta(
            isFuture: true,
            days: 1,
            hours: 0,
            minutes: 0,
            seconds: 0,
            milliseconds: 0,
            microseconds: 0,
          ),
        );
      });

      test('single-unit window (day/day) without truncate', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          firstDateTimeUnit: DateTimeUnit.day,
          precision: DateTimeUnit.day,
          truncate: false,
        );
        expect(result, const DateTimeDelta(isFuture: true, days: 1));
      });

      test('middle window (hour/second) without truncate', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          firstDateTimeUnit: DateTimeUnit.hour,
          truncate: false,
        );
        expect(
          result,
          const DateTimeDelta(
            isFuture: true,
            hours: 1,
            minutes: 1,
            seconds: 1,
          ),
        );
      });

      test('middle window (month/minute) with truncate', () {
        final result = DateTimeDifference.delta(
          startTime: start,
          endTime: end,
          firstDateTimeUnit: DateTimeUnit.month,
          precision: DateTimeUnit.minute,
        );
        expect(
          result,
          const DateTimeDelta(
            isFuture: true,
            months: 1,
            days: 1,
            hours: 1,
            minutes: 1,
            seconds: 0,
            milliseconds: 0,
            microseconds: 0,
          ),
        );
      });

      test('window applies to past-pointing deltas too', () {
        final result = DateTimeDifference.delta(
          startTime: end,
          endTime: start,
          firstDateTimeUnit: DateTimeUnit.day,
          precision: DateTimeUnit.hour,
          truncate: false,
        );
        expect(
          result,
          const DateTimeDelta(isFuture: false, days: 1, hours: 1),
        );
      });

      test('exhaustive matrix of every valid window and truncate flag', () {
        final expected = allUnits(
          years: 1,
          months: 1,
          days: 1,
          hours: 1,
          minutes: 1,
          seconds: 1,
          milliseconds: 1,
          microseconds: 1,
        );

        for (final first in DateTimeUnit.values) {
          for (final precision in DateTimeUnit.values) {
            if (first.index > precision.index) continue;
            for (final truncate in [true, false]) {
              final result = DateTimeDifference.delta(
                startTime: start,
                endTime: end,
                firstDateTimeUnit: first,
                precision: precision,
                truncate: truncate,
              );
              expect(result.isFuture, isTrue);
              for (final unit in DateTimeUnit.values) {
                final reason =
                    'first=$first precision=$precision truncate=$truncate unit=$unit';
                final value = fieldOf(result, unit);
                if (unit.index < first.index) {
                  expect(value, isNull, reason: reason);
                } else if (unit.index > precision.index) {
                  expect(value, truncate ? 0 : isNull, reason: reason);
                } else {
                  expect(value, fieldOf(expected, unit), reason: reason);
                }
              }
            }
          }
        }
      });
    });

    group('consistency', () {
      test(
        'reconstructing the end from the delta round-trips for sub-month spans',
        () {
          final start = DateTime.utc(2026, 3, 10, 7, 45, 12, 345, 678);
          final end = DateTime.utc(2026, 3, 29, 22, 10, 59, 1, 2);
          final delta = full(start, end);

          final rebuilt = start.add(
            Duration(
              days: delta.days!,
              hours: delta.hours!,
              minutes: delta.minutes!,
              seconds: delta.seconds!,
              milliseconds: delta.milliseconds!,
              microseconds: delta.microseconds!,
            ),
          );
          expect(delta.years, 0);
          expect(delta.months, 0);
          expect(rebuilt, end);
        },
      );

      test(
        'adding calendar months then the remainder reconstructs the end',
        () {
          final start = DateTime.utc(2024, 1, 15, 10, 30);
          final end = DateTime.utc(2026, 3, 20, 8, 15);
          final delta = full(start, end);

          final afterCalendar = DateTime.utc(
            start.year + delta.years!,
            start.month + delta.months!,
            start.day,
            start.hour,
            start.minute,
          );
          final rebuilt = afterCalendar.add(
            Duration(
              days: delta.days!,
              hours: delta.hours!,
              minutes: delta.minutes!,
            ),
          );
          expect(rebuilt, end);
        },
      );

      test('every component stays within its natural range', () {
        final pairs = <(DateTime, DateTime)>[
          (
            DateTime.utc(2024, 1, 31, 23, 59, 59, 999, 999),
            DateTime.utc(2024, 3),
          ),
          (
            DateTime.utc(2025, 12, 31, 23, 59, 59, 999, 999),
            DateTime.utc(2026, 2),
          ),
          (
            DateTime.utc(1970),
            DateTime.utc(2026, 10, 21, 12, 34, 56, 789, 123),
          ),
          (DateTime.utc(2026, 3, 31), DateTime.utc(2026, 5)),
        ];
        for (final (start, end) in pairs) {
          final delta = full(start, end);
          expect(delta.months, inInclusiveRange(0, 11), reason: '$start');
          expect(delta.days, inInclusiveRange(0, 31), reason: '$start');
          expect(delta.hours, inInclusiveRange(0, 23), reason: '$start');
          expect(delta.minutes, inInclusiveRange(0, 59), reason: '$start');
          expect(delta.seconds, inInclusiveRange(0, 59), reason: '$start');
          expect(
            delta.milliseconds,
            inInclusiveRange(0, 999),
            reason: '$start',
          );
          expect(
            delta.microseconds,
            inInclusiveRange(0, 999),
            reason: '$start',
          );
        }
      });

      test('results are deterministic across repeated calls', () {
        final start = DateTime.utc(2024, 1, 31, 23);
        final end = DateTime.utc(2024, 3);
        final first = full(start, end);
        for (var i = 0; i < 50; i++) {
          expect(full(start, end), first);
        }
      });
    });
  });
}
