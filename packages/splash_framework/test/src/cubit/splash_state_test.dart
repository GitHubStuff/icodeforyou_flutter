// packages/splash_framework/test/src/cubit/splash_state_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:splash_framework/src/cubit/splash_state.dart';

void main() {
  group('SplashState', () {
    test('SplashRunning can be instantiated and is a SplashState', () {
      const state = SplashRunning();
      expect(state, isA<SplashRunning>());
      expect(state, isA<SplashState>());
    });

    test('SplashWaiting can be instantiated and is a SplashState', () {
      const state = SplashWaiting();
      expect(state, isA<SplashWaiting>());
      expect(state, isA<SplashState>());
    });

    test('SplashComplete can be instantiated and is a SplashState', () {
      const state = SplashComplete();
      expect(state, isA<SplashComplete>());
      expect(state, isA<SplashState>());
    });

    test('SplashError retains error and stack trace and is a SplashState', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.fromString('test stack trace');

      final state = SplashError(error, stackTrace);

      expect(state, isA<SplashError>());
      expect(state, isA<SplashState>());
      expect(state.error, error);
      expect(state.stackTrace, stackTrace);
    });
  });
}
