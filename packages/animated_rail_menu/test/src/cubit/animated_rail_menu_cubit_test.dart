// animated_rail_menu/test/src/cubit/animated_rail_menu_cubit_test.dart

import 'package:animated_rail_menu/src/cubit/animated_rail_menu_cubit.dart';
import 'package:animated_rail_menu/src/cubit/animated_rail_menu_state.dart';
import 'package:animated_rail_menu/src/model/rail_direction.dart';
import 'package:animated_rail_menu/src/model/rail_transition.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedRailMenuCubit', () {
    test('initial state uses defaultIndex 0', () {
      expect(
        AnimatedRailMenuCubit().state,
        equals(const AnimatedRailMenuState(activeIndex: 0)),
      );
    });

    test('initial state uses provided defaultIndex', () {
      expect(
        AnimatedRailMenuCubit(defaultIndex: 3).state,
        equals(const AnimatedRailMenuState(activeIndex: 3)),
      );
    });

    test('activeIndex returns state.activeIndex', () {
      final cubit = AnimatedRailMenuCubit(defaultIndex: 2);
      expect(cubit.activeIndex, 2);
    });

    test('transition returns state.transition', () {
      final cubit = AnimatedRailMenuCubit();
      expect(cubit.transition, RailTransition.crossFade);
    });

    blocTest<AnimatedRailMenuCubit, AnimatedRailMenuState>(
      'setActive emits new state with index and transition',
      build: AnimatedRailMenuCubit.new,
      act: (cubit) => cubit.setActive(2, RailTransition.slideLeft),
      expect: () => [
        const AnimatedRailMenuState(
          activeIndex: 2,
          transition: RailTransition.slideLeft,
        ),
      ],
    );

    blocTest<AnimatedRailMenuCubit, AnimatedRailMenuState>(
      'setActive does not emit when index is already active',
      build: AnimatedRailMenuCubit.new,
      act: (cubit) => cubit.setActive(0, RailTransition.slideLeft),
      expect: () => <AnimatedRailMenuState>[],
    );

    group('resolveDirectional — horizontal', () {
      test('forward tap returns slideRight', () {
        final cubit = AnimatedRailMenuCubit();
        expect(
          cubit.resolveDirectional(
            tappedIndex: 2,
            direction: RailDirection.horizontal,
          ),
          RailTransition.slideRight,
        );
      });

      test('backward tap returns slideLeft', () {
        final cubit = AnimatedRailMenuCubit(defaultIndex: 3);
        expect(
          cubit.resolveDirectional(
            tappedIndex: 1,
            direction: RailDirection.horizontal,
          ),
          RailTransition.slideLeft,
        );
      });
    });

    group('resolveDirectional — vertical', () {
      test('forward tap returns slideDown', () {
        final cubit = AnimatedRailMenuCubit();
        expect(
          cubit.resolveDirectional(
            tappedIndex: 2,
            direction: RailDirection.vertical,
          ),
          RailTransition.slideDown,
        );
      });

      test('backward tap returns slideUp', () {
        final cubit = AnimatedRailMenuCubit(defaultIndex: 3);
        expect(
          cubit.resolveDirectional(
            tappedIndex: 1,
            direction: RailDirection.vertical,
          ),
          RailTransition.slideUp,
        );
      });
    });
  });
}
