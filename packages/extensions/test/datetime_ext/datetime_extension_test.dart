// extensions/test/datetime_ext/datetime_extension_test.dart
import 'dart:async';

import 'package:extensions/datetime_ext/datetime_extension.dart';
import 'package:extensions/datetime_ext/datetime_unit.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeExt', () {
    group('next', () {
      final utc = DateTime.utc(2024, 3, 15, 10, 30, 45, 123, 456);

      test('counts to the next microsecond', () {
        expect(utc.next(DateTimeUnit.usec), 1);
      });

      test('counts to the next millisecond', () {
        expect(utc.next(DateTimeUnit.msec), 544);
      });

      test('counts to the next second', () {
        expect(utc.next(DateTimeUnit.second), 876544);
      });

      test('counts to the next minute', () {
        expect(utc.next(DateTimeUnit.minute), 14876544);
      });

      test('counts to the next hour', () {
        expect(utc.next(DateTimeUnit.hour), 1754876544);
      });

      test('counts to the next day', () {
        expect(utc.next(DateTimeUnit.day), 48554876544);
      });

      test('counts to the first of the next month', () {
        expect(
          utc.next(DateTimeUnit.month),
          DateTime.utc(2024, 4).difference(utc).inMicroseconds,
        );
      });

      test('counts to the start of the next year', () {
        expect(
          utc.next(DateTimeUnit.year),
          DateTime.utc(2025).difference(utc).inMicroseconds,
        );
      });

      test('reports a full unit when already on a boundary', () {
        final onBoundary = DateTime.utc(2024);
        expect(onBoundary.next(DateTimeUnit.second), 1000000);
        expect(onBoundary.next(DateTimeUnit.day), 86400000000);
      });

      test('preserves the local zone', () {
        final local = DateTime(2024, 3, 15, 10, 30, 45, 123, 456);
        expect(
          local.next(DateTimeUnit.minute),
          DateTime(2024, 3, 15, 10, 31).difference(local).inMicroseconds,
        );
      });
    });

    group('repeatEvery', () {
      test('returns the receiver when the first tick stops the loop', () {
        fakeAsync((async) {
          final start = DateTime.utc(2024);
          DateTime? result;
          unawaited(
            start
                .repeatEvery(DateTimeUnit.second, () => false)
                .then((value) => result = value),
          );

          async.elapse(const Duration(seconds: 1));

          expect(result, start);
        });
      });

      test('re-aligns from the live clock between ticks (utc)', () {
        fakeAsync((async) {
          final start = DateTime.utc(2024);
          var ticks = 0;
          unawaited(
            start.repeatEvery(DateTimeUnit.second, () {
              ticks++;
              return ticks < 2;
            }),
          );

          async.elapse(const Duration(seconds: 4));

          expect(ticks, 2);
        });
      });

      test('re-aligns from the live clock between ticks (local)', () {
        fakeAsync((async) {
          final start = DateTime(2024);
          var ticks = 0;
          unawaited(
            start.repeatEvery(DateTimeUnit.second, () {
              ticks++;
              return ticks < 2;
            }),
          );

          async.elapse(const Duration(seconds: 4));

          expect(ticks, 2);
        });
      });
    });

    group('timeStamp', () {
      final instant = DateTime(2024, 1, 1, 9, 5, 3, 7);

      test('omits milliseconds by default', () {
        expect(instant.timeStamp(), '09:05:03');
      });

      test('includes milliseconds when requested', () {
        expect(instant.timeStamp(showMilliseconds: true), '09:05:03.007');
      });
    });

    group('truncate', () {
      // DateTimeExt and DateTimeExtensions both declare `truncate`, so apply
      // this extension explicitly to exercise *this* file's implementation.
      final utc = DateTime.utc(2024, 3, 15, 10, 30, 45, 123, 456);

      test('truncates to the second by default', () {
        expect(
          DateTimeExt(utc).truncate(),
          DateTime.utc(2024, 3, 15, 10, 30, 45),
        );
      });

      test('truncates to a coarser unit', () {
        expect(
          DateTimeExt(utc).truncate(atDateTimeUnit: DateTimeUnit.day),
          DateTime.utc(2024, 3, 15),
        );
      });

      test('returns an identical instant at microsecond precision', () {
        expect(
          DateTimeExt(utc).truncate(atDateTimeUnit: DateTimeUnit.usec),
          utc,
        );
      });

      test('preserves the local zone', () {
        final local = DateTime(2024, 3, 15, 10, 30, 45, 123, 456);
        final result =
            DateTimeExt(local).truncate(atDateTimeUnit: DateTimeUnit.hour);
        expect(result, DateTime(2024, 3, 15, 10));
        expect(result.isUtc, isFalse);
      });
    });

    group('unique', () {
      setUp(DateTimeExt.reset);
      tearDown(DateTimeExt.reset);

      DateTime Function() clockAt(int Function() micros) =>
          () => DateTime.fromMicrosecondsSinceEpoch(micros(), isUtc: true);

      test('returns the wall-clock instant when it has advanced', () {
        fakeAsync((async) {
          var micros = 1000;
          final clock = clockAt(() => micros);

          DateTime? first;
          unawaited(DateTimeExt.unique(now: clock).then((v) => first = v));
          async.flushMicrotasks();
          expect(first!.microsecondsSinceEpoch, 1000);

          micros = 2000;
          DateTime? second;
          unawaited(DateTimeExt.unique(now: clock).then((v) => second = v));
          async.flushMicrotasks();
          expect(second!.microsecondsSinceEpoch, 2000);
          expect(DateTimeExt.maxDrift, 0);
        });
      });

      test('bumps by a microsecond when the clock has stalled', () {
        fakeAsync((async) {
          var micros = 1000;
          final clock = clockAt(() => micros);

          unawaited(DateTimeExt.unique(now: clock));
          async.flushMicrotasks();

          DateTime? stalled;
          unawaited(DateTimeExt.unique(now: clock).then((v) => stalled = v));
          async.flushMicrotasks();

          expect(stalled!.microsecondsSinceEpoch, 1001);
          expect(DateTimeExt.maxDrift, 1);
        });
      });

      test('keeps the largest drift seen', () {
        fakeAsync((async) {
          var micros = 1000;
          final clock = clockAt(() => micros);

          unawaited(DateTimeExt.unique(now: clock));
          async.flushMicrotasks();
          unawaited(DateTimeExt.unique(now: clock));
          async.flushMicrotasks();
          expect(DateTimeExt.maxDrift, 1);

          micros = 1001;
          unawaited(DateTimeExt.unique(now: clock));
          async.flushMicrotasks();
          expect(DateTimeExt.maxDrift, 1);
        });
      });

      test('waits for the clock when drift exceeds the threshold', () {
        fakeAsync((async) {
          DateTimeExt.driftThreshold = 0;
          var micros = 1000;
          final clock = clockAt(() => micros);

          unawaited(DateTimeExt.unique(now: clock));
          async.flushMicrotasks();

          DateTime? waited;
          unawaited(DateTimeExt.unique(now: clock).then((v) => waited = v));
          // Parked on Future.delayed(1ms); jump the clock past currentMicros
          // and fire the delay so the wait loop exits.
          micros = 5000;
          async.elapse(const Duration(milliseconds: 1));

          expect(waited!.microsecondsSinceEpoch, 5000);
        });
      });

      test('uses the system clock by default', () async {
        final a = await DateTimeExt.unique();
        final b = await DateTimeExt.unique();
        expect(b.microsecondsSinceEpoch, greaterThan(a.microsecondsSinceEpoch));
      });
    });
  });
}
