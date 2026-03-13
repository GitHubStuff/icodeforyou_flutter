// lib/src/app/startup_task.dart

abstract class StartupTask {
  const StartupTask();

  String get id;

  Future<void> run();
}
