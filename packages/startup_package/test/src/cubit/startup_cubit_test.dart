// test/src/cubit/startup_cubit_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:startup_package/src/cubit/startup_cubit.dart';

void main() {
  group('StartupCubit', () {
    group('runTasks', () {
      blocTest<StartupCubit, StartupState>(
        'emits [StartupRunningTasks, StartupComplete] '
        'when tasks complete before animation',
        build: () => StartupCubit([() async {}]),
        act: (cubit) async {
          await cubit.runTasks();
          cubit.signalAnimationComplete();
        },
        expect: () => [
          const StartupRunningTasks(),
          const StartupComplete(),
        ],
      );

      blocTest<StartupCubit, StartupState>(
        'emits [StartupRunningTasks, StartupShowLoading, StartupComplete] '
        'when animation completes before tasks',
        build: () => StartupCubit([
          () => Future.delayed(const Duration(milliseconds: 50)),
        ]),
        act: (cubit) async {
          cubit.runTasks();
          cubit.signalAnimationComplete();
          await Future.delayed(const Duration(milliseconds: 100));
        },
        expect: () => [
          const StartupRunningTasks(),
          const StartupShowLoading(),
          const StartupComplete(),
        ],
      );

      blocTest<StartupCubit, StartupState>(
        'emits [StartupRunningTasks, StartupError] '
        'when a task throws',
        build: () => StartupCubit([
          () async => throw Exception('task failed'),
        ]),
        act: (cubit) => cubit.runTasks(),
        expect: () => [
          const StartupRunningTasks(),
          isA<StartupError>(),
        ],
      );

      blocTest<StartupCubit, StartupState>(
        'fails fast on first error with eagerError',
        build: () => StartupCubit([
          () async => throw Exception('first failure'),
          () => Future.delayed(const Duration(seconds: 10)),
        ]),
        act: (cubit) => cubit.runTasks(),
        expect: () => [
          const StartupRunningTasks(),
          isA<StartupError>(),
        ],
      );

      blocTest<StartupCubit, StartupState>(
        'carries the thrown exception in StartupError',
        build: () => StartupCubit([
          () async => throw Exception('boom'),
        ]),
        act: (cubit) => cubit.runTasks(),
        verify: (cubit) {
          final state = cubit.state;
          expect(state, isA<StartupError>());
          expect(
            (state as StartupError).exception.toString(),
            contains('boom'),
          );
        },
      );

      blocTest<StartupCubit, StartupState>(
        'runs multiple tasks concurrently and emits StartupComplete',
        build: () => StartupCubit([
          () async {},
          () async {},
          () async {},
        ]),
        act: (cubit) async {
          await cubit.runTasks();
          cubit.signalAnimationComplete();
        },
        expect: () => [
          const StartupRunningTasks(),
          const StartupComplete(),
        ],
      );
    });

    group('signalAnimationComplete', () {
      blocTest<StartupCubit, StartupState>(
        'emits StartupShowLoading when tasks are not yet complete',
        build: () => StartupCubit([
          () => Future.delayed(const Duration(seconds: 10)),
        ]),
        act: (cubit) {
          cubit.runTasks();
          cubit.signalAnimationComplete();
        },
        expect: () => [
          const StartupRunningTasks(),
          const StartupShowLoading(),
        ],
      );

      blocTest<StartupCubit, StartupState>(
        'does not emit StartupShowLoading when tasks already complete',
        build: () => StartupCubit([() async {}]),
        act: (cubit) async {
          await cubit.runTasks();
          cubit.signalAnimationComplete();
        },
        expect: () => [
          const StartupRunningTasks(),
          const StartupComplete(),
        ],
      );
    });
  });
}
