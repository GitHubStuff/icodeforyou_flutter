// animated_widgets/test/src/stepper_crossfade/stepper_crossfade_cubit_test.dart

// ignore_for_file: always_use_package_imports

import 'package:animated_widgets/src/stepper_crossfade/stepper_crossfade_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slider_directional/slider_directional.dart' show DirectionalController;

void main() {
  group('StepperCrossFadeCubit', () {
    late DirectionalController controller;

    setUp(() => controller = DirectionalController());
    tearDown(() => controller.dispose());

    test('asserts length >= 2', () {
      expect(
        () => StepperCrossFadeCubit(controller: controller, length: 1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('initial state is the controller value, rounded and clamped', () {
      // 2.6 -> round 3 -> clamp(0, length-1=2) -> 2.
      final c = DirectionalController(initial: 2.6);
      addTearDown(c.dispose);

      final cubit = StepperCrossFadeCubit(controller: c, length: 3);
      addTearDown(cubit.close);

      expect(cubit.state, 2);
    });

    test('initial state clamps a negative controller value up to 0', () {
      final c = DirectionalController(initial: -5);
      addTearDown(c.dispose);

      final cubit = StepperCrossFadeCubit(controller: c, length: 3);
      addTearDown(cubit.close);

      expect(cubit.state, 0);
    });

    test('exposes the fixed grid bounds derived from length', () {
      final cubit = StepperCrossFadeCubit(controller: controller, length: 4);
      addTearDown(cubit.close);

      expect(cubit.min, 0);
      expect(cubit.max, 3); // length - 1
      expect(cubit.step, 1);
    });

    blocTest<StepperCrossFadeCubit, int>(
      'emits the clamped, rounded index when the controller value changes',
      build: () => StepperCrossFadeCubit(controller: controller, length: 3),
      act: (_) {
        controller.value = 1.4; // round -> 1
        controller.value = 2.9; // round 3 -> clamp -> 2
      },
      expect: () => [1, 2],
    );

    test('a later value rounding to the current index leaves state unchanged',
        () async {
      final cubit = StepperCrossFadeCubit(controller: controller, length: 3);
      addTearDown(cubit.close);

      controller.value = 1; // index 1
      expect(cubit.state, 1);

      controller.value = 1.2; // still rounds to 1
      expect(cubit.state, 1);
    });

    test('onIndexChanged fires with the new index on a real transition', () {
      final reported = <int>[];
      final cubit = StepperCrossFadeCubit(
        controller: controller,
        length: 3,
        onIndexChanged: reported.add,
      );
      addTearDown(cubit.close);

      controller.value = 2;
      expect(reported, [2]);
    });

    test('onChange equal-state branch does not invoke onIndexChanged', () {
      var called = false;
      final cubit = StepperCrossFadeCubit(
        controller: controller,
        length: 3,
        onIndexChanged: (_) => called = true,
      );
      addTearDown(cubit.close);

      // Directly exercise the guard: currentState == nextState -> skip callback.
      cubit.onChange(const Change(currentState: 0, nextState: 0));
      expect(called, isFalse);
    });

    test('null onIndexChanged is safe on a real transition (?. short-circuit)',
        () {
      final cubit = StepperCrossFadeCubit(controller: controller, length: 3);
      addTearDown(cubit.close);

      expect(() => controller.value = 1, returnsNormally);
      expect(cubit.state, 1);
    });

    test('close removes the controller listener', () async {
      final cubit = StepperCrossFadeCubit(controller: controller, length: 3);

      await cubit.close();

      // After close the listener is gone: driving the controller must not
      // throw (no emit-after-close) and the controller still works standalone.
      expect(() => controller.value = 2, returnsNormally);
      expect(controller.value, 2);
    });
  });
}
