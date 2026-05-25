// theme_manager/test/src/cubit/material_theme_cubit_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:theme_manager/src/cubit/material_theme.dart';
import 'package:theme_manager/src/cubit/material_theme_cubit.dart';
import 'package:theme_manager/src/cubit/material_theme_state.dart';
import 'package:theme_manager/src/theme_mode/theme_persistence_abstract.dart';

class _MockThemePersistence extends Mock implements ThemePersistenceAbstract {}

void main() {
  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
  });

  late _MockThemePersistence persistence;
  late MaterialTheme initialTheme;

  setUp(() {
    persistence = _MockThemePersistence();
    when(() => persistence.save(any())).thenAnswer((_) async {});
    initialTheme = MaterialTheme(mode: ThemeMode.light);
  });

  MaterialThemeCubit buildCubit() => MaterialThemeCubit(
        theme: initialTheme,
        themeModeStorage: persistence,
      );

  group('MaterialThemeCubit', () {
    test('initial state is the provided theme', () {
      final cubit = buildCubit();

      expect(cubit.state, same(initialTheme));
      expect(cubit.state.mode, ThemeMode.light);
    });

    blocTest<MaterialThemeCubit, MaterialThemeState>(
      'toDark emits a state with ThemeMode.dark and persists it',
      build: buildCubit,
      act: (cubit) => cubit.toDark(),
      verify: (cubit) {
        expect(cubit.state.mode, ThemeMode.dark);
        verify(() => persistence.save(ThemeMode.dark)).called(1);
      },
    );

    blocTest<MaterialThemeCubit, MaterialThemeState>(
      'toLight is a no-op when already in light mode',
      build: buildCubit,
      act: (cubit) => cubit.toLight(),
      expect: () => <MaterialThemeState>[],
      verify: (_) {
        verifyNever(() => persistence.save(any()));
      },
    );

    blocTest<MaterialThemeCubit, MaterialThemeState>(
      'toSystem emits a state with ThemeMode.system and persists it',
      build: buildCubit,
      act: (cubit) => cubit.toSystem(),
      verify: (cubit) {
        expect(cubit.state.mode, ThemeMode.system);
        verify(() => persistence.save(ThemeMode.system)).called(1);
      },
    );

    blocTest<MaterialThemeCubit, MaterialThemeState>(
      'sequential mode changes emit each new mode and persist each',
      build: buildCubit,
      act: (cubit) {
        cubit.toDark();
        cubit.toSystem();
        cubit.toLight();
      },
      verify: (cubit) {
        expect(cubit.state.mode, ThemeMode.light);
        verify(() => persistence.save(ThemeMode.dark)).called(1);
        verify(() => persistence.save(ThemeMode.system)).called(1);
        verify(() => persistence.save(ThemeMode.light)).called(1);
      },
    );
  });
}
