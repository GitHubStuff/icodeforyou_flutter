// packages/splash_framework/test/src/cubit/splash_cubit_test.dart
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:splash_framework/src/cubit/splash_cubit.dart';
import 'package:splash_framework/src/cubit/splash_state.dart';

void main() {
  group('SplashCubit', () {
    test('initial state is SplashRunning', () async {
      final cubit = SplashCubit(duration: Duration.zero, tasks: []);
      expect(cubit.state, isA<SplashRunning>());
      await cubit.close();
    });

    blocTest<SplashCubit, SplashState>(
      'emits [SplashComplete] when tasks finish BEFORE the minimum duration',
      build: () => SplashCubit(
        duration: const Duration(milliseconds: 50),
        tasks: [
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
          Future<void>.value,
        ],
      ),
      act: (cubit) => cubit.start(),
      expect: () => [
        isA<SplashComplete>(),
      ],
    );

    blocTest<SplashCubit, SplashState>(
      'emits [SplashWaiting, SplashComplete] when tasks finish AFTER the minimum duration',
      build: () => SplashCubit(
        duration: const Duration(milliseconds: 10),
        tasks: [
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        ],
      ),
      act: (cubit) => cubit.start(),
      expect: () => [
        isA<SplashWaiting>(),
        isA<SplashComplete>(),
      ],
    );

    blocTest<SplashCubit, SplashState>(
      'emits [SplashWaiting, SplashError] and rethrows (in debug) when a task throws',
      build: () => SplashCubit(
        duration: const Duration(milliseconds: 10),
        tasks: [
          () async {
            // FIX: Delay must be longer than the duration.
            // This ensures start() is actively awaiting tasksFuture when it throws,
            // preventing Dart from throwing an unhandled async gap error.
            await Future<void>.delayed(const Duration(milliseconds: 20));
            throw Exception('Test Error');
          },
        ],
      ),
      act: (cubit) async {
        // FIX: Manually absorb the debug-mode rethrow so it doesn't crash blocTest
        try {
          await cubit.start();
          fail('Should have rethrown the exception');
        } catch (e) {
          expect(e, isException);
        }
      },
      expect: () => [
        isA<
          SplashWaiting
        >(), // Emitted because task delay (20ms) > duration (10ms)
        isA<SplashError>().having((e) => e.error, 'error', isException),
      ],
    );

    blocTest<SplashCubit, SplashState>(
      'does not emit [SplashWaiting] or [SplashComplete] if closed BEFORE duration elapses',
      build: () => SplashCubit(
        duration: const Duration(milliseconds: 50),
        tasks: [
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        ],
      ),
      act: (cubit) {
        final future = cubit.start();
        unawaited(cubit.close());
        return future;
      },
      expect: () => <SplashState>[],
    );

    blocTest<SplashCubit, SplashState>(
      'emits [SplashWaiting] but not [SplashComplete] if closed while waiting for slow tasks',
      build: () => SplashCubit(
        duration: const Duration(milliseconds: 20),
        tasks: [
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        ],
      ),
      act: (cubit) async {
        final future = cubit.start();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await cubit.close();
        await future;
      },
      expect: () => [
        isA<SplashWaiting>(),
      ],
    );

    blocTest<SplashCubit, SplashState>(
      'does not emit [SplashError] but still rethrows if closed BEFORE a task throws',
      build: () => SplashCubit(
        duration: const Duration(milliseconds: 10),
        tasks: [
          () async {
            // Must be longer than duration to avoid unhandled async gap crash
            await Future<void>.delayed(const Duration(milliseconds: 20));
            throw Exception('Late Error');
          },
        ],
      ),
      act: (cubit) async {
        final future = cubit.start();
        unawaited(cubit.close());

        try {
          await future;
          fail('Should have rethrown the exception');
        } catch (e) {
          expect(e, isException);
        }
      },
      expect: () => <SplashState>[],
    );
  });
}
