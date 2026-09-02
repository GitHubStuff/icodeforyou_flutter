// packages/extensions/test/datetime/src/datetime_ext_test.dart

import 'package:extensions/datetime/src/datetime_ext.dart' show DateTimeExt;
import 'package:extensions/datetime/src/datetime_unit.dart' show DateTimeUnit;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeExt.unique', () {
    setUp(DateTimeExt.reset);
    tearDown(DateTimeExt.reset);

    test('uses the real clock by default', () async {
      final result = await DateTimeExt.unique();
      expect(result.microsecondsSinceEpoch, greaterThan(0));
    });

    test('returns the clock value when the clock advances', () async {
      final times = [1000000, 1000010];
      var index = 0;
      DateTime now() => DateTime.fromMicrosecondsSinceEpoch(times[index++]);

      final first = await DateTimeExt.unique(now: now);
      final second = await DateTimeExt.unique(now: now);
      expect(first.microsecondsSinceEpoch, 1000000);
      expect(second.microsecondsSinceEpoch, 1000010);
    });

    test('bumps by one microsecond when the clock is stuck', () async {
      DateTime now() => DateTime.fromMicrosecondsSinceEpoch(1000000);

      final first = await DateTimeExt.unique(now: now);
      final second = await DateTimeExt.unique(now: now);
      final third = await DateTimeExt.unique(now: now);
      expect(first.microsecondsSinceEpoch, 1000000);
      expect(second.microsecondsSinceEpoch, 1000001);
      expect(third.microsecondsSinceEpoch, 1000002);
    });

    test('leaves maxDrift alone when the observed drift is smaller', () async {
      DateTime now() => DateTime.fromMicrosecondsSinceEpoch(1000000);

      await DateTimeExt.unique(now: now);
      await DateTimeExt.unique(now: now);
      expect(DateTimeExt.maxDrift, 999);
    });

    test('waits for the clock when drift exceeds the threshold', () async {
      DateTimeExt.driftThreshold = 0;
      var calls = 0;
      DateTime now() {
        calls++;
        return DateTime.fromMicrosecondsSinceEpoch(
          calls <= 4 ? 1000000 : 1000005,
        );
      }

      final first = await DateTimeExt.unique(now: now);
      final second = await DateTimeExt.unique(now: now);
      expect(first.microsecondsSinceEpoch, 1000000);
      expect(second.microsecondsSinceEpoch, 1000005);
      expect(DateTimeExt.maxDrift, 1);
    });

    test('reset restores all static state', () {
      DateTimeExt.maxDrift = 42;
      DateTimeExt.driftThreshold = 1;
      DateTimeExt.reset();
      expect(DateTimeExt.maxDrift, 0);
      expect(DateTimeExt.driftThreshold, 500);
    });
  });

  group('DateTimeExt.isLeapYear', () {
    test('is true for years divisible by 4 but not 100', () {
      expect(DateTime.utc(2024).isLeapYear, isTrue);
    });

    test('is false for century years not divisible by 400', () {
      expect(DateTime.utc(1900).isLeapYear, isFalse);
    });

    test('is true for century years divisible by 400', () {
      expect(DateTime.utc(2000).isLeapYear, isTrue);
    });

    test('is false for a common year', () {
      expect(DateTime.utc(2023).isLeapYear, isFalse);
    });
  });

  group('DateTimeExt.next', () {
    final onBoundary = DateTime.utc(2024);

    test('reports one full unit when sitting exactly on the boundary', () {
      expect(onBoundary.next(DateTimeUnit.usec), 1);
      expect(onBoundary.next(DateTimeUnit.msec), 1000);
      expect(onBoundary.next(DateTimeUnit.second), 1000000);
      expect(onBoundary.next(DateTimeUnit.minute), 60 * 1000000);
      expect(onBoundary.next(DateTimeUnit.hour), 3600 * 1000000);
      expect(onBoundary.next(DateTimeUnit.day), 86400 * 1000000);
      expect(onBoundary.next(DateTimeUnit.month), 31 * 86400 * 1000000);
      // 2024 is a leap year: 366 days.
      expect(onBoundary.next(DateTimeUnit.year), 366 * 86400 * 1000000);
    });

    test('measures to the upcoming boundary mid-unit', () {
      final midSecond = DateTime.utc(2024, 1, 1, 0, 0, 0, 250);
      expect(midSecond.next(DateTimeUnit.second), 750000);
    });

    test('preserves local time when computing the boundary', () {
      final local = DateTime(2024, 6, 15, 10, 30, 30);
      expect(local.next(DateTimeUnit.minute), 30 * 1000000);
    });
  });

  group('DateTimeExt.repeatEvery', () {
    test('ticks until the task returns false (local)', () async {
      var runs = 0;
      final result = await DateTime.now().repeatEvery(DateTimeUnit.usec, () {
        runs++;
        return runs < 3;
      });
      expect(runs, 3);
      expect(result.isUtc, isFalse);
    });

    test('ticks until the task returns false (UTC)', () async {
      var runs = 0;
      final result = await DateTime.now().toUtc().repeatEvery(
        DateTimeUnit.usec,
        () {
          runs++;
          return runs < 2;
        },
      );
      expect(runs, 2);
      expect(result.isUtc, isTrue);
    });
  });

  group('DateTimeExt.timeStamp', () {
    final instant = DateTime.utc(2024, 1, 1, 9, 5, 3, 42);

    test('formats HH:mm:ss with zero padding', () {
      expect(instant.timeStamp(), '09:05:03');
    });

    test('appends zero-padded milliseconds when requested', () {
      expect(instant.timeStamp(showMilliseconds: true), '09:05:03.042');
    });
  });

  group('DateTimeExt.truncate', () {
    final utc = DateTime.utc(2024, 5, 10, 12, 30, 45, 500, 250);

    test('defaults to second precision', () {
      expect(utc.truncate(), DateTime.utc(2024, 5, 10, 12, 30, 45));
    });

    test('truncates to year precision', () {
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.year),
        DateTime.utc(2024),
      );
    });

    test('truncates to day precision', () {
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.day),
        DateTime.utc(2024, 5, 10),
      );
    });

    test('usec precision is the identity', () {
      expect(utc.truncate(atDateTimeUnit: DateTimeUnit.usec), utc);
    });

    test('preserves local time zone', () {
      final local = DateTime(2024, 5, 10, 12, 30, 45, 500, 250);
      final result = local.truncate(atDateTimeUnit: DateTimeUnit.hour);
      expect(result.isUtc, isFalse);
      expect(result, DateTime(2024, 5, 10, 12));
    });
  });
}
