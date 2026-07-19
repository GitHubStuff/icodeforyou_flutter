// packages/animated_widgets/test/src/crossfade_widgets/crossfade_widgets_cubit_test.dart

import 'package:animated_widgets/src/crossfade_widgets/crossfade_widgets_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:custom_widgets/custom_widgets.dart' show DirectionalController;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDirectionalController extends Mock implements DirectionalController {}

// Typed no-op so its static type is `void Function()` (== VoidCallback),
// which is the parameter type mocktail's `any()` must fabricate for the
// addListener/removeListener matchers.
void _noopListener() {}

void main() {
  late _MockDirectionalController controller;

  // The cubit subscribes by calling `controller.addListener(_syncFromController)`.
  // We can't reach that private method directly, so we capture the callback the
  // cubit hands to the mock and invoke it ourselves to simulate a move.
  late void Function() syncListener;

  setUpAll(() {
    registerFallbackValue(_noopListener);
  });

  setUp(() {
    controller = _MockDirectionalController();
    when(() => controller.value).thenReturn(0);
    when(() => controller.addListener(any())).thenAnswer((invocation) {
      syncListener = invocation.positionalArguments.first as void Function();
    });
    when(() => controller.removeListener(any())).thenReturn(null);
  });

  // Re-points the controller and fires the captured subscription, mimicking a
  // real DirectionalController value change.
  void moveControllerTo(double value) {
    when(() => controller.value).thenReturn(value);
    syncListener();
  }

  CrossFadeWidgetsCubit buildCubit({
    int length = 3,
    void Function(int index)? onIndexChanged,
  }) {
    final cubit = CrossFadeWidgetsCubit(
      controller: controller,
      length: length,
      onIndexChanged: onIndexChanged,
    );
    addTearDown(cubit.close);
    return cubit;
  }

  group('CrossFadeWidgetsCubit', () {
    group('construction', () {
      test('seeds state from the rounded, clamped controller value', () {
        when(() => controller.value).thenReturn(4.7);

        expect(buildCubit(length: 3).state, 2);
      });

      test('subscribes to the controller exactly once', () {
        buildCubit(length: 2);

        verify(() => controller.addListener(any())).called(1);
      });

      test('asserts when length is less than two', () {
        expect(
          () => CrossFadeWidgetsCubit(controller: controller, length: 1),
          throwsAssertionError,
        );
      });
    });

    group('grid bounds', () {
      test('expose a fixed integer grid derived from length', () {
        final cubit = buildCubit(length: 5);

        expect(cubit.min, 0);
        expect(cubit.max, 4);
        expect(cubit.step, 1);
      });
    });

    group('controller synchronisation', () {
      blocTest<CrossFadeWidgetsCubit, int>(
        'emits the rounded, clamped index and skips no-op moves',
        build: () => buildCubit(length: 4),
        act: (_) {
          moveControllerTo(1.6); // round -> 2
          moveControllerTo(2.4); // round -> 2: duplicate, no emit
          moveControllerTo(9); // clamp -> 3
        },
        expect: () => const [2, 3],
      );

      test(
        'reports each transition through onIndexChanged, but not the seed',
        () {
          final reported = <int>[];
          final cubit = buildCubit(length: 3, onIndexChanged: reported.add);

          expect(cubit.state, 0);
          expect(reported, isEmpty); // initial index is never reported

          moveControllerTo(1);
          moveControllerTo(2);
          moveControllerTo(2); // unchanged: not reported
          moveControllerTo(0);

          expect(reported, [1, 2, 0]);
        },
      );
    });

    group('close', () {
      test('removes its controller listener and closes', () async {
        final cubit = CrossFadeWidgetsCubit(controller: controller, length: 2);

        await cubit.close();

        verify(() => controller.removeListener(any())).called(1);
        expect(cubit.isClosed, isTrue);
      });
    });
  });
}
