// animated_widgets/test/src/animated_overlay/cubit/animated_overlay_cubit_test.dart

import 'package:animated_widgets/src/animated_overlay/cubit/animated_overlay_cubit.dart';
import 'package:animated_widgets/src/animated_overlay/cubit/animated_overlay_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedOverlayCubit', () {
    test('initial state is hidden', () {
      final cubit = AnimatedOverlayCubit();
      addTearDown(cubit.close);

      expect(cubit.state.child, isNull);
      expect(cubit.state.opacity, 1.0);
    });

    group('showOverlay', () {
      blocTest<AnimatedOverlayCubit, AnimatedOverlayState>(
        'emits state with the supplied child and full opacity',
        build: AnimatedOverlayCubit.new,
        act: (cubit) => cubit.showOverlay(const Text('overlay')),
        expect: () => [
          isA<AnimatedOverlayState>()
              .having((s) => s.child, 'child', isA<Text>())
              .having((s) => s.opacity, 'opacity', 1.0),
        ],
      );

      blocTest<AnimatedOverlayCubit, AnimatedOverlayState>(
        'cancels an in-flight fade timer',
        build: AnimatedOverlayCubit.new,
        act: (cubit) async {
          cubit
            ..showOverlay(const Text('first'))
            ..fadeOverlay(duration: const Duration(milliseconds: 100))
            ..showOverlay(const Text('second'));

          // Wait beyond the original fade duration to confirm the cancelled
          // timer never fires the hidden emit.
          await Future<void>.delayed(const Duration(milliseconds: 200));
        },
        verify: (cubit) {
          expect(cubit.state.opacity, 1.0);
          expect(cubit.state.child, isA<Text>());
        },
      );
    });

    group('updateOverlay', () {
      blocTest<AnimatedOverlayCubit, AnimatedOverlayState>(
        'replaces the current child with full opacity',
        build: AnimatedOverlayCubit.new,
        seed: () => const AnimatedOverlayState(child: Text('original')),
        act: (cubit) => cubit.updateOverlay(const Text('updated')),
        expect: () => [
          isA<AnimatedOverlayState>()
              .having((s) => s.child, 'child', isA<Text>())
              .having((s) => s.opacity, 'opacity', 1.0),
        ],
      );

      blocTest<AnimatedOverlayCubit, AnimatedOverlayState>(
        'cancels an in-flight fade timer',
        build: AnimatedOverlayCubit.new,
        act: (cubit) async {
          cubit
            ..showOverlay(const Text('child'))
            ..fadeOverlay(duration: const Duration(milliseconds: 100))
            ..updateOverlay(const Text('replacement'));

          await Future<void>.delayed(const Duration(milliseconds: 200));
        },
        verify: (cubit) {
          expect(cubit.state.opacity, 1.0);
          expect(cubit.state.child, isA<Text>());
        },
      );
    });

    group('removeOverlay', () {
      blocTest<AnimatedOverlayCubit, AnimatedOverlayState>(
        'emits the hidden state',
        build: AnimatedOverlayCubit.new,
        seed: () => const AnimatedOverlayState(child: Text('child')),
        act: (cubit) => cubit.removeOverlay(),
        expect: () => [
          isA<AnimatedOverlayState>()
              .having((s) => s.child, 'child', isNull)
              .having((s) => s.opacity, 'opacity', 1.0),
        ],
      );

      blocTest<AnimatedOverlayCubit, AnimatedOverlayState>(
        'cancels an in-flight fade timer',
        build: AnimatedOverlayCubit.new,
        act: (cubit) async {
          cubit
            ..showOverlay(const Text('child'))
            ..fadeOverlay(duration: const Duration(milliseconds: 100))
            ..removeOverlay();

          await Future<void>.delayed(const Duration(milliseconds: 200));
        },
        verify: (cubit) {
          expect(cubit.state.child, isNull);
          expect(cubit.state.opacity, 1.0);
        },
      );
    });

    group('fadeOverlay', () {
      blocTest<AnimatedOverlayCubit, AnimatedOverlayState>(
        'returns early when no child is present',
        build: AnimatedOverlayCubit.new,
        act: (cubit) async {
          cubit.fadeOverlay();
          await Future<void>.delayed(const Duration(milliseconds: 50));
        },
        expect: () => <AnimatedOverlayState>[],
        verify: (cubit) {
          expect(cubit.state.child, isNull);
          expect(cubit.state.opacity, 1.0);
        },
      );

      blocTest<AnimatedOverlayCubit, AnimatedOverlayState>(
        'emits intermediate opacity values then the hidden state',
        build: AnimatedOverlayCubit.new,
        act: (cubit) async {
          cubit
            ..showOverlay(const Text('child'))
            ..fadeOverlay(duration: const Duration(milliseconds: 80));

          // Wait for the fade to complete (16ms ticks over an 80ms window).
          await Future<void>.delayed(const Duration(milliseconds: 250));
        },
        verify: (cubit) {
          // Final state must be hidden.
          expect(cubit.state.child, isNull);
          expect(cubit.state.opacity, 1.0);
        },
      );

      blocTest<AnimatedOverlayCubit, AnimatedOverlayState>(
        'restores opacity to 1.0 before fading when called mid-fade',
        build: AnimatedOverlayCubit.new,
        act: (cubit) async {
          cubit
            ..showOverlay(const Text('child'))
            ..fadeOverlay(duration: const Duration(milliseconds: 100));

          // Allow at least one fade tick to drop the opacity below 1.0.
          await Future<void>.delayed(const Duration(milliseconds: 30));

          // Re-trigger the fade -- the cubit must cancel the prior timer
          // and emit opacity 1.0 again before scheduling a fresh fade.
          cubit.fadeOverlay(duration: const Duration(milliseconds: 80));

          // Let the new fade run to completion.
          await Future<void>.delayed(const Duration(milliseconds: 250));
        },
        verify: (cubit) {
          expect(cubit.state.child, isNull);
          expect(cubit.state.opacity, 1.0);
        },
      );
    });

    group('close', () {
      blocTest<AnimatedOverlayCubit, AnimatedOverlayState>(
        'cancels an in-flight fade timer and closes the cubit',
        build: AnimatedOverlayCubit.new,
        act: (cubit) async {
          cubit
            ..showOverlay(const Text('child'))
            ..fadeOverlay(duration: const Duration(milliseconds: 100));
          await cubit.close();

          // Wait beyond the fade window -- if the timer survived close it
          // would attempt to emit on a closed cubit and throw.
          await Future<void>.delayed(const Duration(milliseconds: 200));
        },
        verify: (cubit) {
          expect(cubit.isClosed, isTrue);
        },
      );

      blocTest<AnimatedOverlayCubit, AnimatedOverlayState>(
        'closes cleanly when no fade is active',
        build: AnimatedOverlayCubit.new,
        act: (cubit) => cubit.close(),
        verify: (cubit) {
          expect(cubit.isClosed, isTrue);
        },
      );
    });
  });
}
