// packages/counter_ring/test/src/cubit/counter_ring_cubit_test.dart
import 'dart:async';

import 'package:counter_ring/counter_ring.dart'
    show CounterRingCubit, CounterRingState, CounterRingStatus;
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const interval = Duration(milliseconds: 100);

  CounterRingCubit buildCubit({
    double start = 0,
    double finish = 100,
    double step = 10,
  }) => CounterRingCubit(
    start: start,
    finish: finish,
    step: step,
    interval: interval,
  );

  group('CounterRingCubit', () {
    group('constructor', () {
      test('throws when start equals finish', () {
        expect(
          () => CounterRingCubit(start: 5, finish: 5),
          throwsAssertionError,
        );
      });

      test('throws when step is zero', () {
        expect(
          () => CounterRingCubit(step: 0),
          throwsAssertionError,
        );
      });

      test('throws when step is negative', () {
        expect(
          () => CounterRingCubit(step: -1),
          throwsAssertionError,
        );
      });

      test('uses default start, finish, step, and interval', () async {
        final cubit = CounterRingCubit();
        addTearDown(cubit.close);

        expect(cubit.interval, const Duration(seconds: 1));
        expect(cubit.state.start, 0);
        expect(cubit.state.finish, 100);
        expect(cubit.state.step, 10);
        expect(cubit.state.currentValue, 0);
        expect(cubit.state.isRunning, isFalse);
        expect(cubit.state.isFinished, isFalse);
      });

      test('exposes the configured interval', () async {
        final cubit = buildCubit();
        addTearDown(cubit.close);

        expect(cubit.interval, interval);
      });

      test('seeds state from start, finish, and step', () async {
        final cubit = buildCubit(start: 20, finish: 80, step: 5);
        addTearDown(cubit.close);

        expect(cubit.state.start, 20);
        expect(cubit.state.finish, 80);
        expect(cubit.state.step, 5);
        expect(cubit.state.currentValue, 20);
      });
    });

    group('start', () {
      test('transitions to running and begins ticking', () {
        fakeAsync((async) {
          final cubit = buildCubit();
          addTearDown(cubit.close);

          cubit.start();

          expect(cubit.state.status, CounterRingStatus.running);
          expect(cubit.state.currentValue, 0);

          async.elapse(interval);
          expect(cubit.state.currentValue, 10);

          async.elapse(interval);
          expect(cubit.state.currentValue, 20);
        });
      });

      test('does nothing when already running', () {
        fakeAsync((async) {
          final cubit = buildCubit();
          addTearDown(cubit.close);
          final emitted = <CounterRingState>[];
          cubit.stream.listen(emitted.add);

          cubit.start();
          async.flushMicrotasks();
          expect(emitted, hasLength(1));

          cubit.start();
          async.flushMicrotasks();
          expect(emitted, hasLength(1));

          // A second timer must not have been scheduled.
          async.elapse(interval);
          expect(cubit.state.currentValue, 10);
        });
      });

      test('does nothing when finished', () {
        fakeAsync((async) {
          final cubit = buildCubit(step: 50);
          addTearDown(cubit.close);

          cubit.start();
          async.elapse(interval * 2);
          expect(cubit.state.isFinished, isTrue);

          final emitted = <CounterRingState>[];
          cubit.stream.listen(emitted.add);

          cubit.start();
          async.flushMicrotasks();
          async.elapse(interval);

          expect(emitted, isEmpty);
          expect(cubit.state.status, CounterRingStatus.finished);
          expect(cubit.state.currentValue, 100);
        });
      });

      test('counts downwards when finish is below start', () {
        fakeAsync((async) {
          final cubit = buildCubit(start: 100, finish: 0, step: 25);
          addTearDown(cubit.close);

          cubit.start();

          async.elapse(interval);
          expect(cubit.state.currentValue, 75);

          async.elapse(interval);
          expect(cubit.state.currentValue, 50);
        });
      });
    });

    group('stop', () {
      test('pauses at the current value and transitions to stopped', () {
        fakeAsync((async) {
          final cubit = buildCubit();
          addTearDown(cubit.close);

          cubit.start();
          async.elapse(interval * 3);
          expect(cubit.state.currentValue, 30);

          cubit.stop();

          expect(cubit.state.status, CounterRingStatus.stopped);
          expect(cubit.state.currentValue, 30);

          async.elapse(interval * 5);
          expect(cubit.state.currentValue, 30);
        });
      });

      test('emits nothing when not running', () {
        fakeAsync((async) {
          final cubit = buildCubit();
          addTearDown(cubit.close);
          final emitted = <CounterRingState>[];
          cubit.stream.listen(emitted.add);

          cubit.stop();
          async.flushMicrotasks();

          expect(emitted, isEmpty);
          expect(cubit.state.isRunning, isFalse);
        });
      });

      test('can be resumed by start from the paused value', () {
        fakeAsync((async) {
          final cubit = buildCubit();
          addTearDown(cubit.close);

          cubit.start();
          async.elapse(interval * 2);
          cubit.stop();
          expect(cubit.state.currentValue, 20);

          cubit.start();
          expect(cubit.state.status, CounterRingStatus.running);

          async.elapse(interval);
          expect(cubit.state.currentValue, 30);
        });
      });
    });

    group('cancel', () {
      test('stops ticking and rewinds to the initial state', () {
        fakeAsync((async) {
          final cubit = buildCubit(start: 5, finish: 55, step: 10);
          addTearDown(cubit.close);

          cubit.start();
          async.elapse(interval * 2);
          expect(cubit.state.currentValue, 25);

          cubit.cancel();

          expect(
            cubit.state,
            const CounterRingState.initial(start: 5, finish: 55, step: 10),
          );

          async.elapse(interval * 3);
          expect(cubit.state.currentValue, 5);
        });
      });

      test('resets a finished cubit so start counts again', () {
        fakeAsync((async) {
          final cubit = buildCubit(step: 50);
          addTearDown(cubit.close);

          cubit.start();
          async.elapse(interval * 2);
          expect(cubit.state.isFinished, isTrue);

          cubit.cancel();
          expect(cubit.state.isFinished, isFalse);
          expect(cubit.state.currentValue, 0);

          cubit.start();
          async.elapse(interval);
          expect(cubit.state.currentValue, 50);
        });
      });
    });

    group('ticking', () {
      test('clamps to finish and transitions to finished on overshoot', () {
        fakeAsync((async) {
          final cubit = buildCubit(step: 30);
          addTearDown(cubit.close);

          cubit.start();

          async.elapse(interval * 3);
          expect(cubit.state.currentValue, 90);
          expect(cubit.state.status, CounterRingStatus.running);

          async.elapse(interval);
          expect(cubit.state.currentValue, 100);
          expect(cubit.state.status, CounterRingStatus.finished);
        });
      });

      test('lands exactly on finish when steps divide evenly', () {
        fakeAsync((async) {
          final cubit = buildCubit(step: 50);
          addTearDown(cubit.close);

          cubit.start();

          async.elapse(interval);
          expect(cubit.state.currentValue, 50);
          expect(cubit.state.status, CounterRingStatus.running);

          async.elapse(interval);
          expect(cubit.state.currentValue, 100);
          expect(cubit.state.status, CounterRingStatus.finished);
        });
      });

      test('cancels the timer on finish so no further ticks occur', () {
        fakeAsync((async) {
          final cubit = buildCubit(step: 50);
          addTearDown(cubit.close);
          final emitted = <CounterRingState>[];
          cubit.stream.listen(emitted.add);

          cubit.start();
          async.elapse(interval * 2);
          async.flushMicrotasks();
          final countAtFinish = emitted.length;

          async.elapse(interval * 10);
          async.flushMicrotasks();

          expect(emitted, hasLength(countAtFinish));
          expect(cubit.state.currentValue, 100);
        });
      });
    });

    group('close', () {
      test('cancels the timer and closes the cubit', () {
        fakeAsync((async) {
          final cubit = buildCubit();

          cubit.start();
          async.elapse(interval);
          expect(cubit.state.currentValue, 10);

          unawaited(cubit.close());
          async.flushMicrotasks();

          expect(cubit.isClosed, isTrue);

          // Would throw StateError if a tick emitted after close.
          async.elapse(interval * 5);
          expect(cubit.state.currentValue, 10);
        });
      });

      test('closes cleanly when never started', () async {
        final cubit = buildCubit();

        await cubit.close();

        expect(cubit.isClosed, isTrue);
      });
    });
  });
}
