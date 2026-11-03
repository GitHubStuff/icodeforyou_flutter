// packages/launch_splash_screen/lib/src/cubit/launch_splash_state.dart

import 'package:equatable/equatable.dart' show Equatable;

/// The states a launch splash moves through.
///
/// Transitions, driven by `LaunchSplashCubit`:
///
/// ```text
/// Showing ──(splash elapsed, tasks done)──────────────▶ Completed
///    │
///    └──(splash elapsed, tasks pending)──▶ Waiting ──(tasks done)──▶ Completed
///                                             │
///                                             └──(timeout)──▶ Failed
///
/// Showing / Waiting ──(a task threw)──▶ Failed
/// ```
///
/// [LaunchSplashCompleted] and [LaunchSplashFailed] are terminal.
sealed class LaunchSplashState extends Equatable {
  const LaunchSplashState();

  @override
  List<Object?> get props => const [];
}

/// The splash child is visible and the splash duration is still running.
final class LaunchSplashShowing extends LaunchSplashState {
  /// Creates the initial state.
  const LaunchSplashShowing();
}

/// The splash duration has elapsed but tasks are still running; the
/// spinner is shown over the child.
final class LaunchSplashWaiting extends LaunchSplashState {
  /// Creates the waiting state.
  const LaunchSplashWaiting();
}

/// All tasks finished and the splash duration has elapsed.
final class LaunchSplashCompleted extends LaunchSplashState {
  /// Creates the completed state.
  const LaunchSplashCompleted();
}

/// A task threw, or the timeout elapsed before the tasks finished.
///
/// On timeout [error] is a `TimeoutException`; otherwise it is whatever the
/// task threw.
final class LaunchSplashFailed extends LaunchSplashState {
  /// Creates the failed state carrying the cause.
  const LaunchSplashFailed(this.error);

  /// The cause of the failure.
  final Object error;

  @override
  List<Object?> get props => [error];
}
