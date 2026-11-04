// packages/launch_splash_screen/lib/src/cubit/launch_splash_cubit.dart

import 'dart:async' show Future, TimeoutException, Timer, unawaited;

import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:launch_splash_screen/launch_splash_screen.dart'
    show
        LaunchSplashCompleted,
        LaunchSplashFailed,
        LaunchSplashShowing,
        LaunchSplashState,
        LaunchSplashWaiting,
        LaunchTask;

/// The least amount by which `timeoutDuration` must exceed `splashDuration`.
const Duration minimumTimeoutMargin = Duration(milliseconds: 250);

/// Drives a launch splash: shows the child for [splashDuration], runs
/// [tasks] concurrently, and reports completion or failure.
///
/// Call [start] exactly once. Timing rules:
///
/// * The child is visible for at least [splashDuration]; completion is
///   never reported sooner, even if every task finishes immediately.
/// * If the tasks are still running when [splashDuration] elapses, the
///   state moves to [LaunchSplashWaiting] so the UI can show a spinner.
/// * If the tasks finish before [timeoutDuration], the state moves to
///   [LaunchSplashCompleted].
/// * If [timeoutDuration] elapses first, the state moves to
///   [LaunchSplashFailed] carrying a [TimeoutException] and the trace of
///   the timer firing.
/// * If any task throws, the state moves to [LaunchSplashFailed] carrying
///   that error and the trace captured at the throw, regardless of timing.
///
/// [LaunchSplashCompleted] and [LaunchSplashFailed] are terminal; nothing
/// is emitted after either.
class LaunchSplashCubit extends Cubit<LaunchSplashState> {
  /// Creates a cubit in the [LaunchSplashShowing] state.
  ///
  /// [timeoutDuration] must be at least [splashDuration] plus
  /// [minimumTimeoutMargin].
  LaunchSplashCubit({
    required this.splashDuration,
    required this.timeoutDuration,
    required this.tasks,
  }) : assert(
         timeoutDuration >= splashDuration + minimumTimeoutMargin,
         'timeoutDuration must be at least splashDuration + '
         '${minimumTimeoutMargin.inMilliseconds}ms',
       ),
       super(const LaunchSplashShowing());

  /// How long the child is shown before a spinner may appear.
  final Duration splashDuration;

  /// How long the tasks may run before the splash fails.
  final Duration timeoutDuration;

  /// The work to run while the child is shown.
  final List<LaunchTask> tasks;

  Timer? _splashTimer;
  Timer? _timeoutTimer;
  bool _splashElapsed = false;
  bool _tasksFinished = false;
  bool _started = false;

  bool get _isTerminal =>
      state is LaunchSplashCompleted || state is LaunchSplashFailed;

  /// Starts the splash timer, the timeout timer, and every task.
  ///
  /// Calling [start] more than once is a programmer error.
  void start() {
    assert(!_started, 'start() may only be called once');
    _started = true;

    _splashTimer = Timer(splashDuration, _onSplashElapsed);
    _timeoutTimer = Timer(timeoutDuration, _onTimeout);
    unawaited(_runTasks());
  }

  Future<void> _runTasks() async {
    try {
      await Future.wait(tasks.map((task) => task()), eagerError: true);
      _onTasksFinished();
    } on Object catch (error, stackTrace) {
      _fail(error, stackTrace);
    }
  }

  // Timer callbacks need no closed/terminal guard: every path to a terminal
  // state, and close(), cancels both timers, so a cancelled timer never
  // reaches here. Task callbacks DO need the guard, because futures cannot
  // be cancelled.

  void _onSplashElapsed() {
    _splashElapsed = true;
    if (_tasksFinished) {
      _complete();
    } else {
      emit(const LaunchSplashWaiting());
    }
  }

  // A timeout is constructed, not thrown, so no trace is captured for us;
  // StackTrace.current marks the timer firing, which is all a timeout has.
  void _onTimeout() {
    _fail(
      TimeoutException(
        'Launch tasks did not finish within the timeout',
        timeoutDuration,
      ),
      StackTrace.current,
    );
  }

  void _onTasksFinished() {
    _tasksFinished = true;
    if (isClosed || _isTerminal) {
      return;
    }
    if (_splashElapsed) {
      _complete();
    }
  }

  void _complete() {
    _cancelTimers();
    emit(const LaunchSplashCompleted());
  }

  void _fail(Object error, StackTrace stackTrace) {
    if (isClosed || _isTerminal) {
      return;
    }
    _cancelTimers();
    emit(LaunchSplashFailed(error, stackTrace));
  }

  void _cancelTimers() {
    _splashTimer?.cancel();
    _timeoutTimer?.cancel();
  }

  @override
  Future<void> close() {
    _cancelTimers();
    return super.close();
  }
}
