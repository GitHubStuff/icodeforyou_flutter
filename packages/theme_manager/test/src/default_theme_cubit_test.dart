// theme_manager/test/src/default_theme_cubit_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_manager/src/default_theme_cubit.dart';
import 'package:theme_manager/src/theme_persistence.dart';

void main() {
  final darkTheme = ThemeData(brightness: Brightness.dark);
  final lightTheme = ThemeData(brightness: Brightness.light);

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('DefaultThemeCubit', () {
    group('factory DefaultThemeCubit()', () {
      test('throws UnsupportedError when invoked directly', () {
        expect(
          DefaultThemeCubit.new,
          throwsA(
            isA<UnsupportedError>().having(
              (e) => e.message,
              'message',
              contains('Use DefaultThemeCubit.create() instead.'),
            ),
          ),
        );
      });
    });

    group('create()', () {
      test('returns a DefaultThemeCubit instance', () async {
        final cubit = await DefaultThemeCubit.create(
          darkTheme: darkTheme,
          lightTheme: lightTheme,
        );
        addTearDown(cubit.close);

        expect(cubit, isA<DefaultThemeCubit>());
      });

      test(
        'seeds state with persisted mode when it differs from the '
        'provisional initial state',
        () async {
          SharedPreferences.setMockInitialValues(<String, Object>{
            'flutter.theme_mode-317293440000': ThemeMode.light.name,
          });

          final cubit = await DefaultThemeCubit.create(
            darkTheme: darkTheme,
            lightTheme: lightTheme,
          );
          addTearDown(cubit.close);

          expect(cubit.state, ThemeMode.light);
        },
      );

      test(
        'does not emit when persisted mode equals the provisional initial '
        'state (ThemeMode.dark)',
        () async {
          SharedPreferences.setMockInitialValues(<String, Object>{
            'flutter.theme_mode-317293440000': ThemeMode.dark.name,
          });

          final cubit = await DefaultThemeCubit.create(
            darkTheme: darkTheme,
            lightTheme: lightTheme,
          );
          addTearDown(cubit.close);

          expect(cubit.state, ThemeMode.dark);
        },
      );

      test(
        'defaults state to ThemeMode.dark when nothing is persisted',
        () async {
          final cubit = await DefaultThemeCubit.create(
            darkTheme: darkTheme,
            lightTheme: lightTheme,
          );
          addTearDown(cubit.close);

          expect(cubit.state, ThemeMode.dark);
        },
      );
    });

    group('theme getters', () {
      late DefaultThemeCubit cubit;

      setUp(() async {
        cubit = await DefaultThemeCubit.create(
          darkTheme: darkTheme,
          lightTheme: lightTheme,
        );
      });

      tearDown(() async {
        await cubit.close();
      });

      test('dark returns the injected dark ThemeData', () {
        expect(cubit.dark, same(darkTheme));
      });

      test('light returns the injected light ThemeData', () {
        expect(cubit.light, same(lightTheme));
      });
    });

    group('mode transitions', () {
      late DefaultThemeCubit lightSeededCubit;
      late DefaultThemeCubit darkSeededCubit;

      setUp(() async {
        // Cubit seeded from an empty store (initial state: ThemeMode.dark).
        darkSeededCubit = await DefaultThemeCubit.create(
          darkTheme: darkTheme,
          lightTheme: lightTheme,
        );

        // Cubit seeded with a persisted light mode so toDark produces an emit.
        SharedPreferences.setMockInitialValues(<String, Object>{
          'flutter.theme_mode-317293440000': ThemeMode.light.name,
        });
        lightSeededCubit = await DefaultThemeCubit.create(
          darkTheme: darkTheme,
          lightTheme: lightTheme,
        );
      });

      tearDown(() async {
        await darkSeededCubit.close();
        await lightSeededCubit.close();
      });

      blocTest<DefaultThemeCubit, ThemeMode>(
        'toLight emits ThemeMode.light',
        build: () => darkSeededCubit,
        act: (cubit) => cubit.toLight(),
        expect: () => const <ThemeMode>[ThemeMode.light],
      );

      blocTest<DefaultThemeCubit, ThemeMode>(
        'toSystem emits ThemeMode.system',
        build: () => darkSeededCubit,
        act: (cubit) => cubit.toSystem(),
        expect: () => const <ThemeMode>[ThemeMode.system],
      );

      blocTest<DefaultThemeCubit, ThemeMode>(
        'toDark emits ThemeMode.dark when current state is not dark',
        build: () => lightSeededCubit,
        act: (cubit) => cubit.toDark(),
        expect: () => const <ThemeMode>[ThemeMode.dark],
      );
    });

    group('persistence side effects', () {
      test('toLight persists ThemeMode.light', () async {
        final cubit = await DefaultThemeCubit.create(
          darkTheme: darkTheme,
          lightTheme: lightTheme,
        );
        addTearDown(cubit.close);

        cubit.toLight();
        await _waitForMicrotasks();

        final persistence = await ThemePersistence.create();
        expect(persistence.load(), ThemeMode.light);
      });

      test('toDark persists ThemeMode.dark', () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'flutter.theme_mode-317293440000': ThemeMode.light.name,
        });

        final cubit = await DefaultThemeCubit.create(
          darkTheme: darkTheme,
          lightTheme: lightTheme,
        );
        addTearDown(cubit.close);

        cubit.toDark();
        await _waitForMicrotasks();

        final persistence = await ThemePersistence.create();
        expect(persistence.load(), ThemeMode.dark);
      });

      test('toSystem persists ThemeMode.system', () async {
        final cubit = await DefaultThemeCubit.create(
          darkTheme: darkTheme,
          lightTheme: lightTheme,
        );
        addTearDown(cubit.close);

        cubit.toSystem();
        await _waitForMicrotasks();

        final persistence = await ThemePersistence.create();
        expect(persistence.load(), ThemeMode.system);
      });
    });
  });
}

/// Yields the event loop so pending microtasks (including the fire-and-forget
/// persistence write inside `_emit`) complete before assertions run.
Future<void> _waitForMicrotasks() => Future<void>.delayed(Duration.zero);
