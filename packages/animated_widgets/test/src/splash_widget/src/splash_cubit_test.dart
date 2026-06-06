// animated_widgets/test/src/splash_widget/src/splash_cubit_test.dart
import 'dart:async';

import 'package:animated_widgets/src/splash_widget/src/splash_cubit.dart';
import 'package:animated_widgets/src/splash_widget/src/splash_state.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SplashCubit', () {
    test('starts in SplashShowing', () {
      final cubit = SplashCubit();
      addTearDown(cubit.close);

      expect(cubit.state, isA<SplashShowing>());
    });

    test('lands when tasks finish before the splash elapses', () {
      fakeAsync((async) {
        final task = Completer<void>();
        final cubit = SplashCubit();

        cubit.start(tasks: [task.future]);
        expect(cubit.state, isA<SplashShowing>());

        // Tasks complete first; the splash timer is still pending.
        task.complete();
        async.flushMicrotasks();
        expect(cubit.state, isA<SplashShowing>());

        // Splash elapses with tasks already done -> straight to landing.
        async.elapse(cubit.config.splashDuration);
        expect(cubit.state, isA<LandingShowing>());

        cubit.close();
        async.flushMicrotasks();
      });
    });

    test('shows indeterminate, then lands, when the splash elapses first', () {
      fakeAsync((async) {
        final task = Completer<void>();
        final cubit = SplashCubit();

        cubit.start(tasks: [task.future]);

        // Splash elapses while tasks are pending -> indeterminate.
        async.elapse(cubit.config.splashDuration);
        expect(cubit.state, isA<IndeterminateShowing>());

        // Tasks then complete -> landing.
        task.complete();
        async.flushMicrotasks();
        expect(cubit.state, isA<LandingShowing>());

        cubit.close();
        async.flushMicrotasks();
      });
    });

    test('times out when the indeterminate phase exceeds the timeout', () {
      fakeAsync((async) {
        final task = Completer<void>(); // stays pending through the timeout
        final cubit = SplashCubit();

        cubit.start(tasks: [task.future]);
        async.elapse(cubit.config.splashDuration);
        expect(cubit.state, isA<IndeterminateShowing>());

        async.elapse(cubit.config.timeoutDuration);
        expect(cubit.state, isA<TimedOut>());

        // A late completion after termination is a no-op (terminated guard).
        task.complete();
        async.flushMicrotasks();
        expect(cubit.state, isA<TimedOut>());

        cubit.close();
        async.flushMicrotasks();
      });
    });

    test('reports BackgroundTaskFailed when a task throws', () {
      fakeAsync((async) {
        final task = Completer<void>();
        final cubit = SplashCubit();

        cubit.start(tasks: [task.future]);
        task.completeError(Exception('boom'));
        async.flushMicrotasks();

        expect(cubit.state, isA<BackgroundTaskFailed>());

        cubit.close();
        async.flushMicrotasks();
      });
    });

    test('close cancels the active timer and emits nothing further', () {
      fakeAsync((async) {
        final task = Completer<void>();
        final cubit = SplashCubit();

        cubit.start(tasks: [task.future]); // active splash timer
        cubit.close();
        async.flushMicrotasks();
        expect(cubit.isClosed, isTrue);

        // The cancelled timer must not fire onto a closed cubit; if it did,
        // emit-after-close would throw and surface here.
        async.elapse(
          cubit.config.splashDuration + cubit.config.timeoutDuration,
        );
        task.complete();
        async.flushMicrotasks();
      });
    });
  });
}
