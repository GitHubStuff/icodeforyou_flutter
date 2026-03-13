// test/src/app/app_cubit_test.dart

import 'package:application_setup/src/app/app_cubit.dart';
import 'package:application_setup/src/app/app_state.dart';
import 'package:application_setup/src/app/startup_task.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _directCompute(
  Future<void> Function(StartupTask) fn,
  StartupTask task,
) =>
    fn(task);

class _InstantTask extends StartupTask {
  const _InstantTask();

  @override
  String get id => 'instant_task';

  @override
  Future<void> run() async {}
}

class _SlowTask extends StartupTask {
  const _SlowTask();

  @override
  String get id => 'slow_task';

  @override
  Future<void> run() async =>
      Future<void>.delayed(const Duration(milliseconds: 100));
}

class _ThrowingTask extends StartupTask {
  const _ThrowingTask();

  @override
  String get id => 'throwing_task';

  @override
  Future<void> run() async => throw Exception('task failed');
}

AppCubit _cubit({
  List<StartupTask> tasks = const [],
  Duration splashDuration = Duration.zero,
}) =>
    AppCubit(
      tasks: tasks,
      splashDuration: splashDuration,
      computeTask: _directCompute,
    );

void main() {
  group('AppCubit', () {
    test('initial state is AppInitializing', () async {
      final cubit = _cubit();
      expect(cubit.state, isA<AppInitializing>());
      await cubit.close();
    });

    blocTest<AppCubit, AppState>(
      'emits [AppSplashVisible, AppReady] with no tasks',
      build: _cubit,
      act: (cubit) async => cubit.initialize(),
      expect: () => [
        isA<AppSplashVisible>(),
        isA<AppReady>(),
      ],
    );

    blocTest<AppCubit, AppState>(
      'emits [AppSplashVisible, AppReady] when task finishes before splash',
      build: () => _cubit(
        tasks: const [_InstantTask()],
        splashDuration: const Duration(milliseconds: 50),
      ),
      act: (cubit) async => cubit.initialize(),
      expect: () => [
        isA<AppSplashVisible>(),
        isA<AppReady>(),
      ],
    );

    blocTest<AppCubit, AppState>(
      'emits [AppSplashVisible, AppReady] when splash finishes before task',
      build: () => _cubit(tasks: const [_SlowTask()]),
      act: (cubit) async => cubit.initialize(),
      expect: () => [
        isA<AppSplashVisible>(),
        isA<AppReady>(),
      ],
    );

    blocTest<AppCubit, AppState>(
      'emits [AppSplashVisible, AppStartupFailed] on throwing task',
      build: () => _cubit(tasks: const [_ThrowingTask()]),
      act: (cubit) async {
        try {
          await cubit.initialize();
        } on Exception catch (_) {}
      },
      expect: () => [
        isA<AppSplashVisible>(),
        isA<AppStartupFailed>(),
      ],
    );

    test('AppStartupFailed carries correct taskId on failure', () async {
      final cubit = _cubit(tasks: const [_ThrowingTask()]);
      final states = <AppState>[];
      final sub = cubit.stream.listen(states.add);
      try {
        await cubit.initialize();
      } on Exception catch (_) {}
      await sub.cancel();
      final failed = states.whereType<AppStartupFailed>().first;
      expect(failed.taskId, 'throwing_task');
      await cubit.close();
    });
  });
}
