// splash_screen_state_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:splash_screen_package/src/loading_error.dart';
import 'package:splash_screen_package/src/splash_screen_state.dart';

void main() {
  group('SplashScreenState', () {
    test('SplashScreenInitial instances are equal', () {
      const state1 = SplashScreenInitial();
      const state2 = SplashScreenInitial();

      expect(state1, equals(state2));
    });

    test('SplashScreenAnimatingInProgress instances are equal', () {
      const state1 = SplashScreenAnimatingInProgress();
      const state2 = SplashScreenAnimatingInProgress();

      expect(state1, equals(state2));
    });

    test('SplashScreenShowingSpinner instances are equal', () {
      const state1 = SplashScreenShowingSpinner();
      const state2 = SplashScreenShowingSpinner();

      expect(state1, equals(state2));
    });

    test('SplashScreenReadyToDismiss instances are equal', () {
      const state1 = SplashScreenReadyToDismiss();
      const state2 = SplashScreenReadyToDismiss();

      expect(state1, equals(state2));
    });

    test('SplashScreenShowError with same error are equal', () {
      const error = LoadingError('Test error');
      const state1 = SplashScreenShowError(error);
      const state2 = SplashScreenShowError(error);

      expect(state1, equals(state2));
    });

    test('SplashScreenShowError with equal errors are equal', () {
      const error1 = LoadingError('Test error', {'key': 'value'});
      const error2 = LoadingError('Test error', {'key': 'value'});
      const state1 = SplashScreenShowError(error1);
      const state2 = SplashScreenShowError(error2);

      expect(state1, equals(state2));
    });

    test('SplashScreenShowError with different errors are not equal', () {
      const error1 = LoadingError('Error 1');
      const error2 = LoadingError('Error 2');
      const state1 = SplashScreenShowError(error1);
      const state2 = SplashScreenShowError(error2);

      expect(state1, isNot(equals(state2)));
    });

    test('different state types are not equal', () {
      const state1 = SplashScreenInitial();
      const state2 = SplashScreenAnimatingInProgress();

      expect(state1, isNot(equals(state2)));
    });

    test('SplashScreenShowError props includes error', () {
      const error = LoadingError('Test error');
      const state = SplashScreenShowError(error);

      expect(state.props, equals(const [error]));
    });

    test('empty states have empty props', () {
      const state = SplashScreenInitial();

      expect(state.props, equals([]));
    });
  });
}
