// packages/app_navigation/test/src/cubit/navigation_cubit_test.dart

import 'dart:async';

import 'package:app_navigation/src/cubit/navigation_cubit.dart';
import 'package:app_navigation/src/cubit/navigation_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NavigationCubit', () {
    test('initial state uses empty string when no destination is given', () {
      final cubit = NavigationCubit();

      expect(
        cubit.state,
        equals(
          const NavigationState(
            destinationName: '',
          ),
        ),
      );

      unawaited(cubit.close());
    });

    test('initial state respects custom initialDestinationName', () {
      const destination = 'settings';
      final cubit = NavigationCubit(
        initialDestinationName: destination,
      );

      expect(
        cubit.state,
        equals(
          const NavigationState(
            destinationName: destination,
          ),
        ),
      );

      unawaited(cubit.close());
    });

    group('select', () {
      blocTest<NavigationCubit, NavigationState>(
        'emits updated destinationName when select is called',
        build: NavigationCubit.new,
        act: (cubit) => cubit.select('dashboard'),
        expect: () => const <NavigationState>[
          NavigationState(
            destinationName: 'dashboard',
          ),
        ],
      );

      blocTest<NavigationCubit, NavigationState>(
        'retains railVisible state when updating destinationName',
        build: () => NavigationCubit(
          initialDestinationName: 'home',
        ),
        seed: () => const NavigationState(
          destinationName: 'home',
          railVisible: false,
        ),
        act: (cubit) => cubit.select('profile'),
        expect: () => const <NavigationState>[
          NavigationState(
            destinationName: 'profile',
            railVisible: false,
          ),
        ],
      );
    });

    group('toggleRail', () {
      blocTest<NavigationCubit, NavigationState>(
        'toggles railVisible from true to false',
        build: () => NavigationCubit(
          initialDestinationName: 'home',
        ),
        seed: () => const NavigationState(
          destinationName: 'home',
          railVisible: true,
        ),
        act: (cubit) => cubit.toggleRail(),
        expect: () => const <NavigationState>[
          NavigationState(
            destinationName: 'home',
            railVisible: false,
          ),
        ],
      );

      blocTest<NavigationCubit, NavigationState>(
        'toggles railVisible from false to true',
        build: () => NavigationCubit(
          initialDestinationName: 'home',
        ),
        seed: () => const NavigationState(
          destinationName: 'home',
          railVisible: false,
        ),
        act: (cubit) => cubit.toggleRail(),
        expect: () => const <NavigationState>[
          NavigationState(
            destinationName: 'home',
            railVisible: true,
          ),
        ],
      );
    });
  });
}
