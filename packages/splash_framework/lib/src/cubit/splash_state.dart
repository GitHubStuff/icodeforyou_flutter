// packages/splash_framework/lib/src/splash_state.dart

/// Base class for all splash lifecycle states emitted by [SplashCubit].
///
/// The splash flow progresses through several distinct states:
/// - [SplashRunning] — the initial state while the minimum duration and tasks
///   begin executing.
/// - [SplashWaiting] — emitted when the minimum duration has elapsed but tasks
///   are still running.
/// - [SplashComplete] — emitted when all tasks finish successfully.
/// - [SplashError] — emitted when any task throws an exception.
///
/// All splash states are immutable and represent a snapshot of the current
/// initialization progress.
sealed class SplashState {
  /// Creates a new immutable splash state.
  const SplashState();
}

/// State emitted while the splash screen is still within its minimum duration
/// and startup tasks are running.
///
/// This is the initial state of the splash process.
final class SplashRunning extends SplashState {
  /// Creates a new [SplashRunning] state.
  const SplashRunning();
}

/// State emitted when the minimum splash duration has elapsed but the startup
/// tasks have not yet completed.
///
/// The UI typically uses this state to display a loading indicator.
final class SplashWaiting extends SplashState {
  /// Creates a new [SplashWaiting] state.
  const SplashWaiting();
}

/// State emitted when all startup tasks have completed successfully.
///
/// When this state is reached, the splash screen can transition to the main
/// application content.
final class SplashComplete extends SplashState {
  /// Creates a new [SplashComplete] state.
  const SplashComplete();
}

/// State emitted when one or more startup tasks throw an exception.
///
/// The [error] property contains the thrown object, allowing the UI or caller
/// to handle or display the failure.
final class SplashError extends SplashState {
  /// Creates a new [SplashError] state containing the thrown [error].
  const SplashError(this.error);

  /// The error thrown by a failing startup task.
  final Object error;
}
