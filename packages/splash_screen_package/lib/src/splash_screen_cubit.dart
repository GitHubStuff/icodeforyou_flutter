// splash_screen_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'loading_error.dart';
import 'splash_screen_state.dart';

/// Manages the state and lifecycle of the splash screen.
///
/// This cubit handles animation tracking, error reporting, dismiss requests,
/// and timeout management for the splash screen flow.
class SplashScreenCubit extends Cubit<SplashScreenState> {
  static SplashScreenCubit? _instance;

  final Duration _timeoutDuration;
  Timer? _timeoutTimer;
  bool _animationCompleted = false;
  bool _dismissRequested = false;
  LoadingError? _queuedError;

  SplashScreenCubit._(this._timeoutDuration)
    : super(const SplashScreenInitial());

  /// Gets the singleton instance of the cubit.
  ///
  /// Throws [StateError] if [initialize] has not been called first.
  static SplashScreenCubit get instance {
    if (_instance == null) {
      throw StateError(
        'SplashScreenCubit must be initialized before accessing instance. '
        'Call SplashScreenCubit.initialize() in main() before runApp().',
      );
    }
    return _instance!;
  }

  /// Initializes the singleton instance with the specified timeout duration.
  ///
  /// This must be called in main() before any other code tries to access the instance.
  /// Safe to call multiple times - will update the timeout duration if called again.
  static void initialize(Duration timeout) {
    _instance?.close();
    _instance = SplashScreenCubit._(timeout);
  }

  /// Resets the cubit to its initial state for testing purposes.
  static void reset() {
    _instance?.close();
    _instance = null;
  }

  /// Notifies the cubit that the splash screen animation has started.
  void notifyAnimationStarted() {
    if (isClosed) return;
    emit(const SplashScreenAnimatingInProgress());
  }

  /// Notifies the cubit that the splash screen animation has completed.
  ///
  /// This triggers state evaluation to determine next action:
  /// - If error queued: show error
  /// - If dismiss queued: ready to dismiss
  /// - Otherwise: show spinner and start timeout
  void notifyAnimationCompleted() {
    if (isClosed) return;
    _animationCompleted = true;
    _processQueuedActions();
  }

  /// Reports an error that occurred during initialization.
  ///
  /// If animation is still in progress, the error is queued.
  /// If animation is complete, immediately transitions to error state.
  /// Errors override any queued dismiss requests.
  /// Multiple error calls keep only the first error.
  void reportError(LoadingError error) {
    if (isClosed) return;

    if (_queuedError != null) return;

    _queuedError = error;

    if (_animationCompleted) {
      _cancelTimeoutTimer();
      emit(SplashScreenShowError(error));
    }
  }

  /// Requests dismissal of the splash screen to proceed to main app.
  ///
  /// If animation is still in progress, the request is queued.
  /// If animation is complete, immediately transitions to ready state.
  /// Subsequent dismiss requests after the first are ignored.
  /// Dismiss is ignored if error is queued.
  void dismiss() {
    if (isClosed) return;

    if (_dismissRequested) return;

    _dismissRequested = true;

    if (_animationCompleted) {
      if (_queuedError == null) {
        _cancelTimeoutTimer();
        emit(const SplashScreenReadyToDismiss());
      }
    }
  }

  void _processQueuedActions() {
    if (_queuedError != null) {
      emit(SplashScreenShowError(_queuedError!));
      return;
    }

    if (_dismissRequested) {
      emit(const SplashScreenReadyToDismiss());
      return;
    }

    emit(const SplashScreenShowingSpinner());
    _startTimeoutTimer();
  }

  void _startTimeoutTimer() {
    _cancelTimeoutTimer();
    _timeoutTimer = Timer(_timeoutDuration, _onTimeout);
  }

  void _onTimeout() {
    if (isClosed) return;

    final timeoutError = LoadingError('Operation timed out', {
      'timeout_duration': _timeoutDuration.toString(),
    });

    _queuedError = timeoutError;
    _cancelTimeoutTimer();
    emit(SplashScreenShowError(timeoutError));
  }

  void _cancelTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  @override
  Future<void> close() {
    _cancelTimeoutTimer();
    return super.close();
  }
}
