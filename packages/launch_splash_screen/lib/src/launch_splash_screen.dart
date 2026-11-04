// packages/launch_splash_screen/lib/src/launch_splash_screen.dart

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocBuilder, BlocListener, BlocProvider;
import 'package:launch_splash_screen/src/cubit/launch_splash_cubit.dart'
    show LaunchSplashCubit;
import 'package:launch_splash_screen/src/cubit/launch_splash_state.dart'
    show
        LaunchSplashCompleted,
        LaunchSplashFailed,
        LaunchSplashShowing,
        LaunchSplashState,
        LaunchSplashWaiting;
import 'package:launch_splash_screen/src/launch_task.dart' show LaunchTask;

/// Called when the splash has finished and the app should move on.
///
/// Typically navigates away and removes the splash from the stack, e.g.
/// `Navigator.of(context).pushReplacementNamed('/home')`.
typedef LaunchCompletedCallback = void Function(BuildContext context);

/// Called when a task threw or the timeout elapsed.
///
/// On timeout [error] is a `TimeoutException` and [stackTrace] marks where
/// the timeout fired; otherwise they are whatever the task threw and the
/// trace captured at that throw. Both are suitable for forwarding to crash
/// reporting as-is.
typedef LaunchFailureCallback = void Function(
  BuildContext context,
  Object error,
  StackTrace stackTrace,
);

/// Shows [child] while [backgroundTasks] run, then hands off to the app.
///
/// * [child] is visible for at least [splashDuration].
/// * If the tasks are still running when [splashDuration] elapses,
///   [spinner] is shown centred over [child].
/// * When the tasks finish (and [splashDuration] has elapsed),
///   [onCompleted] is called once.
/// * If any task throws, or [timeoutDuration] elapses first, [onFailure]
///   is called once.
///
/// This widget knows nothing about routes; navigation is the caller's job
/// inside [onCompleted] and [onFailure].
class LaunchSplashScreen extends StatelessWidget {
  /// Creates a launch splash.
  ///
  /// [timeoutDuration] must be at least [splashDuration] plus
  /// `minimumTimeoutMargin`.
  const LaunchSplashScreen({
    required this.timeoutDuration,
    required this.child,
    required this.spinner,
    required this.onCompleted,
    required this.onFailure,
    required this.splashDuration,
    this.backgroundTasks = const [],
    super.key,
  });

  /// How long [child] is shown before [spinner] may appear.
  final Duration splashDuration;

  /// How long [backgroundTasks] may run before [onFailure] is called.
  final Duration timeoutDuration;

  /// The splash content.
  final Widget child;

  /// Shown centred over [child] while tasks outlast [splashDuration].
  final Widget spinner;

  /// Work to run while [child] is shown; tasks run concurrently.
  final List<LaunchTask> backgroundTasks;

  /// Invoked once when the splash completes.
  final LaunchCompletedCallback onCompleted;

  /// Invoked once when a task throws or the timeout elapses.
  final LaunchFailureCallback onFailure;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LaunchSplashCubit>(
      create: (_) => LaunchSplashCubit(
        splashDuration: splashDuration,
        timeoutDuration: timeoutDuration,
        tasks: backgroundTasks,
      )..start(),
      child: BlocListener<LaunchSplashCubit, LaunchSplashState>(
        listenWhen: (_, current) =>
            current is LaunchSplashCompleted || current is LaunchSplashFailed,
        listener: _onTerminalState,
        child: BlocBuilder<LaunchSplashCubit, LaunchSplashState>(
          buildWhen: (_, current) =>
              current is LaunchSplashShowing || current is LaunchSplashWaiting,
          builder: (_, state) => Stack(
            fit: StackFit.expand,
            children: [
              child,
              if (state is LaunchSplashWaiting) Center(child: spinner),
            ],
          ),
        ),
      ),
    );
  }

  void _onTerminalState(BuildContext context, LaunchSplashState state) {
    switch (state) {
      case LaunchSplashCompleted():
        onCompleted(context);
      case LaunchSplashFailed(:final error, :final stackTrace):
        onFailure(context, error, stackTrace);
      case LaunchSplashShowing():
      case LaunchSplashWaiting():
        break;
    }
  }
}
