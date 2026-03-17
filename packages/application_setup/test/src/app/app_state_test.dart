// test/src/app/app_state_test.dart

import 'package:application_setup/src/app/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppState', () {
    group('AppInitializing', () {
      test('two instances are equal', () {
        expect(const AppInitializing(), equals(const AppInitializing()));
      });
    });

    group('AppSplashVisible', () {
      test('two instances are equal', () {
        expect(const AppSplashVisible(), equals(const AppSplashVisible()));
      });
    });

    group('AppSplashWaiting', () {
      test('two instances are equal', () {
        expect(const AppSplashWaiting(), equals(const AppSplashWaiting()));
      });
    });

    group('AppTasksComplete', () {
      test('two instances are equal', () {
        expect(const AppTasksComplete(), equals(const AppTasksComplete()));
      });
    });

    group('AppReady', () {
      test('two instances are equal', () {
        expect(const AppReady(), equals(const AppReady()));
      });
    });

    group('AppStartupFailed', () {
      test('exposes taskId and error', () {
        const state = AppStartupFailed(taskId: 'db', error: 'oops');
        expect(state.taskId, equals('db'));
        expect(state.error, equals('oops'));
      });

      test('two instances with same values are equal', () {
        const a = AppStartupFailed(taskId: 'db', error: 'oops');
        const b = AppStartupFailed(taskId: 'db', error: 'oops');
        expect(a, equals(b));
      });

      test('instances with different values are not equal', () {
        const a = AppStartupFailed(taskId: 'db', error: 'oops');
        const b = AppStartupFailed(taskId: 'other', error: 'oops');
        expect(a, isNot(equals(b)));
      });
    });

    test('states are subtypes of AppState', () {
      expect(const AppInitializing(), isA<AppState>());
      expect(const AppSplashVisible(), isA<AppState>());
      expect(const AppSplashWaiting(), isA<AppState>());
      expect(const AppTasksComplete(), isA<AppState>());
      expect(const AppReady(), isA<AppState>());
      expect(
        const AppStartupFailed(taskId: 'x', error: 'e'),
        isA<AppState>(),
      );
    });
  });
}
