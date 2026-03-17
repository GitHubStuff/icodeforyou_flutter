// lib/src/app/startup_task.dart

abstract class StartupTask {
  const StartupTask(); // coverage:ignore-line

  String get id;

  Future<void> run();
}
