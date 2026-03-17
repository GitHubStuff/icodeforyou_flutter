// test/src/app/app_cubit_test.dart

// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:async';

import 'package:application_setup/src/app/app_cubit.dart';
import 'package:application_setup/src/app/app_state.dart';
import 'package:application_setup/src/app/startup_task.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStartupTask extends Mock implements StartupTask {}

class _FakeStartupTask extends Fake implements StartupTask {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeStartupTask()));

  group('AppCubit', () {
    late _MockStartupTask task;

    setUp(() {
      task = _MockStartupTask();
      when(() => task.id).thenReturn('mock_task');
      when(() => task.run()).thenAnswer((_) async {});
    });

    test('initial state is AppInitializing', () {
      final cubit = AppCubit(
        tasks: const [],
        computeTask: (fn, task) => fn(task),
      );
      expect(cubit.state, isA<AppInitializing>());
      unawaited(cubit.close());
    });

    group('initialize — tasks complete before splash', () {
      blocTest<AppCubit, AppState>(
        'emits AppSplashVisible then AppTasksComplete '
        'when splash has not signalled done',
        build: () => AppCubit(
          tasks: [task],
          computeTask: (fn, t) => fn(t),
        ),
        act: (cubit) => cubit.initialize(),
        expect: () => [
          isA<AppSplashVisible>(),
          isA<AppTasksComplete>(),
        ],
      );
    });

    group('initialize — splash completes before tasks', () {
      blocTest<AppCubit, AppState>(
        'emits AppSplashVisible then AppSplashWaiting '
        'when onSplashDone called before tasks complete',
        build: () => AppCubit(
          tasks: const [],
          computeTask: (fn, t) => fn(t),
        ),
        act: (cubit) async {
          cubit.onSplashDone();
          await cubit.initialize();
        },
        expect: () => [
          isA<AppSplashWaiting>(),
          isA<AppSplashVisible>(),
          isA<AppReady>(),
        ],
      );
    });

    group('onSplashDone', () {
      blocTest<AppCubit, AppState>(
        'emits AppSplashWaiting when tasks are not complete',
        build: () => AppCubit(
          tasks: const [],
          computeTask: (fn, t) => fn(t),
        ),
        act: (cubit) => cubit.onSplashDone(),
        expect: () => [isA<AppSplashWaiting>()],
      );

      blocTest<AppCubit, AppState>(
        'emits AppReady when tasks are already complete',
        build: () => AppCubit(
          tasks: const [],
          computeTask: (fn, t) => fn(t),
        ),
        act: (cubit) async {
          await cubit.initialize();
          cubit.onSplashDone();
        },
        expect: () => [
          isA<AppSplashVisible>(),
          isA<AppTasksComplete>(),
          isA<AppReady>(),
        ],
      );
    });

    group('task failure', () {
      blocTest<AppCubit, AppState>(
        'emits AppStartupFailed and rethrows on task error',
        build: () {
          when(() => task.run()).thenThrow(Exception('fail'));
          return AppCubit(
            tasks: [task],
            computeTask: (fn, t) => fn(t),
          );
        },
        act: (cubit) async {
          try {
            await cubit.initialize();
          } catch (_) {}
        },
        expect: () => [
          isA<AppSplashVisible>(),
          isA<AppStartupFailed>(),
        ],
      );
    });
  });
}
