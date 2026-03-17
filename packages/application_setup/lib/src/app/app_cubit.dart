// lib/src/app/app_cubit.dart

import 'package:application_setup/src/app/app_cubit_base.dart';
import 'package:application_setup/src/app/app_state.dart';
import 'package:application_setup/src/app/startup_task.dart';

class AppCubit extends AppCubitBase {
  AppCubit({
    required super.tasks,
    super.computeTask,
  });

  bool _tasksComplete = false;
  bool _splashDone = false;

  @override
  void onSplashDone() {
    _splashDone = true;
    if (_tasksComplete) {
      emit(const AppReady());
    } else {
      emit(const AppSplashWaiting());
    }
  }

  @override
  Future<void> initialize() async {
    emit(const AppSplashVisible());
    await _runTasks();
    _tasksComplete = true;
    if (_splashDone) {
      emit(const AppReady());
    } else {
      emit(const AppTasksComplete());
    }
  }

  Future<void> _runTasks() async {
    for (final task in tasks) {
      await _runTask(task);
    }
  }

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
