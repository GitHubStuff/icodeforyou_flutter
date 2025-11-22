// splash_screen_state.dart

import 'package:equatable/equatable.dart';
import 'loading_error.dart';

/// Base class for all splash screen states.
sealed class SplashScreenState extends Equatable {
  const SplashScreenState();

  @override
  List<Object?> get props => [];
}

/// Initial state before animation has started.
final class SplashScreenInitial extends SplashScreenState {
  const SplashScreenInitial();
}

/// Animation is currently in progress.
final class SplashScreenAnimatingInProgress extends SplashScreenState {
  const SplashScreenAnimatingInProgress();
}

/// Animation completed, showing spinner while waiting for dismiss signal.
final class SplashScreenShowingSpinner extends SplashScreenState {
  const SplashScreenShowingSpinner();
}

/// Ready to dismiss and transition to the main app.
final class SplashScreenReadyToDismiss extends SplashScreenState {
  const SplashScreenReadyToDismiss();
}

/// An error occurred, display error widget.
final class SplashScreenShowError extends SplashScreenState {
  final LoadingError error;

  const SplashScreenShowError(this.error);

  @override
  List<Object?> get props => [error];
}
