// application_startup/lib/src/app/app_cubit.dart
import 'package:application_startup/src/cubit/app_cubit_base.dart';
import 'package:application_startup/src/cubit/app_state.dart';
import 'package:application_startup/src/tasks/startup_task.dart';

/// Orchestrates the application startup sequence, coordinating splash
/// visibility with wave-based [StartupTask] execution.
class AppCubit extends AppCubitBase {
  /// Creates an [AppCubit] with the required [tasks] list and an optional
  /// [computeTask] override for isolate-based execution.
  AppCubit({
    required super.tasks,
    super.computeTask,
  });

  bool _tasksComplete = false;
  bool _splashDone = false;

  /// Called by the splash screen when its exit animation has completed.
  ///
  /// If tasks are already finished, transitions immediately to [AppReady];
  /// otherwise waits in [AppSplashWaiting] until tasks complete.
  @override
  void onSplashDone() {
    _splashDone = true;
    if (_tasksComplete) {
      emit(const AppReady());
    } else {
      emit(const AppSplashWaiting());
    }
  }

  /// Begins the startup task pipeline, emitting [AppSplashVisible] first,
  /// then running all [tasks] in dependency order.
  ///
  /// Transitions to [AppReady] if the splash is already done, otherwise
  /// emits [AppTasksComplete] to signal the splash it may now dismiss.
  @override
  Future<void> runStartupTasks() async {
    assert(
      tasks.map((t) => t.id).toSet().length == tasks.length,
      'Duplicate StartupTask ids detected',
    );
    emit(const AppSplashVisible());
    await _runTasks();
    _tasksComplete = true;
    if (_splashDone) {
      emit(const AppReady());
    } else {
      emit(const AppTasksComplete());
    }
  }

  /// Executes all [tasks] in waves, where each wave contains only tasks
  /// whose dependencies have already completed.
  Future<void> _runTasks() async {
    final remaining = tasks.toList();
    final completed = <String>{};
    while (remaining.isNotEmpty) {
      final wave = remaining
          .where((t) => completed.containsAll(t.dependencies))
          .toList();
      assert(wave.isNotEmpty, 'Circular or unresolvable dependencies detected');
      await Future.wait(wave.map(_runTask));
      completed.addAll(wave.map((t) => t.id));
      remaining.removeWhere(wave.contains);
    }
  }

  /// Runs a single [task] via [computeTask], emitting [AppStartupFailed]
  /// on error before rethrowing.
  Future<void> _runTask(StartupTask task) async {
    try {
      await computeTask(_execute, task);
    } catch (error) {
      emit(AppStartupFailed(taskId: task.id, error: error));
      rethrow;
    }
  }

  static Future<void> _execute(StartupTask task) => task.run();
}
