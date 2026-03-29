// test/src/cubit/rail_menu_cubit_test.dart

import 'package:animated_rail_menu/src/cubit/rail_menu_cubit.dart';
import 'package:animated_rail_menu/src/cubit/rail_menu_state.dart';
import 'package:animated_rail_menu/src/model/rail_direction.dart';
import 'package:animated_rail_menu/src/model/rail_transition.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RailMenuCubit', () {
    test('initial state uses defaultIndex 0', () {
      expect(
        RailMenuCubit().state,
        equals(const RailMenuState(activeIndex: 0)),
      );
    });

    test('initial state uses provided defaultIndex', () {
      expect(
        RailMenuCubit(defaultIndex: 3).state,
        equals(const RailMenuState(activeIndex: 3)),
      );
    });

    test('activeIndex returns state.activeIndex', () {
      final cubit = RailMenuCubit(defaultIndex: 2);
      expect(cubit.activeIndex, 2);
    });

    test('transition returns state.transition', () {
      final cubit = RailMenuCubit();
      expect(cubit.transition, RailTransition.crossFade);
    });

    blocTest<RailMenuCubit, RailMenuState>(
      'setActive emits new state with index and transition',
      build: RailMenuCubit.new,
      act: (cubit) => cubit.setActive(2, RailTransition.slideLeft),
      expect: () => [
        const RailMenuState(
          activeIndex: 2,
          transition: RailTransition.slideLeft,
        ),
      ],
    );

    blocTest<RailMenuCubit, RailMenuState>(
      'setActive does not emit when index is already active',
      build: RailMenuCubit.new,
      act: (cubit) => cubit.setActive(0, RailTransition.slideLeft),
      expect: () => <RailMenuState>[],
    );

    group('resolveDirectional — horizontal', () {
      test('forward tap returns slideRight', () {
        final cubit = RailMenuCubit();
        expect(
          cubit.resolveDirectional(
            tappedIndex: 2,
            direction: RailDirection.horizontal,
          ),
          RailTransition.slideRight,
        );
      });

      test('backward tap returns slideLeft', () {
        final cubit = RailMenuCubit(defaultIndex: 3);
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
        final cubit = RailMenuCubit();
        expect(
          cubit.resolveDirectional(
            tappedIndex: 2,
            direction: RailDirection.vertical,
          ),
          RailTransition.slideDown,
        );
      });

      test('backward tap returns slideUp', () {
        final cubit = RailMenuCubit(defaultIndex: 3);
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
