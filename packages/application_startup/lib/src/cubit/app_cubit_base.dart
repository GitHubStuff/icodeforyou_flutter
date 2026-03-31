// application_startup/lib/src/app/app_cubit_base.dart
import 'package:application_startup/newsrc/widgets/splash_screen_configuration.dart';
import 'package:application_startup/src/cubit/app_state.dart';
import 'package:application_startup/src/tasks/startup_task.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Signature for a function that executes a [StartupTask] on a background
/// isolate, matching the signature of Flutter's [compute].
typedef ComputeTask =
    Future<void> Function(
      Future<void> Function(StartupTask) fn,
      StartupTask task,
    );

/// Base class for the application startup cubit.
///
/// Subclasses are responsible for orchestrating [StartupTask] execution
/// and transitioning through the [AppState] lifecycle.
abstract class AppCubitBase extends Cubit<AppState> {
  /// Creates an [AppCubitBase] with the given [tasks] and optional
  /// [computeTask] override (defaults to Flutter's [compute]).
  AppCubitBase({
    required List<StartupTask> tasks,
    ComputeTask? computeTask,
  }) : _tasks = tasks,
       _computeTask = computeTask ?? compute,
       super(const AppInitializing());

  final List<StartupTask> _tasks;
  final ComputeTask _computeTask;

  /// The list of startup tasks to be executed during app initialisation.
  @protected
  List<StartupTask> get tasks => _tasks;

  /// The compute function used to run tasks, injectable for testing.
  @protected
  ComputeTask get computeTask => _computeTask;

  /// Triggered when [SplashScreenConfiguration.splashDuration] elapses.
  ///
  /// Emits [AppReady] if all startup tasks have completed, or
  /// [AppSplashWaiting] if tasks are still in progress.
  void onSplashDone();

  /// Executes all [tasks] in sequence, updating [AppState] as each completes.
  Future<void> runStartupTasks();
}
