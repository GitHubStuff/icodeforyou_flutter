// packages/extensions/test/datetime/src/datetime_ext_test.dart
import 'package:extensions/datetime/src/datetime_unit.dart' show DateTimeUnit;
import 'package:extensions/extensions.dart' show DateTimeExt;
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(DateTimeExt.reset);

  group('DateTimeExt.unique and reset', () {
    test('returns unique timestamps across calls with default now()', () async {
      final t1 = await DateTimeExt.unique();
      final t2 = await DateTimeExt.unique();
      expect(t2.microsecondsSinceEpoch, greaterThan(t1.microsecondsSinceEpoch));
    });

    test(
      'increments microsecond when now() yields the same or smaller timestamp',
      () async {
        final fixedTime = DateTime(2026, 1, 1, 12, 0, 0);
        final t1 = await DateTimeExt.unique(now: () => fixedTime);
        final t2 = await DateTimeExt.unique(now: () => fixedTime);
        final t3 = await DateTimeExt.unique(
          now: () => fixedTime.subtract(const Duration(seconds: 10)),
        );

        expect(t1.microsecondsSinceEpoch, fixedTime.microsecondsSinceEpoch);
        expect(t2.microsecondsSinceEpoch, fixedTime.microsecondsSinceEpoch + 1);
        expect(t3.microsecondsSinceEpoch, fixedTime.microsecondsSinceEpoch + 2);
      },
    );

    test('reset clears internal microsecond state', () async {
      final fixedTime = DateTime(2026, 1, 1, 12, 0, 0);
      await DateTimeExt.unique(now: () => fixedTime);
      DateTimeExt.reset();

      final tAfterReset = await DateTimeExt.unique(now: () => fixedTime);
      expect(
        tAfterReset.microsecondsSinceEpoch,
        fixedTime.microsecondsSinceEpoch,
      );
    });
  });

  group('isLeapYear', () {
    test('evaluates Gregorian leap years correctly', () {
      expect(DateTime(2024, 1, 1).isLeapYear, isTrue); // Divisible by 4
      expect(DateTime(2000, 1, 1).isLeapYear, isTrue); // Divisible by 400
      expect(
        DateTime(1900, 1, 1).isLeapYear,
        isFalse,
      ); // Divisible by 100, not 400
      expect(DateTime(2023, 1, 1).isLeapYear, isFalse); // Not divisible by 4
    });
  });

  group('next and _nextBoundary', () {
    test(
      'calculates microseconds to next boundary for all units (local & UTC)',
      () {
        final local = DateTime(2026, 5, 10, 14, 30, 45, 123, 456);
        final utc = DateTime.utc(2026, 5, 10, 14, 30, 45, 123, 456);

        for (final dt in [local, utc]) {
          expect(dt.next(DateTimeUnit.year), greaterThan(0));
          expect(dt.next(DateTimeUnit.month), greaterThan(0));
          expect(dt.next(DateTimeUnit.day), greaterThan(0));
          expect(dt.next(DateTimeUnit.hour), greaterThan(0));
          expect(dt.next(DateTimeUnit.minute), greaterThan(0));
          expect(dt.next(DateTimeUnit.second), greaterThan(0));
          expect(dt.next(DateTimeUnit.msec), greaterThan(0));
          expect(dt.next(DateTimeUnit.usec), greaterThan(0));
        }
      },
    );

    test('matches exact differences to next boundaries', () {
      final dtUtc = DateTime.utc(2026, 1, 1, 0, 0, 0, 0, 0);
      expect(
        dtUtc.next(DateTimeUnit.second),
        equals(Duration.microsecondsPerSecond),
      );
      expect(
        dtUtc.next(DateTimeUnit.usec),
        equals(1),
      );
    });
  });

  group('repeatEvery', () {
    test('repeats and stops on local DateTime when task returns false', () {
      fakeAsync((async) {
        final start = DateTime(2026, 1, 1, 0, 0, 0, 0, 0);
        int runCount = 0;
        DateTime? finalBasis;

        start
            .repeatEvery(DateTimeUnit.usec, () {
              runCount++;
              return runCount < 3;
            })
            .then((result) {
              finalBasis = result;
            });

        async.elapse(const Duration(milliseconds: 10));
        expect(runCount, equals(3));
        expect(finalBasis, isNotNull);
        expect(finalBasis!.isUtc, isFalse);
      });
    });

    test('repeats and stops on UTC DateTime when task returns false', () {
      fakeAsync((async) {
        final start = DateTime.utc(2026, 1, 1, 0, 0, 0, 0, 0);
        int runCount = 0;
        DateTime? finalBasis;

        start
            .repeatEvery(DateTimeUnit.usec, () {
              runCount++;
              return runCount < 2;
            })
            .then((result) {
              finalBasis = result;
            });

        async.elapse(const Duration(milliseconds: 10));
        expect(runCount, equals(2));
        expect(finalBasis, isNotNull);
        expect(finalBasis!.isUtc, isTrue);
      });
    });

    test('terminates immediately on the first tick if task returns false', () {
      fakeAsync((async) {
        final start = DateTime.utc(2026, 1, 1, 0, 0, 0, 0, 0);
        int runCount = 0;
        DateTime? finalBasis;

        start
            .repeatEvery(DateTimeUnit.usec, () {
              runCount++;
              return false;
            })
            .then((result) {
              finalBasis = result;
            });

        async.elapse(const Duration(milliseconds: 1));
        expect(runCount, equals(1));
        expect(finalBasis, equals(start));
      });
    });
  });

  group('timeStamp', () {
    test('formats time string without milliseconds', () {
      final dt = DateTime(2026, 1, 1, 9, 5, 7, 45);
      expect(dt.timeStamp(), equals('09:05:07'));
      expect(dt.timeStamp(showMilliseconds: false), equals('09:05:07'));
    });

    test('formats time string with milliseconds', () {
      final dt = DateTime(2026, 1, 1, 14, 30, 45, 7);
      expect(dt.timeStamp(showMilliseconds: true), equals('14:30:45.007'));
    });
  });

  group('truncate', () {
    test('truncates local and UTC DateTime at various unit precisions', () {
      final local = DateTime(2026, 8, 15, 14, 30, 45, 123, 456);
      final utc = DateTime.utc(2026, 8, 15, 14, 30, 45, 123, 456);

      // Default truncate (atDateTimeUnit = DateTimeUnit.second)
      final truncatedDefault = local.truncate();
      expect(truncatedDefault, equals(DateTime(2026, 8, 15, 14, 30, 45, 0, 0)));
      expect(truncatedDefault.isUtc, isFalse);

      final truncatedUtcDefault = utc.truncate();
      expect(
        truncatedUtcDefault,
        equals(DateTime.utc(2026, 8, 15, 14, 30, 45, 0, 0)),
      );
      expect(truncatedUtcDefault.isUtc, isTrue);

      // Truncate at year
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.year),
        equals(DateTime.utc(2026, 1, 1, 0, 0, 0, 0, 0)),
      );

      // Truncate at month
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.month),
        equals(DateTime.utc(2026, 8, 1, 0, 0, 0, 0, 0)),
      );

      // Truncate at day
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.day),
        equals(DateTime.utc(2026, 8, 15, 0, 0, 0, 0, 0)),
      );

      // Truncate at hour
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.hour),
        equals(DateTime.utc(2026, 8, 15, 14, 0, 0, 0, 0)),
      );

      // Truncate at minute
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.minute),
        equals(DateTime.utc(2026, 8, 15, 14, 30, 0, 0, 0)),
      );

      // Truncate at msec
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.msec),
        equals(DateTime.utc(2026, 8, 15, 14, 30, 45, 123, 0)),
      );

      // Truncate at usec (finest unit, next is null -> preserves everything)
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.usec),
        equals(DateTime.utc(2026, 8, 15, 14, 30, 45, 123, 456)),
      );
    });
  });
}
