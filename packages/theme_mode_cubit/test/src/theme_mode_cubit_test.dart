// packages/theme_mode_cubit/test/src/theme_mode_cubit_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:theme_mode_cubit/src/theme_mode_storage_abstract.dart'
    show ThemeModeStorageAbstract;
import 'package:theme_mode_cubit/theme_mode_cubit.dart' show ThemeModeCubit;

class MockThemeModeStorage extends Mock implements ThemeModeStorageAbstract {}

void main() {
  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
  });

  group('ThemeModeCubit', () {
    late MockThemeModeStorage mockStorage;

    setUp(() {
      mockStorage = MockThemeModeStorage();
    });

    test(
      'initializes with ThemeMode.dark and loads saved theme from storage',
      () async {
        when(() => mockStorage.read()).thenAnswer((_) async => ThemeMode.light);
        when(() => mockStorage.write(any())).thenAnswer((_) async {});

        final cubit = ThemeModeCubit(storage: mockStorage);

        // Verify immediate initial state before async read completes
        expect(cubit.state, equals(ThemeMode.dark));
        verify(() => mockStorage.read()).called(1);

        // Await pending async microtasks from storage.read().then(...)
        await pumpEventQueue();

        expect(cubit.state, equals(ThemeMode.light));
        verify(() => mockStorage.write(ThemeMode.light)).called(1);

        await cubit.close();
      },
    );

    test(
      'setTheme does nothing when new mode is identical to current state',
      () async {
        when(() => mockStorage.read()).thenAnswer((_) async => ThemeMode.dark);

        final cubit = ThemeModeCubit(storage: mockStorage);
        await pumpEventQueue();

        clearInteractions(mockStorage);

        // Attempting to set to current state (ThemeMode.dark)
        cubit.setTheme(ThemeMode.dark);

        expect(cubit.state, equals(ThemeMode.dark));
        verifyNever(() => mockStorage.write(any()));

        await cubit.close();
      },
    );

    test(
      'setTheme updates state and writes to storage when mode changes',
      () async {
        when(() => mockStorage.read()).thenAnswer((_) async => ThemeMode.dark);
        when(() => mockStorage.write(any())).thenAnswer((_) async {});

        final cubit = ThemeModeCubit(storage: mockStorage);
        await pumpEventQueue();

        clearInteractions(mockStorage);

        cubit.setTheme(ThemeMode.system);

        expect(cubit.state, equals(ThemeMode.system));
        verify(() => mockStorage.write(ThemeMode.system)).called(1);

        await cubit.close();
      },
    );
  });
}
