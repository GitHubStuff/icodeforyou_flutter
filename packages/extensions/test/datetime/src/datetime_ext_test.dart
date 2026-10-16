// packages/extensions/test/datetime/src/datetime_ext_test.dart

import 'package:extensions/datetime/src/datetime_ext.dart' show DateTimeExt;
import 'package:extensions/datetime/src/datetime_unit.dart' show DateTimeUnit;
import 'package:fake_async/fake_async.dart' show FakeAsync;
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Sunday 11 October 2026, 05:09:04.123456 — used throughout as a fixed,
  // known instant with every component non-zero and non-minimal.
  final utc = DateTime.utc(2026, 10, 11, 5, 9, 4, 123, 456);
  final local = DateTime(2026, 10, 11, 5, 9, 4, 123, 456);

  group('DateTimeExt.unique', () {
    setUp(DateTimeExt.reset);
    tearDown(DateTimeExt.reset);

    test('returns the clock value when it is ahead of the last result', () {
      final result = DateTimeExt.unique(
        now: () => DateTime.fromMicrosecondsSinceEpoch(1000),
      );

      expect(result.microsecondsSinceEpoch, 1000);
    });

    test('bumps by one microsecond when the clock has not advanced', () {
      DateTime frozen() => DateTime.fromMicrosecondsSinceEpoch(1000);

      final first = DateTimeExt.unique(now: frozen);
      final second = DateTimeExt.unique(now: frozen);
      final third = DateTimeExt.unique(now: frozen);

      expect(first.microsecondsSinceEpoch, 1000);
      expect(second.microsecondsSinceEpoch, 1001);
      expect(third.microsecondsSinceEpoch, 1002);
    });

    test('bumps past the last result when the clock goes backwards', () {
      DateTimeExt.unique(
        now: () => DateTime.fromMicrosecondsSinceEpoch(5000),
      );

      final result = DateTimeExt.unique(
        now: () => DateTime.fromMicrosecondsSinceEpoch(4000),
      );

      expect(result.microsecondsSinceEpoch, 5001);
    });

    test('uses DateTime.now by default', () {
      final before = DateTime.now();
      final result = DateTimeExt.unique();
      final after = DateTime.now();

      expect(result.isBefore(before), isFalse);
      expect(result.isAfter(after), isFalse);
    });

    test('reset clears the high-water mark', () {
      DateTimeExt.unique(
        now: () => DateTime.fromMicrosecondsSinceEpoch(9000),
      );

      DateTimeExt.reset();

      final result = DateTimeExt.unique(
        now: () => DateTime.fromMicrosecondsSinceEpoch(10),
      );
      expect(result.microsecondsSinceEpoch, 10);
    });
  });

  group('DateTimeExt.toDisplay', () {
    test('uses displayPattern by default', () {
      expect(utc.toDisplay(), 'Sun 11-Oct-2026 5:09:04 AM');
    });

    test('renders PM hours in 12-hour form', () {
      final afternoon = DateTime.utc(2026, 10, 11, 17, 9, 4);

      expect(afternoon.toDisplay(), 'Sun 11-Oct-2026 5:09:04 PM');
    });

    test('honours a custom pattern', () {
      expect(utc.toDisplay('yyyy-MM-dd'), '2026-10-11');
    });

    test('displayPattern is the documented default', () {
      expect(DateTimeExt.displayPattern, 'EEE dd-MMM-yyyy h:mm:ss a');
    });
  });

  group('DateTimeExt.isLeapYear', () {
    test('divisible by 4 but not 100 is a leap year', () {
      expect(DateTime.utc(2024).isLeapYear, isTrue);
    });

    test('divisible by 400 is a leap year', () {
      expect(DateTime.utc(2000).isLeapYear, isTrue);
    });

    test('divisible by 100 but not 400 is not a leap year', () {
      expect(DateTime.utc(1900).isLeapYear, isFalse);
      expect(DateTime.utc(2100).isLeapYear, isFalse);
    });

    test('not divisible by 4 is not a leap year', () {
      expect(DateTime.utc(2023).isLeapYear, isFalse);
    });
  });

  group('DateTimeExt.isWithin', () {
    test('throws ArgumentError for a negative tolerance', () {
      expect(
        () => utc.isWithin(utc, tolerance: const Duration(microseconds: -1)),
        throwsA(
          isA<ArgumentError>()
              .having((e) => e.name, 'name', 'tolerance')
              .having((e) => e.message, 'message', 'must be zero or positive'),
        ),
      );
    });

    test('is true at exactly the default tolerance', () {
      final other = utc.add(const Duration(microseconds: 250));

      expect(utc.isWithin(other), isTrue);
    });

    test('is false one microsecond past the default tolerance', () {
      final other = utc.add(const Duration(microseconds: 251));

      expect(utc.isWithin(other), isFalse);
    });

    test('is true for identical instants with zero tolerance', () {
      expect(utc.isWithin(utc, tolerance: Duration.zero), isTrue);
    });

    test('is symmetric', () {
      final other = utc.subtract(const Duration(milliseconds: 5));
      const tolerance = Duration(milliseconds: 5);

      expect(utc.isWithin(other, tolerance: tolerance), isTrue);
      expect(other.isWithin(utc, tolerance: tolerance), isTrue);
    });

    test('compares UTC and local on the absolute timeline', () {
      final asLocal = utc.toLocal();

      expect(utc.isWithin(asLocal, tolerance: Duration.zero), isTrue);
    });
  });

  group('DateTimeExt.next', () {
    test('year counts to 1 January of next year', () {
      final expected = DateTime.utc(2027).difference(utc).inMicroseconds;

      expect(utc.next(DateTimeUnit.year), expected);
    });

    test('month counts to the first of next month', () {
      final expected = DateTime.utc(2026, 11).difference(utc).inMicroseconds;

      expect(utc.next(DateTimeUnit.month), expected);
    });

    test('day counts to next midnight', () {
      final expected = DateTime.utc(
        2026,
        10,
        12,
      ).difference(utc).inMicroseconds;

      expect(utc.next(DateTimeUnit.day), expected);
    });

    test('hour counts to the top of next hour', () {
      final expected = DateTime.utc(
        2026,
        10,
        11,
        6,
      ).difference(utc).inMicroseconds;

      expect(utc.next(DateTimeUnit.hour), expected);
    });

    test('minute counts to the top of next minute', () {
      final expected = DateTime.utc(
        2026,
        10,
        11,
        5,
        10,
      ).difference(utc).inMicroseconds;

      expect(utc.next(DateTimeUnit.minute), expected);
    });

    test('second counts to the top of next second', () {
      // 04.123456 → 05.000000
      expect(utc.next(DateTimeUnit.second), 876544);
    });

    test('msec counts to the next millisecond', () {
      // .123456 → .124000
      expect(utc.next(DateTimeUnit.msec), 544);
    });

    test('usec counts exactly one microsecond', () {
      expect(utc.next(DateTimeUnit.usec), 1);
    });

    test('is strictly positive on an exact boundary', () {
      final boundary = DateTime.utc(2026, 10, 11);

      expect(
        boundary.next(DateTimeUnit.day),
        const Duration(days: 1).inMicroseconds,
      );
    });

    test('cascades rollover through month and year', () {
      final newYearsEve = DateTime.utc(2026, 12, 31, 23, 59, 59, 999, 999);

      expect(newYearsEve.next(DateTimeUnit.usec), 1);
      expect(newYearsEve.next(DateTimeUnit.second), 1);
      expect(
        newYearsEve.add(
          Duration(microseconds: newYearsEve.next(DateTimeUnit.day)),
        ),
        DateTime.utc(2027),
      );
    });

    test('preserves local zone', () {
      final boundary = local.add(
        Duration(microseconds: local.next(DateTimeUnit.day)),
      );

      expect(boundary.isUtc, isFalse);
      expect(boundary.isAtSameMomentAs(DateTime(2026, 10, 12)), isTrue);
    });
  });

  group('DateTimeExt.repeatEvery', () {
    test('returns this when task stops on the first tick', () {
      FakeAsync().run((async) {
        DateTime? result;
        var calls = 0;

        utc
            .repeatEvery(DateTimeUnit.usec, () {
              calls++;
              return false;
            })
            .then((value) => result = value);

        async.elapse(const Duration(microseconds: 10));

        expect(calls, 1);
        expect(result, utc);
      });
    });

    test('re-bases on the live UTC clock after each tick', () {
      FakeAsync().run((async) {
        DateTime? result;
        var calls = 0;

        utc
            .repeatEvery(DateTimeUnit.usec, () {
              calls++;
              return calls < 3;
            })
            .then((value) => result = value);

        async.elapse(const Duration(microseconds: 10));

        expect(calls, 3);
        expect(result, isNotNull);
        expect(result!.isUtc, isTrue);
        expect(result, isNot(utc));
      });
    });

    test('re-bases on the live local clock after each tick', () {
      FakeAsync().run((async) {
        DateTime? result;
        var calls = 0;

        local
            .repeatEvery(DateTimeUnit.usec, () {
              calls++;
              return calls < 2;
            })
            .then((value) => result = value);

        async.elapse(const Duration(microseconds: 10));

        expect(calls, 2);
        expect(result, isNotNull);
        expect(result!.isUtc, isFalse);
        expect(result, isNot(local));
      });
    });

    test('waits the full boundary before the first tick', () {
      FakeAsync().run((async) {
        var calls = 0;

        utc.repeatEvery(DateTimeUnit.second, () {
          calls++;
          return false;
        });

        // 04.123456 → 05.000000 is 876_544 µs.
        async.elapse(const Duration(microseconds: 876543));
        expect(calls, 0);

        async.elapse(const Duration(microseconds: 1));
        expect(calls, 1);
      });
    });
  });

  group('DateTimeExt.timeStamp', () {
    test('formats HH:mm:ss without milliseconds by default', () {
      expect(utc.timeStamp(), '05:09:04');
    });

    test('appends zero-padded milliseconds when requested', () {
      expect(utc.timeStamp(showMilliseconds: true), '05:09:04.123');
    });

    test('pads every component', () {
      final early = DateTime.utc(2026, 1, 1, 0, 0, 0, 7);

      expect(early.timeStamp(showMilliseconds: true), '00:00:00.007');
    });
  });

  group('DateTimeExt.truncate', () {
    test('defaults to second', () {
      expect(utc.truncate(), DateTime.utc(2026, 10, 11, 5, 9, 4));
    });

    test('year keeps only the year', () {
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.year),
        DateTime.utc(2026),
      );
    });

    test('month keeps year and month', () {
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.month),
        DateTime.utc(2026, 10),
      );
    });

    test('day keeps through day', () {
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.day),
        DateTime.utc(2026, 10, 11),
      );
    });

    test('hour keeps through hour', () {
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.hour),
        DateTime.utc(2026, 10, 11, 5),
      );
    });

    test('minute keeps through minute', () {
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.minute),
        DateTime.utc(2026, 10, 11, 5, 9),
      );
    });

    test('second keeps through second', () {
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.second),
        DateTime.utc(2026, 10, 11, 5, 9, 4),
      );
    });

    test('msec keeps through millisecond', () {
      expect(
        utc.truncate(atDateTimeUnit: DateTimeUnit.msec),
        DateTime.utc(2026, 10, 11, 5, 9, 4, 123),
      );
    });

    test('usec keeps everything', () {
      expect(utc.truncate(atDateTimeUnit: DateTimeUnit.usec), utc);
    });

    test('preserves UTC', () {
      expect(utc.truncate().isUtc, isTrue);
    });

    test('preserves local', () {
      final truncated = local.truncate(atDateTimeUnit: DateTimeUnit.hour);

      expect(truncated.isUtc, isFalse);
      expect(truncated, DateTime(2026, 10, 11, 5));
    });
  });
}
