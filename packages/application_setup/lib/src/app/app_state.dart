// lib/src/app/app_state.dart

import 'package:application_setup/src/app/app_state_base.dart';

sealed class AppState extends AppStateBase {
  const AppState();
}

final class AppInitializing extends AppState {
  const AppInitializing();
}

final class AppSplashVisible extends AppState {
  const AppSplashVisible();
}

/// Splash animation is complete but startup tasks are still running.
final class AppSplashWaiting extends AppState {
  const AppSplashWaiting();
}

/// All startup tasks are complete but splash animation has not finished.
final class AppTasksComplete extends AppState {
  const AppTasksComplete();
}

final class AppReady extends AppState {
  const AppReady();
}

final class AppStartupFailed extends AppState {
  const AppStartupFailed({
    required this.taskId,
    required this.error,
  });

  final String taskId;
  final Object error;
}
