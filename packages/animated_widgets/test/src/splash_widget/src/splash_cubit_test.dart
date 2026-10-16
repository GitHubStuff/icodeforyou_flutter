// packages/animated_widgets/test/src/splash_widget/src/splash_cubit_test.dart
import 'dart:async';

import 'package:animated_widgets/src/splash_widget/src/splash_config.dart';
import 'package:animated_widgets/src/splash_widget/src/splash_cubit.dart';
import 'package:animated_widgets/src/splash_widget/src/splash_state.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SplashCubit', () {
    test('starts in SplashShowing with the default config', () {
      final cubit = SplashCubit();
      addTearDown(cubit.close);

      expect(cubit.state, isA<SplashShowing>());
      expect(cubit.config.splashDuration, const SplashConfig().splashDuration);
    });

    test('uses the supplied config', () {
      const config = SplashConfig(
        splashDuration: Duration(seconds: 1),
        timeoutDuration: Duration(seconds: 2),
      );
      final cubit = SplashCubit(splashConfig: config);
      addTearDown(cubit.close);

      expect(cubit.config, same(config));
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

        unawaited(cubit.close());
        async.flushMicrotasks();
        expect(cubit.isClosed, isTrue);
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

        unawaited(cubit.close());
        async.flushMicrotasks();
        expect(cubit.isClosed, isTrue);
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

        unawaited(cubit.close());
        async.flushMicrotasks();
        expect(cubit.isClosed, isTrue);
      });
    });

    test('ignores a task failure that arrives after termination', () {
      fakeAsync((async) {
        final task = Completer<void>();
        final cubit = SplashCubit();

        cubit.start(tasks: [task.future]);
        async
          ..elapse(cubit.config.splashDuration)
          ..elapse(cubit.config.timeoutDuration);
        expect(cubit.state, isA<TimedOut>());

        // A late failure after termination is a no-op (terminated guard).
        task.completeError(Exception('late'));
        async.flushMicrotasks();
        expect(cubit.state, isA<TimedOut>());

        unawaited(cubit.close());
        async.flushMicrotasks();
        expect(cubit.isClosed, isTrue);
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

        // The failure cancelled the splash timer; elapsing changes nothing.
        async.elapse(cubit.config.splashDuration);
        expect(cubit.state, isA<BackgroundTaskFailed>());

        unawaited(cubit.close());
        async.flushMicrotasks();
        expect(cubit.isClosed, isTrue);
      });
    });

    test('lands after a restart when the first run has terminated', () {
      fakeAsync((async) {
        final first = Completer<void>();
        final second = Completer<void>();
        final cubit = SplashCubit();

        cubit.start(tasks: [first.future]);
        first.completeError(Exception('boom'));
        async.flushMicrotasks();
        expect(cubit.state, isA<BackgroundTaskFailed>());

        // start() resets the terminated flag and re-arms the splash timer.
        cubit.start(tasks: [second.future]);
        expect(cubit.state, isA<SplashShowing>());

        second.complete();
        async.flushMicrotasks();
        async.elapse(cubit.config.splashDuration);
        expect(cubit.state, isA<LandingShowing>());

        unawaited(cubit.close());
        async.flushMicrotasks();
        expect(cubit.isClosed, isTrue);
      });
    });

    test('close cancels the active timer and emits nothing further', () {
      fakeAsync((async) {
        final task = Completer<void>();
        final cubit = SplashCubit();

        cubit.start(tasks: [task.future]); // active splash timer

        unawaited(cubit.close());
        async.flushMicrotasks();
        expect(cubit.isClosed, isTrue);

        // The cancelled timer must not fire onto a closed cubit; if it did,
        // emit-after-close would throw and surface here.
        async.elapse(
          cubit.config.splashDuration + cubit.config.timeoutDuration,
        );
        task.complete();
        async.flushMicrotasks();
        expect(cubit.state, isA<SplashShowing>());
      });
    });
  });
}
