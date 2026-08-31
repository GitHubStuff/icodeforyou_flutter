// packages/app_navigation/test/src/cubit/navigation_state_test.dart

import 'package:app_navigation/src/cubit/navigation_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NavigationState', () {
    const destinationName = 'home';

    test('supports value equality', () {
      expect(
        const NavigationState(
          destinationName: destinationName,
        ),
        equals(
          const NavigationState(
            destinationName: destinationName,
          ),
        ),
      );
    });

    test('defaults railVisible to true', () {
      const state = NavigationState(
        destinationName: destinationName,
      );

      expect(state.railVisible, isTrue);
    });

    group('copyWith', () {
      test('returns same values when no parameters are passed', () {
        const state = NavigationState(
          destinationName: destinationName,
          railVisible: false,
        );

        expect(
          state.copyWith(),
          equals(state),
        );
      });

      test('replaces destinationName when non-null value is passed', () {
        const state = NavigationState(
          destinationName: destinationName,
        );

        expect(
          state.copyWith(destinationName: 'settings'),
          equals(
            const NavigationState(
              destinationName: 'settings',
            ),
          ),
        );
      });

      test('replaces railVisible when non-null value is passed', () {
        const state = NavigationState(
          destinationName: destinationName,
          railVisible: true,
        );

        expect(
          state.copyWith(railVisible: false),
          equals(
            const NavigationState(
              destinationName: destinationName,
              railVisible: false,
            ),
          ),
        );
      });
    });

    group('equality and hashCode', () {
      test('two objects with same values have equal hashCode', () {
        const stateA = NavigationState(
          destinationName: destinationName,
          railVisible: false,
        );
        const stateB = NavigationState(
          destinationName: destinationName,
          railVisible: false,
        );

        expect(stateA, equals(stateB));
        expect(stateA.hashCode, equals(stateB.hashCode));
      });

      test('two objects with different destinationName are not equal', () {
        const stateA = NavigationState(
          destinationName: 'home',
        );
        const stateB = NavigationState(
          destinationName: 'settings',
        );

        expect(stateA, isNot(equals(stateB)));
        expect(stateA.hashCode, isNot(equals(stateB.hashCode)));
      });

      test('two objects with different railVisible are not equal', () {
        const stateA = NavigationState(
          destinationName: destinationName,
          railVisible: true,
        );
        const stateB = NavigationState(
          destinationName: destinationName,
          railVisible: false,
        );

        expect(stateA, isNot(equals(stateB)));
        expect(stateA.hashCode, isNot(equals(stateB.hashCode)));
      });

      test('is not equal to an object of a different type', () {
        const state = NavigationState(
          destinationName: destinationName,
        );

        expect(
          // ignore: unrelated_type_equality_checks
          state == Object(),
          isFalse,
        );
      });
    });
  });
}
