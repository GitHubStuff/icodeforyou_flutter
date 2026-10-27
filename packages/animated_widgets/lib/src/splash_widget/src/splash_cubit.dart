// packages/animated_widgets/lib/src/splash_widget/src/splash_cubit.dart
// ignore_for_file: always_use_package_imports

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'splash_config.dart';
import 'splash_state.dart';

/// Drives the splash → indeterminate → landing flow.
///
/// The cubit owns the timers that gate phase transitions and awaits the
/// background tasks supplied to [start]. Calling code does not schedule
/// timers itself.
///
/// Once the cubit reaches a terminal state ([LandingShowing], [TimedOut], or
/// [BackgroundTaskFailed]) it will not emit again: the active timer is
/// cancelled and late task settlement is ignored.
final class SplashCubit extends Cubit<SplashState> {
  /// Creates a cubit in the [SplashShowing] state.
  ///
  /// Call [start] from the presenting widget's `initState` to begin the
  /// splash timer and start awaiting the background tasks. When no
  /// [splashConfig] is supplied a const [SplashConfig] is used.
  SplashCubit({SplashConfig? splashConfig})
    : config = splashConfig ?? const SplashConfig(),
      super(const SplashShowing());

  /// The timing and copy controlling this flow.
  final SplashConfig config;

  Timer? _timer;
  bool _splashElapsed = false;
  bool _tasksCompleted = false;
  bool _terminated = false;

  /// Begins the splash phase and starts awaiting [tasks].
  ///
  /// The splash artwork is shown for [SplashConfig.splashDuration]. When that
  /// duration elapses, the cubit either transitions directly to
  /// [LandingShowing] (if the tasks have already completed) or to
  /// [IndeterminateShowing] (if they have not). The
  /// [SplashConfig.timeoutDuration] clock starts only when
  /// [IndeterminateShowing] is emitted.
  ///
  /// If any task fails, [BackgroundTaskFailed] is emitted with the first
  /// error from `Future.wait`. If the indeterminate phase exceeds
  /// [SplashConfig.timeoutDuration], [TimedOut] is emitted.
  void start({
    required List<Future<void>> tasks,
  }) {
    _splashElapsed = false;
    _tasksCompleted = false;
    _terminated = false;

    _emitAndSetTimer(
      const SplashShowing(),
      config.splashDuration,
      _onSplashFinished,
    );

    unawaited(_awaitTasks(tasks));
  }

  Future<void> _awaitTasks(List<Future<void>> tasks) async {
    try {
      await Future.wait<void>(tasks, eagerError: true);
    } on Object catch (error, stackTrace) {
      _onTasksFailed(error, stackTrace);
      return;
    }
    _onTasksCompleted();
  }

  /// Fired only by the splash timer, which [_terminate] and [close] cancel,
  /// so it never runs after termination.
  void _onSplashFinished() {
    _splashElapsed = true;
    if (_tasksCompleted) {
      _terminate(const LandingShowing());
      return;
    }
    _emitAndSetTimer(
      const IndeterminateShowing(),
      config.timeoutDuration,
      _onTimeout,
    );
  }

  void _onTasksCompleted() {
    if (_terminated) {
      return;
    }
    _tasksCompleted = true;
    if (_splashElapsed) {
      _terminate(const LandingShowing());
    }
  }

  void _onTasksFailed(Object error, StackTrace stackTrace) {
    if (_terminated) {
      return;
    }
    _terminate(BackgroundTaskFailed(error, stackTrace));
  }

  /// Fired only by the timeout timer, which is armed when
  /// [IndeterminateShowing] is emitted and cancelled by every exit from that
  /// state, so the cubit is always still indeterminate when this runs.
  void _onTimeout() => _terminate(const TimedOut());

  void _emitAndSetTimer(
    SplashState next,
    Duration delay,
    void Function() onFire,
  ) {
    _timer?.cancel();
    _timer = Timer(delay, onFire);
    emit(next);
  }

  void _terminate(SplashState next) {
    _timer?.cancel();
    _timer = null;
    _terminated = true;
    emit(next);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _timer = null;
    return super.close();
  }
}
