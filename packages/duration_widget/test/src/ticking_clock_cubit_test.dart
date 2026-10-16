// packages/duration_widget/test/src/ticking_clock_cubit_test.dart

import 'dart:async';

import 'package:duration_widget/src/ticking_clock_cubit.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TickingClockCubit', () {
    final start = DateTime(2026, 1, 1, 12);
    const interval = Duration(seconds: 1);

    group('constructor', () {
      test('initial state is the start time and interval is stored', () {
        fakeAsync((async) {
          final cubit = TickingClockCubit(start, interval);

          expect(cubit.state, start);
          expect(cubit.interval, interval);

          unawaited(cubit.close());
          async.flushMicrotasks();
        });
      });

      test('throws an AssertionError for a zero interval', () {
        expect(
          () => TickingClockCubit(start, Duration.zero),
          throwsAssertionError,
        );
      });

      test('throws an AssertionError for a negative interval', () {
        expect(
          () => TickingClockCubit(start, const Duration(seconds: -1)),
          throwsAssertionError,
        );
      });
    });

    group('ticking', () {
      test('does not emit before the first interval elapses', () {
        fakeAsync((async) {
          final cubit = TickingClockCubit(start, interval);

          async.elapse(interval - const Duration(milliseconds: 1));
          expect(cubit.state, start);

          unawaited(cubit.close());
          async.flushMicrotasks();
        });
      });

      test('advances state by interval on every tick', () {
        fakeAsync((async) {
          final cubit = TickingClockCubit(start, interval);

          async.elapse(interval);
          expect(cubit.state, start.add(interval));

          async.elapse(interval);
          expect(cubit.state, start.add(interval * 2));

          async.elapse(interval);
          expect(cubit.state, start.add(interval * 3));

          unawaited(cubit.close());
          async.flushMicrotasks();
        });
      });

      test('emits each ticked DateTime on the stream', () {
        fakeAsync((async) {
          final cubit = TickingClockCubit(start, interval);
          final emitted = <DateTime>[];
          final subscription = cubit.stream.listen(emitted.add);

          async.elapse(interval * 3);

          expect(emitted, [
            start.add(interval),
            start.add(interval * 2),
            start.add(interval * 3),
          ]);

          unawaited(subscription.cancel());
          unawaited(cubit.close());
          async.flushMicrotasks();
        });
      });

      test('honours a custom interval', () {
        fakeAsync((async) {
          const custom = Duration(minutes: 5);
          final cubit = TickingClockCubit(start, custom);

          async.elapse(const Duration(minutes: 4, seconds: 59));
          expect(cubit.state, start);

          async.elapse(const Duration(seconds: 1));
          expect(cubit.state, start.add(custom));

          unawaited(cubit.close());
          async.flushMicrotasks();
        });
      });
    });

    group('close', () {
      test('closes the cubit', () {
        fakeAsync((async) {
          final cubit = TickingClockCubit(start, interval);

          unawaited(cubit.close());
          async.flushMicrotasks();

          expect(cubit.isClosed, isTrue);
        });
      });

      test('cancels the timer so no further states are emitted', () {
        fakeAsync((async) {
          final cubit = TickingClockCubit(start, interval);
          final emitted = <DateTime>[];
          final subscription = cubit.stream.listen(emitted.add);

          async.elapse(interval);
          expect(cubit.state, start.add(interval));

          unawaited(cubit.close());
          async.flushMicrotasks();

          // A live periodic timer would call emit() on a closed cubit here,
          // which throws; a cancelled timer leaves state untouched.
          async.elapse(interval * 10);

          expect(cubit.state, start.add(interval));
          expect(emitted, [start.add(interval)]);
          expect(async.periodicTimerCount, 0);

          unawaited(subscription.cancel());
          async.flushMicrotasks();
        });
      });
    });
  });
}
