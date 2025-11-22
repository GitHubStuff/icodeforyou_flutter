// splash_screen_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:splash_screen_package/src/loading_error.dart';
import 'package:splash_screen_package/src/splash_screen_cubit.dart';
import 'package:splash_screen_package/src/splash_screen_state.dart';

void main() {
  group('SplashScreenCubit', () {
    setUp(() {
      SplashScreenCubit.initialize(const Duration(seconds: 5));
    });

    tearDown(() {
      SplashScreenCubit.reset();
    });

    test('initialize creates singleton instance', () {
      final instance = SplashScreenCubit.instance;
      expect(instance, isNotNull);
      expect(instance.state, isA<SplashScreenInitial>());
    });

    test('accessing instance before initialize throws StateError', () {
      SplashScreenCubit.reset();
      expect(
        () => SplashScreenCubit.instance,
        throwsStateError,
      );
    });

    test('reset clears the instance', () {
      expect(() => SplashScreenCubit.instance, returnsNormally);
      SplashScreenCubit.reset();
      expect(() => SplashScreenCubit.instance, throwsStateError);
    });

    test('notifyAnimationStarted emits AnimatingInProgress', () {
      final cubit = SplashScreenCubit.instance;
      expect(cubit.state, isA<SplashScreenInitial>());

      cubit.notifyAnimationStarted();

      expect(cubit.state, isA<SplashScreenAnimatingInProgress>());
    });

    test('notifyAnimationCompleted without queue emits ShowingSpinner', () {
      final cubit = SplashScreenCubit.instance;

      cubit.notifyAnimationStarted();
      cubit.notifyAnimationCompleted();

      expect(cubit.state, isA<SplashScreenShowingSpinner>());
    });

    test('dismiss queued before animation completion emits ReadyToDismiss after', () {
      final cubit = SplashScreenCubit.instance;

      cubit.notifyAnimationStarted();
      cubit.dismiss();

      expect(cubit.state, isA<SplashScreenAnimatingInProgress>());

      cubit.notifyAnimationCompleted();

      expect(cubit.state, isA<SplashScreenReadyToDismiss>());
    });

    test('error queued before animation completion emits ShowError after', () {
      final cubit = SplashScreenCubit.instance;
      const error = LoadingError('Test error', {'key': 'value'});

      cubit.notifyAnimationStarted();
      cubit.reportError(error);

      expect(cubit.state, isA<SplashScreenAnimatingInProgress>());

      cubit.notifyAnimationCompleted();

      expect(cubit.state, isA<SplashScreenShowError>());
      final state = cubit.state as SplashScreenShowError;
      expect(state.error.errorMessage, 'Test error');
      expect(state.error.errorDetails, const {'key': 'value'});
    });

    test('error overrides queued dismiss', () {
      final cubit = SplashScreenCubit.instance;
      const error = LoadingError('Critical error');

      cubit.notifyAnimationStarted();
      cubit.dismiss();
      cubit.reportError(error);
      cubit.notifyAnimationCompleted();

      expect(cubit.state, isA<SplashScreenShowError>());
      final state = cubit.state as SplashScreenShowError;
      expect(state.error.errorMessage, 'Critical error');
    });

    test('dismiss during spinner emits ReadyToDismiss', () {
      final cubit = SplashScreenCubit.instance;

      cubit.notifyAnimationStarted();
      cubit.notifyAnimationCompleted();

      expect(cubit.state, isA<SplashScreenShowingSpinner>());

      cubit.dismiss();

      expect(cubit.state, isA<SplashScreenReadyToDismiss>());
    });

    test('error during spinner emits ShowError', () {
      final cubit = SplashScreenCubit.instance;
      const error = LoadingError('Runtime error');

      cubit.notifyAnimationStarted();
      cubit.notifyAnimationCompleted();

      expect(cubit.state, isA<SplashScreenShowingSpinner>());

      cubit.reportError(error);

      expect(cubit.state, isA<SplashScreenShowError>());
      final state = cubit.state as SplashScreenShowError;
      expect(state.error.errorMessage, 'Runtime error');
    });

    test('timeout emits ShowError with timeout message', () async {
      SplashScreenCubit.initialize(const Duration(milliseconds: 100));
      final cubit = SplashScreenCubit.instance;

      cubit.notifyAnimationStarted();
      cubit.notifyAnimationCompleted();

      expect(cubit.state, isA<SplashScreenShowingSpinner>());

      await Future.delayed(const Duration(milliseconds: 150));

      expect(cubit.state, isA<SplashScreenShowError>());
      final state = cubit.state as SplashScreenShowError;
      expect(state.error.errorMessage, 'Operation timed out');
      expect(state.error.errorDetails, isNotNull);
      expect(state.error.errorDetails!.containsKey('timeout_duration'), true);
    });

    test('multiple dismiss calls are idempotent', () {
      final cubit = SplashScreenCubit.instance;

      cubit.notifyAnimationStarted();
      cubit.dismiss();
      cubit.dismiss();
      cubit.dismiss();
      cubit.notifyAnimationCompleted();

      expect(cubit.state, isA<SplashScreenReadyToDismiss>());
    });

    test('reportError after animation immediately emits ShowError', () {
      final cubit = SplashScreenCubit.instance;
      const error = LoadingError('Immediate error');

      cubit.notifyAnimationStarted();
      cubit.notifyAnimationCompleted();

      expect(cubit.state, isA<SplashScreenShowingSpinner>());

      cubit.reportError(error);

      expect(cubit.state, isA<SplashScreenShowError>());
      final state = cubit.state as SplashScreenShowError;
      expect(state.error.errorMessage, 'Immediate error');
    });

    test('dismiss after animation with no queue immediately emits ReadyToDismiss', () {
      final cubit = SplashScreenCubit.instance;

      cubit.notifyAnimationStarted();
      cubit.notifyAnimationCompleted();

      expect(cubit.state, isA<SplashScreenShowingSpinner>());

      cubit.dismiss();

      expect(cubit.state, isA<SplashScreenReadyToDismiss>());
    });

    test('close cancels timeout timer', () async {
      SplashScreenCubit.initialize(const Duration(seconds: 10));
      final cubit = SplashScreenCubit.instance;

      cubit.notifyAnimationStarted();
      cubit.notifyAnimationCompleted();

      expect(cubit.state, isA<SplashScreenShowingSpinner>());

      await cubit.close();

      expect(cubit.isClosed, true);
    });

    test('initialize can be called multiple times', () {
      SplashScreenCubit.initialize(const Duration(seconds: 1));
      final instance1 = SplashScreenCubit.instance;

      SplashScreenCubit.initialize(const Duration(seconds: 5));
      final instance2 = SplashScreenCubit.instance;

      expect(instance1, isNot(same(instance2)));
      expect(instance2.state, isA<SplashScreenInitial>());
    });

    test('methods called after close do nothing', () async {
      final cubit = SplashScreenCubit.instance;
      await cubit.close();

      cubit.notifyAnimationStarted();
      cubit.notifyAnimationCompleted();
      cubit.dismiss();
      cubit.reportError(const LoadingError('Test'));

      expect(cubit.isClosed, true);
    });

    test('multiple reportError calls keep only first error', () {
      final cubit = SplashScreenCubit.instance;
      const error1 = LoadingError('First error');
      const error2 = LoadingError('Second error');

      cubit.notifyAnimationStarted();
      cubit.reportError(error1);
      cubit.reportError(error2);
      cubit.notifyAnimationCompleted();

      expect(cubit.state, isA<SplashScreenShowError>());
      final state = cubit.state as SplashScreenShowError;
      expect(state.error.errorMessage, 'First error');
    });

    test('dismiss does not override error', () {
      final cubit = SplashScreenCubit.instance;
      const error = LoadingError('Error message');

      cubit.notifyAnimationStarted();
      cubit.notifyAnimationCompleted();

      expect(cubit.state, isA<SplashScreenShowingSpinner>());

      cubit.reportError(error);

      expect(cubit.state, isA<SplashScreenShowError>());

      cubit.dismiss();

      expect(cubit.state, isA<SplashScreenShowError>());
    });
  });
}
