// packages/ext_datetime/test/src/ext_datetime_test.dart

import 'dart:async';

import 'package:ext_datetime/ext_datetime.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExtDateTime', () {
    setUp(ExtDateTime.reset);
    tearDown(ExtDateTime.reset);

    group('uiPattern', () {
      test('is the documented display pattern', () {
        expect(ExtDateTime.uiPattern, 'EEE dd-MMM-yyyy h:mm:ss a');
      });
    });

    group('unique', () {
      test('returns the clock value on first call after reset', () {
        final fixed = DateTime.utc(2026, 1, 15, 10, 30, 45, 123, 456);
        final result = ExtDateTime.unique(now: () => fixed);
        expect(result.microsecondsSinceEpoch, fixed.microsecondsSinceEpoch);
      });

      test('bumps by one microsecond when the clock does not advance', () {
        final fixed = DateTime.utc(2026, 1, 15, 10, 30, 45, 123, 456);
        final base = fixed.microsecondsSinceEpoch;

        final first = ExtDateTime.unique(now: () => fixed);
        final second = ExtDateTime.unique(now: () => fixed);
        final third = ExtDateTime.unique(now: () => fixed);

        expect(first.microsecondsSinceEpoch, base);
        expect(second.microsecondsSinceEpoch, base + 1);
        expect(third.microsecondsSinceEpoch, base + 2);
      });

      test('bumps past the last value when the clock goes backwards', () {
        final later = DateTime.utc(2026, 1, 15, 10, 30, 45, 0, 1000);
        final earlier = DateTime.utc(2026, 1, 15, 10, 30, 45, 0, 500);

        final first = ExtDateTime.unique(now: () => later);
        final second = ExtDateTime.unique(now: () => earlier);

        expect(first.microsecondsSinceEpoch, later.microsecondsSinceEpoch);
        expect(
          second.microsecondsSinceEpoch,
          later.microsecondsSinceEpoch + 1,
        );
      });

      test('follows the clock when it advances', () {
        final t1 = DateTime.utc(2026, 1, 15, 10, 30, 45, 0, 100);
        final t2 = DateTime.utc(2026, 1, 15, 10, 30, 45, 0, 900);

        final first = ExtDateTime.unique(now: () => t1);
        final second = ExtDateTime.unique(now: () => t2);

        expect(first.microsecondsSinceEpoch, t1.microsecondsSinceEpoch);
        expect(second.microsecondsSinceEpoch, t2.microsecondsSinceEpoch);
      });

      test('an instant at the epoch is bumped past the initial zero', () {
        final epoch = DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true);
        final result = ExtDateTime.unique(now: () => epoch);
        expect(result.microsecondsSinceEpoch, 1);
      });

      test('every value in a burst is strictly increasing', () {
        final fixed = DateTime.utc(2026, 1, 15);
        var previous = -1;
        for (var i = 0; i < 1000; i++) {
          final value = ExtDateTime.unique(
            now: () => fixed,
          ).microsecondsSinceEpoch;
          expect(value, greaterThan(previous));
          previous = value;
        }
      });

      test('defaults to DateTime.now', () {
        final before = DateTime.now().microsecondsSinceEpoch;
        final result = ExtDateTime.unique();
        final after = DateTime.now().microsecondsSinceEpoch;
        expect(result.microsecondsSinceEpoch, greaterThanOrEqualTo(before));
        expect(result.microsecondsSinceEpoch, lessThanOrEqualTo(after + 1));
      });
    });

    group('reset', () {
      test(
        'clears the last-seen microsecond so the clock is trusted again',
        () {
          final later = DateTime.utc(2026, 1, 15, 10, 30, 45, 0, 1000);
          final earlier = DateTime.utc(2026, 1, 15, 10, 30, 45, 0, 500);

          ExtDateTime.unique(now: () => later);
          final bumped = ExtDateTime.unique(now: () => earlier);
          expect(
            bumped.microsecondsSinceEpoch,
            later.microsecondsSinceEpoch + 1,
          );

          ExtDateTime.reset();

          final fresh = ExtDateTime.unique(now: () => earlier);
          expect(fresh.microsecondsSinceEpoch, earlier.microsecondsSinceEpoch);
        },
      );
    });

    group('toDisplay', () {
      test('uses uiPattern by default (AM)', () {
        expect(
          DateTime(2026, 3, 27, 5, 9, 4).toDisplay(),
          'Fri 27-Mar-2026 5:09:04 AM',
        );
      });

      test('uses uiPattern by default (PM)', () {
        expect(
          DateTime(2026, 3, 27, 17, 9, 4).toDisplay(),
          'Fri 27-Mar-2026 5:09:04 PM',
        );
      });

      test('renders midnight as 12 AM', () {
        expect(
          DateTime(2026, 10, 21, 0, 0, 7).toDisplay(),
          'Wed 21-Oct-2026 12:00:07 AM',
        );
      });

      test('renders noon as 12 PM', () {
        expect(
          DateTime(2026, 10, 21, 12).toDisplay(),
          'Wed 21-Oct-2026 12:00:00 PM',
        );
      });

      test('zero-pads day but not hour', () {
        expect(
          DateTime(2026, 1, 5, 9, 3, 2).toDisplay(),
          'Mon 05-Jan-2026 9:03:02 AM',
        );
      });

      test('honours a custom pattern', () {
        expect(
          DateTime(2026, 3, 27, 5, 9, 4).toDisplay('yyyy-MM-dd'),
          '2026-03-27',
        );
      });

      test('custom pattern with time fields', () {
        expect(
          DateTime(2026, 3, 27, 17, 9, 4).toDisplay('HH:mm:ss'),
          '17:09:04',
        );
      });

      test('explicit uiPattern matches the default', () {
        final dt = DateTime(2026, 3, 27, 5, 9, 4);
        expect(dt.toDisplay(ExtDateTime.uiPattern), dt.toDisplay());
      });

      test('formats UTC instants using their UTC fields', () {
        expect(
          DateTime.utc(2026, 3, 27, 23, 59, 59).toDisplay(),
          'Fri 27-Mar-2026 11:59:59 PM',
        );
      });
    });

    group('isLeapYear', () {
      test('divisible by 4 is leap', () {
        expect(DateTime(2024).isLeapYear, isTrue);
        expect(DateTime(2028).isLeapYear, isTrue);
        expect(DateTime(1996).isLeapYear, isTrue);
      });

      test('not divisible by 4 is not leap', () {
        expect(DateTime(2025).isLeapYear, isFalse);
        expect(DateTime(2026).isLeapYear, isFalse);
        expect(DateTime(2027).isLeapYear, isFalse);
      });

      test('century not divisible by 400 is not leap', () {
        expect(DateTime(1900).isLeapYear, isFalse);
        expect(DateTime(2100).isLeapYear, isFalse);
        expect(DateTime(1800).isLeapYear, isFalse);
      });

      test('century divisible by 400 is leap', () {
        expect(DateTime(2000).isLeapYear, isTrue);
        expect(DateTime(1600).isLeapYear, isTrue);
        expect(DateTime(2400).isLeapYear, isTrue);
      });

      test('depends only on the year', () {
        expect(DateTime.utc(2024, 12, 31, 23, 59, 59).isLeapYear, isTrue);
        expect(DateTime.utc(2023, 2, 28).isLeapYear, isFalse);
      });
    });

    group('isWithin', () {
      final base = DateTime.utc(2026, 1, 15, 10, 30, 45, 123, 456);

      test('identical instants are within any tolerance, including zero', () {
        expect(base.isWithin(base), isTrue);
        expect(base.isWithin(base, tolerance: Duration.zero), isTrue);
      });

      test('default tolerance is 250 microseconds, inclusive', () {
        final at250 = base.add(const Duration(microseconds: 250));
        final at251 = base.add(const Duration(microseconds: 251));
        expect(base.isWithin(at250), isTrue);
        expect(base.isWithin(at251), isFalse);
      });

      test('is symmetric', () {
        final other = base.add(const Duration(microseconds: 100));
        expect(base.isWithin(other), other.isWithin(base));

        final far = base.add(const Duration(seconds: 1));
        expect(base.isWithin(far), far.isWithin(base));
        expect(base.isWithin(far), isFalse);
      });

      test('handles other preceding this', () {
        final earlier = base.subtract(const Duration(microseconds: 200));
        expect(base.isWithin(earlier), isTrue);
        final tooEarly = base.subtract(const Duration(microseconds: 300));
        expect(base.isWithin(tooEarly), isFalse);
      });

      test('custom tolerance is honoured, inclusive', () {
        const tolerance = Duration(seconds: 5);
        expect(
          base.isWithin(base.add(tolerance), tolerance: tolerance),
          isTrue,
        );
        expect(
          base.isWithin(
            base.add(tolerance + const Duration(microseconds: 1)),
            tolerance: tolerance,
          ),
          isFalse,
        );
      });

      test('zero tolerance rejects any non-identical instant', () {
        final other = base.add(const Duration(microseconds: 1));
        expect(base.isWithin(other, tolerance: Duration.zero), isFalse);
      });

      test('mixing UTC and local compares on the absolute timeline', () {
        final local = base.toLocal();
        expect(base.isWithin(local), isTrue);
        expect(local.isWithin(base), isTrue);
        expect(
          base.isWithin(
            local.add(const Duration(microseconds: 300)),
          ),
          isFalse,
        );
      });

      test('negative tolerance throws ArgumentError naming tolerance', () {
        expect(
          () => base.isWithin(
            base,
            tolerance: const Duration(microseconds: -1),
          ),
          throwsA(
            isA<ArgumentError>()
                .having((e) => e.name, 'name', 'tolerance')
                .having(
                  (e) => e.message,
                  'message',
                  'must be zero or positive',
                ),
          ),
        );
      });
    });

    group('next', () {
      final dt = DateTime.utc(2026, 1, 15, 10, 30, 45, 123, 456);

      test('usec is one microsecond', () {
        expect(dt.next(DateTimeUnit.usec), 1);
      });

      test('msec counts to the next whole millisecond', () {
        expect(dt.next(DateTimeUnit.msec), 544);
      });

      test('second counts to the next whole second', () {
        expect(
          dt.next(DateTimeUnit.second),
          const Duration(milliseconds: 876, microseconds: 544).inMicroseconds,
        );
      });

      test('minute counts to the next whole minute', () {
        expect(
          dt.next(DateTimeUnit.minute),
          const Duration(
            seconds: 14,
            milliseconds: 876,
            microseconds: 544,
          ).inMicroseconds,
        );
      });

      test('hour counts to the top of the next hour', () {
        expect(
          dt.next(DateTimeUnit.hour),
          const Duration(
            minutes: 29,
            seconds: 14,
            milliseconds: 876,
            microseconds: 544,
          ).inMicroseconds,
        );
      });

      test('day counts to the next midnight', () {
        expect(
          dt.next(DateTimeUnit.day),
          const Duration(
            hours: 13,
            minutes: 29,
            seconds: 14,
            milliseconds: 876,
            microseconds: 544,
          ).inMicroseconds,
        );
      });

      test('month counts to the first of next month', () {
        expect(
          dt.next(DateTimeUnit.month),
          const Duration(
            days: 16,
            hours: 13,
            minutes: 29,
            seconds: 14,
            milliseconds: 876,
            microseconds: 544,
          ).inMicroseconds,
        );
      });

      test('year counts to the first of next year', () {
        expect(
          dt.next(DateTimeUnit.year),
          const Duration(
            days: 350,
            hours: 13,
            minutes: 29,
            seconds: 14,
            milliseconds: 876,
            microseconds: 544,
          ).inMicroseconds,
        );
      });

      test('is always strictly positive', () {
        for (final unit in DateTimeUnit.values) {
          expect(dt.next(unit), greaterThan(0), reason: 'next($unit)');
        }
      });

      test('is monotonically non-decreasing from finest to coarsest', () {
        var previous = 0;
        for (final unit in DateTimeUnit.values.reversed) {
          final value = dt.next(unit);
          expect(value, greaterThanOrEqualTo(previous), reason: 'next($unit)');
          previous = value;
        }
      });

      test('an instant exactly on a boundary reports one full unit', () {
        final boundary = DateTime.utc(2026);
        expect(boundary.next(DateTimeUnit.usec), 1);
        expect(boundary.next(DateTimeUnit.msec), 1000);
        expect(boundary.next(DateTimeUnit.second), 1000000);
        expect(
          boundary.next(DateTimeUnit.minute),
          const Duration(minutes: 1).inMicroseconds,
        );
        expect(
          boundary.next(DateTimeUnit.hour),
          const Duration(hours: 1).inMicroseconds,
        );
        expect(
          boundary.next(DateTimeUnit.day),
          const Duration(days: 1).inMicroseconds,
        );
        expect(
          boundary.next(DateTimeUnit.month),
          const Duration(days: 31).inMicroseconds,
        );
        expect(
          boundary.next(DateTimeUnit.year),
          const Duration(days: 365).inMicroseconds,
        );
      });

      test('rollover cascades through every unit at the end of a year', () {
        final lastInstant = DateTime.utc(2026, 12, 31, 23, 59, 59, 999, 999);
        for (final unit in DateTimeUnit.values) {
          expect(lastInstant.next(unit), 1, reason: 'next($unit)');
        }
      });

      test('month boundary respects February in a leap year', () {
        final feb29 = DateTime.utc(2024, 2, 29);
        expect(
          feb29.next(DateTimeUnit.month),
          const Duration(days: 1).inMicroseconds,
        );
        final feb28 = DateTime.utc(2024, 2, 28);
        expect(
          feb28.next(DateTimeUnit.month),
          const Duration(days: 2).inMicroseconds,
        );
      });

      test('month boundary respects February in a common year', () {
        final feb28 = DateTime.utc(2026, 2, 28);
        expect(
          feb28.next(DateTimeUnit.month),
          const Duration(days: 1).inMicroseconds,
        );
      });

      test('year boundary respects a leap year length', () {
        expect(
          DateTime.utc(2024).next(DateTimeUnit.year),
          const Duration(days: 366).inMicroseconds,
        );
      });

      test('day boundary at the end of a 30-day month rolls to next month', () {
        final apr30 = DateTime.utc(2026, 4, 30, 12);
        final after = apr30.add(
          Duration(microseconds: apr30.next(DateTimeUnit.day)),
        );
        expect(after, DateTime.utc(2026, 5));
      });

      test('preserves local zone and lands on a local boundary', () {
        // For a unit U the boundary keeps every unit coarser than U, carries
        // U itself by one, and zeroes (or floors to 1) every unit finer
        // than U. So a field is checked for its floor only when it is
        // strictly finer than U.
        final local = DateTime(2026, 1, 15, 10, 30, 45, 123, 456);
        for (final unit in DateTimeUnit.values) {
          final boundary = local.add(Duration(microseconds: local.next(unit)));
          final reason = 'next($unit)';

          expect(boundary.isUtc, isFalse, reason: reason);

          if (unit.index < DateTimeUnit.usec.index) {
            expect(boundary.microsecond, 0, reason: reason);
          }
          if (unit.index < DateTimeUnit.msec.index) {
            expect(boundary.millisecond, 0, reason: reason);
          }
          if (unit.index < DateTimeUnit.second.index) {
            expect(boundary.second, 0, reason: reason);
          }
          if (unit.index < DateTimeUnit.minute.index) {
            expect(boundary.minute, 0, reason: reason);
          }
          if (unit.index < DateTimeUnit.hour.index) {
            expect(boundary.hour, 0, reason: reason);
          }
          if (unit.index < DateTimeUnit.day.index) {
            expect(boundary.day, 1, reason: reason);
          }
          if (unit.index < DateTimeUnit.month.index) {
            expect(boundary.month, 1, reason: reason);
          }

          switch (unit) {
            case DateTimeUnit.year:
              expect(boundary.year, 2027, reason: reason);
            case DateTimeUnit.month:
              expect(boundary.month, 2, reason: reason);
            case DateTimeUnit.day:
              expect(boundary.day, 16, reason: reason);
            case DateTimeUnit.hour:
              expect(boundary.hour, 11, reason: reason);
            case DateTimeUnit.minute:
              expect(boundary.minute, 31, reason: reason);
            case DateTimeUnit.second:
              expect(boundary.second, 46, reason: reason);
            case DateTimeUnit.msec:
              expect(boundary.millisecond, 124, reason: reason);
            case DateTimeUnit.usec:
              expect(boundary.microsecond, 457, reason: reason);
          }
        }
      });
    });

    group('repeatEvery', () {
      test(
        'returns this unchanged when task declines the first tick',
        () async {
          final start = DateTime.now();
          final result = await start.repeatEvery(
            DateTimeUnit.msec,
            () => false,
          );
          expect(result, same(start));
        },
      );

      test(
        'runs task on every boundary until it returns false (local)',
        () async {
          var ticks = 0;
          final start = DateTime.now();
          final result = await start.repeatEvery(
            DateTimeUnit.msec,
            () => ++ticks < 3,
          );
          expect(ticks, 3);
          expect(result.isUtc, isFalse);
          expect(result.isBefore(start), isFalse);
        },
      );

      test(
        'runs task on every boundary until it returns false (UTC)',
        () async {
          var ticks = 0;
          final start = DateTime.now().toUtc();
          final result = await start.repeatEvery(
            DateTimeUnit.usec,
            () => ++ticks < 4,
          );
          expect(ticks, 4);
          expect(result.isUtc, isTrue);
          expect(result.isBefore(start), isFalse);
        },
      );

      test('first wait is aligned to the receiver, not the live clock', () {
        fakeAsync((fake) {
          var ticks = 0;
          DateTime? result;
          final start = DateTime.utc(2026, 6, 15);

          unawaited(
            start
                .repeatEvery(DateTimeUnit.year, () {
                  ticks++;
                  return false;
                })
                .then((value) => result = value),
          );

          fake.elapse(const Duration(days: 199, hours: 23));
          expect(ticks, 0);
          expect(result, isNull);

          fake.elapse(const Duration(hours: 1));
          expect(ticks, 1);
          expect(result, same(start));
        });
      });

      test('subsequent waits are recomputed from the live clock (UTC)', () {
        fakeAsync((fake) {
          var ticks = 0;
          DateTime? result;
          final start = DateTime.utc(2026, 6, 15);

          unawaited(
            start
                .repeatEvery(DateTimeUnit.year, () => ++ticks < 2)
                .then((value) => result = value),
          );

          fake.elapse(const Duration(days: 200));
          expect(ticks, 1);
          expect(result, isNull);

          // The second wait is based on the real clock, which is at most one
          // (leap) year away from its next year boundary.
          fake.elapse(const Duration(days: 367));
          expect(ticks, 2);
          expect(result, isNotNull);
          expect(result!.isUtc, isTrue);
          expect(identical(result, start), isFalse);
        });
      });

      test('subsequent waits are recomputed from the live clock (local)', () {
        fakeAsync((fake) {
          var ticks = 0;
          DateTime? result;
          final start = DateTime(2026, 1, 15, 12);

          unawaited(
            start
                .repeatEvery(DateTimeUnit.day, () => ++ticks < 2)
                .then((value) => result = value),
          );

          fake.elapse(const Duration(hours: 11));
          expect(ticks, 0);

          fake.elapse(const Duration(hours: 1));
          expect(ticks, 1);
          expect(result, isNull);

          // Real clock is at most 25 hours (DST) from its next midnight.
          fake.elapse(const Duration(hours: 26));
          expect(ticks, 2);
          expect(result, isNotNull);
          expect(result!.isUtc, isFalse);
        });
      });
    });

    group('timeStamp', () {
      test('formats HH:mm:ss without milliseconds by default', () {
        expect(DateTime(2026, 1, 1, 5, 7, 9, 45).timeStamp(), '05:07:09');
      });

      test('appends .SSS when showMilliseconds is true', () {
        expect(
          DateTime(2026, 1, 1, 5, 7, 9, 45).timeStamp(showMilliseconds: true),
          '05:07:09.045',
        );
      });

      test('zero-pads every component', () {
        expect(
          DateTime(2026).timeStamp(showMilliseconds: true),
          '00:00:00.000',
        );
      });

      test('renders the last instant of a day', () {
        expect(
          DateTime(
            2026,
            1,
            1,
            23,
            59,
            59,
            999,
          ).timeStamp(showMilliseconds: true),
          '23:59:59.999',
        );
      });

      test('ignores microseconds', () {
        expect(
          DateTime(
            2026,
            1,
            1,
            12,
            0,
            0,
            1,
            999,
          ).timeStamp(showMilliseconds: true),
          '12:00:00.001',
        );
      });

      test('uses UTC fields for UTC instants', () {
        expect(DateTime.utc(2026, 1, 1, 13, 14, 15).timeStamp(), '13:14:15');
      });
    });

    group('truncate', () {
      final utc = DateTime.utc(2026, 7, 19, 13, 47, 58, 321, 654);

      test('defaults to second precision', () {
        expect(utc.truncate(), DateTime.utc(2026, 7, 19, 13, 47, 58));
      });

      test('usec keeps everything', () {
        expect(utc.truncate(atDateTimeUnit: DateTimeUnit.usec), utc);
      });

      test('msec zeroes microseconds', () {
        expect(
          utc.truncate(atDateTimeUnit: DateTimeUnit.msec),
          DateTime.utc(2026, 7, 19, 13, 47, 58, 321),
        );
      });

      test('second zeroes sub-second units', () {
        expect(
          utc.truncate(atDateTimeUnit: DateTimeUnit.second),
          DateTime.utc(2026, 7, 19, 13, 47, 58),
        );
      });

      test('minute zeroes seconds and below', () {
        expect(
          utc.truncate(atDateTimeUnit: DateTimeUnit.minute),
          DateTime.utc(2026, 7, 19, 13, 47),
        );
      });

      test('hour zeroes minutes and below', () {
        expect(
          utc.truncate(atDateTimeUnit: DateTimeUnit.hour),
          DateTime.utc(2026, 7, 19, 13),
        );
      });

      test('day zeroes the time of day', () {
        expect(
          utc.truncate(atDateTimeUnit: DateTimeUnit.day),
          DateTime.utc(2026, 7, 19),
        );
      });

      test('month floors the day to 1', () {
        expect(
          utc.truncate(atDateTimeUnit: DateTimeUnit.month),
          DateTime.utc(2026, 7),
        );
      });

      test('year floors month and day to 1', () {
        expect(
          utc.truncate(atDateTimeUnit: DateTimeUnit.year),
          DateTime.utc(2026),
        );
      });

      test('preserves UTC', () {
        for (final unit in DateTimeUnit.values) {
          expect(
            utc.truncate(atDateTimeUnit: unit).isUtc,
            isTrue,
            reason: 'truncate($unit)',
          );
        }
      });

      test('preserves local zone', () {
        final local = DateTime(2026, 7, 19, 13, 47, 58, 321, 654);
        for (final unit in DateTimeUnit.values) {
          expect(
            local.truncate(atDateTimeUnit: unit).isUtc,
            isFalse,
            reason: 'truncate($unit)',
          );
        }
      });

      test('local truncation matches the local calendar constructor', () {
        final local = DateTime(2026, 7, 19, 13, 47, 58, 321, 654);
        expect(
          local.truncate(atDateTimeUnit: DateTimeUnit.hour),
          DateTime(2026, 7, 19, 13),
        );
        expect(
          local.truncate(atDateTimeUnit: DateTimeUnit.day),
          DateTime(2026, 7, 19),
        );
        expect(
          local.truncate(atDateTimeUnit: DateTimeUnit.month),
          DateTime(2026, 7),
        );
        expect(
          local.truncate(atDateTimeUnit: DateTimeUnit.year),
          DateTime(2026),
        );
      });

      test('is idempotent', () {
        for (final unit in DateTimeUnit.values) {
          final once = utc.truncate(atDateTimeUnit: unit);
          expect(once.truncate(atDateTimeUnit: unit), once, reason: '$unit');
        }
      });

      test('never moves the instant later', () {
        for (final unit in DateTimeUnit.values) {
          expect(
            utc.truncate(atDateTimeUnit: unit).isAfter(utc),
            isFalse,
            reason: 'truncate($unit)',
          );
        }
      });

      test(
        'an instant already on a year boundary is unchanged at every unit',
        () {
          final clean = DateTime.utc(2026);
          for (final unit in DateTimeUnit.values) {
            expect(
              clean.truncate(atDateTimeUnit: unit),
              clean,
              reason: '$unit',
            );
          }
        },
      );

      test('a month-clean instant is unchanged at month and finer', () {
        final clean = DateTime.utc(2026, 7);
        for (final unit in DateTimeUnit.values) {
          if (unit == DateTimeUnit.year) continue;
          expect(clean.truncate(atDateTimeUnit: unit), clean, reason: '$unit');
        }
        expect(
          clean.truncate(atDateTimeUnit: DateTimeUnit.year),
          DateTime.utc(2026),
        );
      });
    });
  });
}
