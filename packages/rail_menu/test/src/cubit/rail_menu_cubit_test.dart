// test/src/cubit/rail_menu_cubit_test.dart

// ignore_for_file: cascade_invocations, discarded_futures

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rail_menu/rail_menu.dart';

void main() {
  group('RailMenuCubit', () {
    test('initial state has activeIndex 0 and transition none', () {
      final cubit = RailMenuCubit();
      expect(cubit.activeIndex, equals(0));
      expect(cubit.transition, equals(RailMenuTransition.none));
      cubit.close();
    });

    test('defaultIndex seeds activeIndex', () {
      final cubit = RailMenuCubit(defaultIndex: 3);
      expect(cubit.activeIndex, equals(3));
      cubit.close();
    });

    blocTest<RailMenuCubit, RailMenuState>(
      'setActive emits new state with index and transition',
      build: RailMenuCubit.new,
      act: (cubit) =>
          cubit.setActive(2, RailMenuTransition.slideFromRight),
      expect: () => [
        const RailMenuState(
          activeIndex: 2,
          transition: RailMenuTransition.slideFromRight,
        ),
      ],
    );

    blocTest<RailMenuCubit, RailMenuState>(
      'setActive is a no-op when index matches current activeIndex',
      build: RailMenuCubit.new,
      act: (cubit) => cubit.setActive(0, RailMenuTransition.fade),
      expect: () => <RailMenuState>[],
    );

    blocTest<RailMenuCubit, RailMenuState>(
      'setActive emits multiple times for distinct indexes',
      build: RailMenuCubit.new,
      act: (cubit) {
        cubit.setActive(1, RailMenuTransition.slideFromRight);
        cubit.setActive(2, RailMenuTransition.slideFromLeft);
      },
      expect: () => [
        const RailMenuState(
          activeIndex: 1,
          transition: RailMenuTransition.slideFromRight,
        ),
        const RailMenuState(
          activeIndex: 2,
          transition: RailMenuTransition.slideFromLeft,
        ),
      ],
    );
  });
}
