// theme_manager/test/src/theme_cubit_base_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_manager/src/theme_cubit_base.dart';

void main() {
  group('ThemeCubitBase', () {
    test('constructor forwards initialState to Cubit', () {
      final cubit = _FakeThemeCubit(ThemeMode.system);
      addTearDown(cubit.close);
      expect(cubit.state, ThemeMode.system);
    });

    test('initialState can be any ThemeMode value', () {
      final lightCubit = _FakeThemeCubit(ThemeMode.light);
      final darkCubit = _FakeThemeCubit(ThemeMode.dark);
      addTearDown(lightCubit.close);
      addTearDown(darkCubit.close);

      expect(lightCubit.state, ThemeMode.light);
      expect(darkCubit.state, ThemeMode.dark);
    });
  });
}

/// Minimal concrete subclass used purely to instantiate [ThemeCubitBase]
/// and verify constructor behavior. Abstract members return sentinel
/// values and transition methods are no-ops — they are the subclass's
/// responsibility to test, not the base's.
class _FakeThemeCubit extends ThemeCubitBase {
  _FakeThemeCubit(super.initialState);

  @override
  ThemeData get dark => ThemeData.dark();

  @override
  ThemeData get light => ThemeData.light();

  @override
  void toLight() {}

  @override
  void toDark() {}

  @override
  void toSystem() {}
}
