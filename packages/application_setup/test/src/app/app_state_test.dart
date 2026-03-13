// test/src/app/app_state_test.dart

import 'package:application_setup/src/app/app_state.dart';
import 'package:application_setup/src/app/app_state_base.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppStateBase', () {
    test('AppState is an AppStateBase', () {
      const state = AppInitializing();
      expect(state, isA<AppStateBase>());
    });
  });

  group('AppState', () {
    test('AppInitializing is an AppState', () {
      expect(const AppInitializing(), isA<AppState>());
    });

    test('AppSplashVisible is an AppState', () {
      expect(const AppSplashVisible(), isA<AppState>());
    });

    test('AppSplashWaiting is an AppState', () {
      expect(const AppSplashWaiting(), isA<AppState>());
    });

    test('AppReady is an AppState', () {
      expect(const AppReady(), isA<AppState>());
    });

    test('AppStartupFailed carries taskId and error', () {
      const error = 'boom';
      const state = AppStartupFailed(taskId: 'test_task', error: error);
      expect(state.taskId, 'test_task');
      expect(state.error, error);
    });

    test('AppStartupFailed is an AppState', () {
      expect(
        const AppStartupFailed(taskId: 'id', error: 'err'),
        isA<AppState>(),
      );
    });
  });
}
