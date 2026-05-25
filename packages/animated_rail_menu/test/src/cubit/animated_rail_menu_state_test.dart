// animated_rail_menu/test/src/cubit/animated_rail_menu_state_test.dart

// ignore_for_file: document_ignores

import 'package:animated_rail_menu/src/cubit/animated_rail_menu_state.dart';
import 'package:animated_rail_menu/src/model/rail_transition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedRailMenuState', () {
    test('default transition is crossFade', () {
      const state = AnimatedRailMenuState(activeIndex: 0);
      expect(state.transition, RailTransition.crossFade);
    });

    test('exposes activeIndex and transition', () {
      const state = AnimatedRailMenuState(
        activeIndex: 2,
        transition: RailTransition.slideLeft,
      );
      expect(state.activeIndex, 2);
      expect(state.transition, RailTransition.slideLeft);
    });

    test('two states with same values are equal', () {
      const a = AnimatedRailMenuState(activeIndex: 1, transition: RailTransition.scale);
      const b = AnimatedRailMenuState(activeIndex: 1, transition: RailTransition.scale);
      expect(a, equals(b));
    });

    test('two states with different activeIndex are not equal', () {
      const a = AnimatedRailMenuState(activeIndex: 0);
      const b = AnimatedRailMenuState(activeIndex: 1);
      expect(a, isNot(equals(b)));
    });

    test('two states with different transition are not equal', () {
      const a = AnimatedRailMenuState(
        activeIndex: 0,
        transition: RailTransition.slideLeft,
      );
      const b = AnimatedRailMenuState(
        activeIndex: 0,
        transition: RailTransition.slideRight,
      );
      expect(a, isNot(equals(b)));
    });

    test('hashCode is consistent with equality', () {
      const a = AnimatedRailMenuState(activeIndex: 1, transition: RailTransition.scale);
      const b = AnimatedRailMenuState(activeIndex: 1, transition: RailTransition.scale);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('identical instances are equal', () {
      const state = AnimatedRailMenuState(activeIndex: 0);
      expect(state == state, isTrue);
    });

    test('not equal to non-AnimatedRailMenuState object', () {
      const state = AnimatedRailMenuState(activeIndex: 0);
      // ignore: unrelated_type_equality_checks
      expect(state == 'other', isFalse);
    });
  });
}
