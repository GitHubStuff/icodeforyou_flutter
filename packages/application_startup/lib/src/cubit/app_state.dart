// application_startup/lib/src/app/app_state.dart
import 'package:flutter/material.dart';

/// Base class for all application states.
abstract class AppStateBase {
  /// Creates an [AppStateBase].
  const AppStateBase();
}

/// Sealed hierarchy of all possible application startup states.
sealed class AppState extends AppStateBase {
  /// Creates an [AppState].
  const AppState();
}

/// The application is initialising; no UI is shown yet.
final class AppInitializing extends AppState {
  /// Creates an [AppInitializing] state.
  const AppInitializing();
}

/// The splash screen is visible; startup tasks may still be running.
final class AppSplashVisible extends AppState {
  /// Creates an [AppSplashVisible] state.
  const AppSplashVisible();
}

/// Splash duration has elapsed but tasks are still running — show a spinner.
final class AppSplashWaiting extends AppState {
  /// Creates an [AppSplashWaiting] state.
  const AppSplashWaiting();
}

/// All startup tasks are complete; the splash animation has not yet finished.
final class AppTasksComplete extends AppState {
  /// Creates an [AppTasksComplete] state.
  const AppTasksComplete();
}

/// The application is fully ready to display its main content.
final class AppReady extends AppState {
  /// Creates an [AppReady] state.
  const AppReady();
}

/// A startup task failed; carries the offending [taskId] and [error].
@immutable
final class AppStartupFailed extends AppState {
  /// Creates an [AppStartupFailed] state with the given [taskId] and [error].
  const AppStartupFailed({required this.taskId, required this.error});

  /// The identifier of the task that failed.
  final String taskId;

  /// The error thrown by the failing task.
  final Object error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppStartupFailed &&
          taskId == other.taskId &&
          error == other.error;

  @override
  int get hashCode => Object.hash(taskId, error);
}
