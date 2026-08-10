// test/datetime/src/boundary_timer_test.dart

import 'dart:async';

import 'package:extensions/datetime/src/boundary_timer.dart' show BoundaryTimer;
import 'package:extensions/datetime/src/datetime_unit.dart' show DateTimeUnit;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BoundaryTimer', () {
    test('ticks on each boundary until onTick returns false', () async {
      var ticks = 0;
      final done = Completer<void>();
      final timer = BoundaryTimer(
        unit: DateTimeUnit.usec,
        onTick: () {
          ticks++;
          if (ticks == 3) {
            scheduleMicrotask(done.complete);
            return false;
          }
          return true;
        },
      );

      expect(timer.isActive, isFalse);
      timer.start();
      expect(timer.isActive, isTrue);
      timer.start(); // Idempotent: no second schedule.

      await done.future;
      expect(ticks, 3);
      expect(timer.isActive, isFalse);
    });

    test('supports an injected clock and an async onTick', () async {
      var ticks = 0;
      final done = Completer<void>();
      final timer = BoundaryTimer(
        unit: DateTimeUnit.usec,
        now: () => DateTime.utc(2024),
        onTick: () async {
          ticks++;
          if (ticks == 2) {
            scheduleMicrotask(done.complete);
            return false;
          }
          return true;
        },
      );

      timer.start();
      await done.future;
      expect(ticks, 2);
      expect(timer.isActive, isFalse);
    });

    test('stop cancels a pending wait and is safe to repeat', () async {
      final timer = BoundaryTimer(
        unit: DateTimeUnit.day,
        onTick: () => fail('The tick must never fire after stop.'),
      );

      timer.stop(); // Idle: no-op.
      timer.start();
      expect(timer.isActive, isTrue);
      timer.stop();
      expect(timer.isActive, isFalse);
      timer.stop(); // Already stopped: no-op.

      await Future<void>.delayed(const Duration(milliseconds: 20));
    });

    test('does not reschedule when stopped from inside onTick', () async {
      var ticks = 0;
      late final BoundaryTimer timer;
      timer = BoundaryTimer(
        unit: DateTimeUnit.usec,
        onTick: () {
          ticks++;
          timer.stop();
          return true;
        },
      );

      timer.start();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(ticks, 1);
      expect(timer.isActive, isFalse);
    });

    test('a throwing onTick stops the timer and reports to onError', () async {
      final errored = Completer<void>();
      Object? captured;
      final timer = BoundaryTimer(
        unit: DateTimeUnit.usec,
        onTick: () => throw StateError('boom'),
        onError: (error, stackTrace) {
          captured = error;
          errored.complete();
        },
      );

      timer.start();
      await errored.future;
      expect(captured, isA<StateError>());
      expect(timer.isActive, isFalse);
    });

    test('a throwing onTick without onError still stops cleanly', () async {
      final timer = BoundaryTimer(
        unit: DateTimeUnit.usec,
        onTick: () => throw StateError('boom'),
      );

      timer.start();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(timer.isActive, isFalse);
    });

    test('skips intermediate ticks when onTick work overruns window', () async {
      var ticks = 0;
      final done = Completer<void>();

      final timer = BoundaryTimer(
        unit: DateTimeUnit.usec,
        onTick: () async {
          ticks++;
          // Simulate work that overruns the microsecond boundary window.
          await Future<void>.delayed(const Duration(milliseconds: 10));
          if (ticks == 2) {
            scheduleMicrotask(done.complete);
            return false;
          }
          return true;
        },
      );

      timer.start();
      await done.future;

      // Ensure ticks did not pile up; only 2 executions ran sequentially.
      expect(ticks, 2);
      expect(timer.isActive, isFalse);
    });

    test(
      'recomputes delay dynamically to handle clock drift or shifts',
      () async {
        var currentFakeTime = DateTime.utc(2024, 1, 1, 12, 0, 0);
        var ticks = 0;
        final done = Completer<void>();

        final timer = BoundaryTimer(
          unit: DateTimeUnit.second,
          now: () => currentFakeTime,
          onTick: () {
            ticks++;
            if (ticks == 1) {
              // Simulate clock drift forward (e.g. system time jump).
              currentFakeTime = currentFakeTime.add(const Duration(hours: 1));
              return true;
            }
            scheduleMicrotask(done.complete);
            return false;
          },
        );

        timer.start();

        // Next schedule re-evaluates boundary using the shifted `now` function.
        await done.future;
        expect(ticks, 2);
        expect(timer.isActive, isFalse);
      },
    );
  });
}
