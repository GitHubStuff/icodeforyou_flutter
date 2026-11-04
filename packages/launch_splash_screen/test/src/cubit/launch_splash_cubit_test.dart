// packages/launch_splash_screen/test/src/cubit/launch_splash_cubit_test.dart

import 'dart:async' show Completer, TimeoutException, unawaited;

import 'package:fake_async/fake_async.dart' show fakeAsync;
import 'package:flutter_test/flutter_test.dart';
import 'package:launch_splash_screen/launch_splash_screen.dart'
    show
        LaunchSplashCompleted,
        LaunchSplashCubit,
        LaunchSplashFailed,
        LaunchSplashShowing,
        LaunchSplashState,
        LaunchSplashWaiting,
        LaunchTask,
        minimumTimeoutMargin;

const splash = Duration(milliseconds: 750);
const timeout = Duration(milliseconds: 2000);
const tick = Duration(milliseconds: 1);

/// A recognisable trace to fail tasks with; the cubit must forward it as-is.
final trace = StackTrace.fromString('#0 task (package:test/task.dart:1:1)');

/// Builds a cubit, starts it, and records every emitted state.
({LaunchSplashCubit cubit, List<LaunchSplashState> states}) startCubit({
  List<LaunchTask> tasks = const [],
  Duration splashDuration = splash,
  Duration timeoutDuration = timeout,
}) {
  final cubit = LaunchSplashCubit(
    splashDuration: splashDuration,
    timeoutDuration: timeoutDuration,
    tasks: tasks,
  );
  final states = <LaunchSplashState>[];
  cubit.stream.listen(states.add);
  cubit.start();
  return (cubit: cubit, states: states);
}

void main() {
  group('construction', () {
    test('initial state is LaunchSplashShowing', () {
      final cubit = LaunchSplashCubit(
        splashDuration: splash,
        timeoutDuration: timeout,
        tasks: const [],
      );
      expect(cubit.state, const LaunchSplashShowing());
      unawaited(cubit.close());
    });

    test('accepts timeoutDuration exactly splashDuration + margin', () {
      final cubit = LaunchSplashCubit(
        splashDuration: splash,
        timeoutDuration: splash + minimumTimeoutMargin,
        tasks: const [],
      );
      expect(cubit.state, const LaunchSplashShowing());
      unawaited(cubit.close());
    });

    test('asserts when timeoutDuration is below splashDuration + margin', () {
      expect(
        () => LaunchSplashCubit(
          splashDuration: splash,
          timeoutDuration: splash + minimumTimeoutMargin - tick,
          tasks: const [],
        ),
        throwsAssertionError,
      );
    });

    test('asserts when start() is called twice', () {
      fakeAsync((async) {
        final (:cubit, states: _) = startCubit();
        expect(cubit.start, throwsAssertionError);
        unawaited(cubit.close());
      });
    });
  });

  group('no tasks', () {
    test('completes exactly when splashDuration elapses', () {
      fakeAsync((async) {
        final (:cubit, :states) = startCubit();

        async.elapse(splash - tick);
        expect(states, isEmpty);

        async.elapse(tick);
        expect(states, [const LaunchSplashCompleted()]);

        unawaited(cubit.close());
      });
    });

    test('emits nothing after completing', () {
      fakeAsync((async) {
        final (:cubit, :states) = startCubit();

        async.elapse(timeout + splash);
        expect(states, [const LaunchSplashCompleted()]);

        unawaited(cubit.close());
      });
    });
  });

  group('tasks finish before splashDuration', () {
    test('waits for splashDuration before completing', () {
      fakeAsync((async) {
        final completer = Completer<void>();
        final (:cubit, :states) = startCubit(tasks: [() => completer.future]);

        async.elapse(tick);
        completer.complete();
        async.flushMicrotasks();
        expect(states, isEmpty);

        async.elapse(splash);
        expect(states, [const LaunchSplashCompleted()]);

        unawaited(cubit.close());
      });
    });

    test('runs every task concurrently', () {
      fakeAsync((async) {
        final started = <int>[];
        final (:cubit, :states) = startCubit(
          tasks: [
            () async => started.add(1),
            () async => started.add(2),
            () async => started.add(3),
          ],
        );

        async.flushMicrotasks();
        expect(started, [1, 2, 3]);

        async.elapse(splash);
        expect(states, [const LaunchSplashCompleted()]);

        unawaited(cubit.close());
      });
    });
  });

  group('tasks finish after splashDuration, before timeoutDuration', () {
    test('emits Waiting then Completed', () {
      fakeAsync((async) {
        final completer = Completer<void>();
        final (:cubit, :states) = startCubit(tasks: [() => completer.future]);

        async.elapse(splash);
        expect(states, [const LaunchSplashWaiting()]);

        completer.complete();
        async.flushMicrotasks();
        expect(states, [
          const LaunchSplashWaiting(),
          const LaunchSplashCompleted(),
        ]);

        unawaited(cubit.close());
      });
    });

    test('cancels the timeout after completing', () {
      fakeAsync((async) {
        final completer = Completer<void>();
        final (:cubit, :states) = startCubit(tasks: [() => completer.future]);

        async.elapse(splash);
        completer.complete();
        async.flushMicrotasks();

        async.elapse(timeout);
        expect(states, [
          const LaunchSplashWaiting(),
          const LaunchSplashCompleted(),
        ]);

        unawaited(cubit.close());
      });
    });
  });

  group('tasks exceed timeoutDuration', () {
    test('emits Waiting then Failed with a TimeoutException and a trace', () {
      fakeAsync((async) {
        final completer = Completer<void>();
        final (:cubit, :states) = startCubit(tasks: [() => completer.future]);

        async.elapse(timeout);

        expect(states, hasLength(2));
        expect(states.first, const LaunchSplashWaiting());
        expect(
          states.last,
          isA<LaunchSplashFailed>()
              .having(
                (s) => s.error,
                'error',
                isA<TimeoutException>().having(
                  (e) => e.duration,
                  'duration',
                  timeout,
                ),
              )
              .having(
                (s) => s.stackTrace.toString(),
                'stackTrace',
                isNotEmpty,
              ),
        );

        unawaited(cubit.close());
      });
    });

    test('ignores a task that finishes after the timeout', () {
      fakeAsync((async) {
        final completer = Completer<void>();
        final (:cubit, :states) = startCubit(tasks: [() => completer.future]);

        async.elapse(timeout);
        final afterTimeout = List.of(states);

        completer.complete();
        async.flushMicrotasks();
        expect(states, afterTimeout);

        unawaited(cubit.close());
      });
    });

    test('ignores a task that throws after the timeout', () {
      fakeAsync((async) {
        final completer = Completer<void>();
        final (:cubit, :states) = startCubit(tasks: [() => completer.future]);

        async.elapse(timeout);
        final afterTimeout = List.of(states);

        completer.completeError(StateError('late'), trace);
        async.flushMicrotasks();
        expect(states, afterTimeout);

        unawaited(cubit.close());
      });
    });
  });

  group('a task throws', () {
    test('fails immediately while still Showing, carrying the trace', () {
      fakeAsync((async) {
        final error = StateError('boom');
        final completer = Completer<void>();
        final (:cubit, :states) = startCubit(tasks: [() => completer.future]);

        async.elapse(tick);
        completer.completeError(error, trace);
        async.flushMicrotasks();
        expect(states, [LaunchSplashFailed(error, trace)]);

        unawaited(cubit.close());
      });
    });

    test('cancels the splash and timeout timers after failing', () {
      fakeAsync((async) {
        final error = StateError('boom');
        final completer = Completer<void>();
        final (:cubit, :states) = startCubit(tasks: [() => completer.future]);

        async.elapse(tick);
        completer.completeError(error, trace);
        async.flushMicrotasks();

        async.elapse(timeout + splash);
        expect(states, [LaunchSplashFailed(error, trace)]);

        unawaited(cubit.close());
      });
    });

    test('fails while Waiting', () {
      fakeAsync((async) {
        final error = StateError('boom');
        final completer = Completer<void>();
        final (:cubit, :states) = startCubit(tasks: [() => completer.future]);

        async.elapse(splash);
        completer.completeError(error, trace);
        async.flushMicrotasks();
        expect(states, [
          const LaunchSplashWaiting(),
          LaunchSplashFailed(error, trace),
        ]);

        unawaited(cubit.close());
      });
    });

    test('reports only the first error when several tasks throw', () {
      fakeAsync((async) {
        final first = StateError('first');
        final a = Completer<void>();
        final b = Completer<void>();
        final (:cubit, :states) = startCubit(
          tasks: [() => a.future, () => b.future],
        );

        async.elapse(tick);
        a.completeError(first, trace);
        async.flushMicrotasks();
        b.completeError(StateError('second'), StackTrace.current);
        async.flushMicrotasks();

        expect(states, [LaunchSplashFailed(first, trace)]);

        unawaited(cubit.close());
      });
    });
  });

  group('close()', () {
    test('cancels the timers so nothing is emitted afterwards', () {
      fakeAsync((async) {
        final (:cubit, :states) = startCubit();

        unawaited(cubit.close());
        async.elapse(timeout + splash);
        expect(states, isEmpty);
      });
    });

    test('ignores a task that finishes after close', () {
      fakeAsync((async) {
        final completer = Completer<void>();
        final (:cubit, :states) = startCubit(tasks: [() => completer.future]);

        unawaited(cubit.close());
        async.flushMicrotasks();
        completer.complete();
        async.flushMicrotasks();
        expect(states, isEmpty);
      });
    });

    test('ignores a task that throws after close', () {
      fakeAsync((async) {
        final completer = Completer<void>();
        final (:cubit, :states) = startCubit(tasks: [() => completer.future]);

        unawaited(cubit.close());
        async.flushMicrotasks();
        completer.completeError(StateError('late'), trace);
        async.flushMicrotasks();
        expect(states, isEmpty);
      });
    });
  });
}
