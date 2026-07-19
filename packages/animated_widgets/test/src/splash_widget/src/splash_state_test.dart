// animated_widgets/test/src/splash_widget/src/splash_state_test.dart
import 'package:animated_widgets/src/splash_widget/src/splash_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SplashState', () {
    test('SplashShowing is a SplashState', () {
      expect(const SplashShowing(), isA<SplashState>());
    });

    test('IndeterminateShowing is a SplashState', () {
      expect(const IndeterminateShowing(), isA<SplashState>());
    });

    test('LandingShowing is a SplashState', () {
      expect(const LandingShowing(), isA<SplashState>());
    });

    test('TimedOut is a SplashState', () {
      expect(const TimedOut(), isA<SplashState>());
    });

    test('BackgroundTaskFailed stores the error and stack trace', () {
      final error = Exception('boom');
      final stackTrace = StackTrace.current;

      final state = BackgroundTaskFailed(error, stackTrace);

      expect(state, isA<SplashState>());
      expect(state.error, same(error));
      expect(state.stackTrace, same(stackTrace));
    });
  });
}
