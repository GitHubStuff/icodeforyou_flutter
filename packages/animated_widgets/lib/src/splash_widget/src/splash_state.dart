// packages/animated_widgets/lib/src/splash_widget/src/splash_flow.dart
// ignore_for_file: comment_references, public_member_api_docs

/// State emitted by [SplashCubit] to drive [SplashFlow].
///
/// The flow moves through these states in order: [SplashShowing] →
/// (optional [IndeterminateShowing]) → [LandingShowing]. From the
/// indeterminate phase the flow may instead reach [TimedOut] when the
/// configured timeout elapses before the background tasks complete, or
/// [BackgroundTaskFailed] when any task fails.
///
/// [LandingShowing] is terminal: once entered, the cubit will not emit again.
sealed class SplashState {
  const SplashState();
}

/// Initial splash artwork is on screen.
final class SplashShowing extends SplashState {
  const SplashShowing();
}

/// Splash finished and an indeterminate progress widget is shown while the
/// host application's background tasks continue running.
final class IndeterminateShowing extends SplashState {
  const IndeterminateShowing();
}

/// Background tasks completed and the splash duration has elapsed; the
/// landing page is shown. This state is terminal.
final class LandingShowing extends SplashState {
  const LandingShowing();
}

/// The indeterminate phase exceeded its allotted time; a timeout widget is
/// shown.
final class TimedOut extends SplashState {
  const TimedOut();
}

/// One of the background tasks failed during the splash flow. The first error
/// to surface from `Future.wait` is captured; subsequent failures are
/// discarded.
final class BackgroundTaskFailed extends SplashState {
  const BackgroundTaskFailed(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;
}
