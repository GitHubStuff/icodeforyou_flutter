// packages/theme_framework/test/src/cubit/theme_cubit_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_framework/src/cubit/theme_cubit.dart';
import 'package:theme_framework/src/preferences/theme_storage_abstract.dart';

/// A lightweight fake to simulate storage read/write operations.
class _FakeThemeStorage implements ThemeStorageAbstract {
  _FakeThemeStorage({this.storedMode});

  ThemeMode? storedMode;
  ThemeMode? writtenMode;

  @override
  Future<ThemeMode?> read() async => storedMode;

  @override
  Future<void> write(ThemeMode mode) async {
    writtenMode = mode;
  }
}

void main() {
  group('ThemeCubit', () {
    test('initial state seeds at ThemeMode.dark for splash screen', () async {
      final storage = _FakeThemeStorage();
      final cubit = ThemeCubit(storage);

      expect(cubit.state, ThemeMode.dark);

      await cubit.close();
    });

    blocTest<ThemeCubit, ThemeMode>(
      'restore() emits ThemeMode.system when storage returns null (first launch)',
      build: () => ThemeCubit(_FakeThemeStorage(storedMode: null)),
      act: (cubit) => cubit.restore(),
      expect: () => [
        ThemeMode.system,
      ],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'restore() emits the persisted ThemeMode when storage returns a value',
      build: () => ThemeCubit(_FakeThemeStorage(storedMode: ThemeMode.light)),
      act: (cubit) => cubit.restore(),
      expect: () => [
        ThemeMode.light,
      ],
    );

    test('setThemeMode() emits synchronously and writes to storage', () async {
      final storage = _FakeThemeStorage();
      final cubit = ThemeCubit(storage);

      // Act
      cubit.setThemeMode(ThemeMode.light);

      // Assert synchronous state change
      expect(cubit.state, ThemeMode.light);

      // Because ThemeCubit uses unawaited() for the write operation, we yield
      // back to the event loop for one microtask to let the fake storage complete.
      await Future<void>.delayed(Duration.zero);

      // Assert storage was updated
      expect(storage.writtenMode, ThemeMode.light);

      await cubit.close();
    });
  });
}
