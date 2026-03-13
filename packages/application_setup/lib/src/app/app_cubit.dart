// lib/src/app/app_cubit.dart

import 'package:application_setup/src/app/app_cubit_base.dart';
import 'package:application_setup/src/app/app_state.dart';
import 'package:application_setup/src/app/startup_task.dart';

class AppCubit extends AppCubitBase {
  AppCubit({
    required super.tasks,
    required super.splashDuration,
    super.computeTask,
  });

  @override
  Future<void> initialize() async {
    emit(const AppSplashVisible());

    await Future.wait([
      _runTasks(),
      Future<void>.delayed(splashDuration),
    ]);

    emit(const AppReady());
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
