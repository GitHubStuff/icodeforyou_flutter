// test/src/cubit/rail_menu_state_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:rail_menu/rail_menu.dart';

void main() {
  group('RailMenuState', () {
    test('defaults transition to RailMenuTransition.none', () {
      const state = RailMenuState(activeIndex: 0);
      expect(state.transition, equals(RailMenuTransition.none));
    });

    test('exposes activeIndex and transition', () {
      const state = RailMenuState(
        activeIndex: 2,
        transition: RailMenuTransition.slideFromLeft,
      );
      expect(state.activeIndex, equals(2));
      expect(state.transition, equals(RailMenuTransition.slideFromLeft));
    });

    test('two states with same values are equal', () {
      const a = RailMenuState(
        activeIndex: 1,
        transition: RailMenuTransition.fade,
      );
      const b = RailMenuState(
        activeIndex: 1,
        transition: RailMenuTransition.fade,
      );
      expect(a, equals(b));
    });

    test('two states with different activeIndex are not equal', () {
      const a = RailMenuState(activeIndex: 0);
      const b = RailMenuState(activeIndex: 1);
      expect(a, isNot(equals(b)));
    });

    test('two states with different transition are not equal', () {
      const a = RailMenuState(
        activeIndex: 0,
        transition: RailMenuTransition.fade,
      );
      const b = RailMenuState(
        activeIndex: 0,
        transition: RailMenuTransition.slideFromLeft,
      );
      expect(a, isNot(equals(b)));
    });

    test('hashCode is consistent with equality', () {
      const a = RailMenuState(
        activeIndex: 1,
        transition: RailMenuTransition.fade,
      );
      const b = RailMenuState(
        activeIndex: 1,
        transition: RailMenuTransition.fade,
      );
      expect(a.hashCode, equals(b.hashCode));
    });

    test('identical instances are equal', () {
      const state = RailMenuState(activeIndex: 0);
      expect(state == state, isTrue);
    });

    test('not equal to different type', () {
      const state = RailMenuState(activeIndex: 0);
      // ignore: unrelated_type_equality_checks
      expect(state == 'other', isFalse);
    });
  });
}
