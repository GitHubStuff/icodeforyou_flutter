// extensions/test/datetime_ext/boundary_timer_test.dart
import 'package:extensions/datetime_ext/boundary_timer.dart';
import 'package:extensions/datetime_ext/datetime_unit.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BoundaryTimer', () {
    // Tying `now` to FakeAsync's elapsed clock keeps the injected wall clock
    // in lockstep with the virtual timer clock, so boundaries land predictably.
    DateTime Function() clockFrom(FakeAsync async) =>
        () => DateTime.utc(2024).add(async.elapsed);

    test('is idle until started', () {
      final timer = BoundaryTimer(
        unit: DateTimeUnit.second,
        onTick: () => true,
      );

      expect(timer.isActive, isFalse);
    });

    test('fires on each boundary and stays self-correcting', () {
      fakeAsync((async) {
        var ticks = 0;
        final timer = BoundaryTimer(
          unit: DateTimeUnit.second,
          now: clockFrom(async),
          onTick: () {
            ticks++;
            return true;
          },
        );

        timer.start();
        async.elapse(const Duration(seconds: 3));

        expect(ticks, 3);
        expect(timer.isActive, isTrue);

        timer.stop();
      });
    });

    test('stops when onTick returns false', () {
      fakeAsync((async) {
        var ticks = 0;
        final timer = BoundaryTimer(
          unit: DateTimeUnit.second,
          now: clockFrom(async),
          onTick: () {
            ticks++;
            return ticks < 2;
          },
        );

        timer.start();
        async.elapse(const Duration(seconds: 5));

        expect(ticks, 2);
        expect(timer.isActive, isFalse);
      });
    });

    test('start is a no-op while already active', () {
      fakeAsync((async) {
        var ticks = 0;
        final timer = BoundaryTimer(
          unit: DateTimeUnit.second,
          now: clockFrom(async),
          onTick: () {
            ticks++;
            return true;
          },
        )
          ..start()
          ..start();

        async.elapse(const Duration(seconds: 1));

        expect(ticks, 1);
        expect(timer.isActive, isTrue);

        timer.stop();
      });
    });

    test('stop cancels a pending wait and prevents further ticks', () {
      fakeAsync((async) {
        var ticks = 0;
        final timer = BoundaryTimer(
          unit: DateTimeUnit.second,
          now: clockFrom(async),
          onTick: () {
            ticks++;
            return true;
          },
        );

        timer.start();
        async.elapse(const Duration(milliseconds: 500));
        timer.stop();
        async.elapse(const Duration(seconds: 5));

        expect(ticks, 0);
        expect(timer.isActive, isFalse);
      });
    });

    test('stop is a no-op when idle', () {
      final timer = BoundaryTimer(
        unit: DateTimeUnit.second,
        onTick: () => true,
      )..stop();

      expect(timer.isActive, isFalse);
    });

    test('routes a thrown error to onError and stops', () {
      fakeAsync((async) {
        Object? captured;
        final timer = BoundaryTimer(
          unit: DateTimeUnit.second,
          now: clockFrom(async),
          onTick: () => throw StateError('boom'),
          onError: (error, _) => captured = error,
        );

        timer.start();
        async.elapse(const Duration(seconds: 1));

        expect(captured, isA<StateError>());
        expect(timer.isActive, isFalse);
      });
    });

    test('uses DateTime.now by default and tolerates a null onError', () {
      fakeAsync((async) {
        var ticks = 0;
        final timer = BoundaryTimer(
          unit: DateTimeUnit.second,
          onTick: () {
            ticks++;
            throw StateError('x');
          },
        );

        timer.start();
        async.elapse(const Duration(seconds: 2));

        expect(ticks, 1);
        expect(timer.isActive, isFalse);
      });
    });
  });
}
