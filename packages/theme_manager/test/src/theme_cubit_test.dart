// test/src/theme_cubit_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:theme_manager/src/theme_cubit.dart';
import 'package:theme_manager/src/theme_cubit_base.dart';

void main() {
  group('ThemeCubit', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    test('is a ThemeCubitBase', () async {
      final cubit = await ThemeCubit.create();
      expect(cubit, isA<ThemeCubitBase>());
      await cubit.close();
    });

    test('initial state is ThemeMode.dark when no persisted value', () async {
      final cubit = await ThemeCubit.create();
      expect(cubit.state, ThemeMode.dark);
      await cubit.close();
    });

    test('initial state reflects persisted ThemeMode.light', () async {
      final seed = await ThemeCubit.create();
      seed.toLight();
      await Future<void>.delayed(Duration.zero);
      await seed.close();

      final cubit = await ThemeCubit.create();
      expect(cubit.state, ThemeMode.light);
      await cubit.close();
    });

    test('initial state reflects persisted ThemeMode.system', () async {
      final seed = await ThemeCubit.create();
      seed.toSystem();
      await Future<void>.delayed(Duration.zero);
      await seed.close();

      final cubit = await ThemeCubit.create();
      expect(cubit.state, ThemeMode.system);
      await cubit.close();
    });

    test('toLight emits ThemeMode.light', () async {
      final cubit = await ThemeCubit.create();
      cubit.toLight();
      expect(cubit.state, ThemeMode.light);
      await cubit.close();
    });

    test('toDark emits ThemeMode.dark', () async {
      final cubit = await ThemeCubit.create();
      cubit.toLight();
      cubit.toDark();
      expect(cubit.state, ThemeMode.dark);
      await cubit.close();
    });

    test('toSystem emits ThemeMode.system', () async {
      final cubit = await ThemeCubit.create();
      cubit.toSystem();
      expect(cubit.state, ThemeMode.system);
      await cubit.close();
    });

    test('toLight does not re-emit when already light', () async {
      final cubit = await ThemeCubit.create();
      cubit.toLight();
      final emitted = <ThemeMode>[];
      final sub = cubit.stream.listen(emitted.add);
      cubit.toLight();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(emitted, isEmpty);
      await cubit.close();
    });

    test('persists ThemeMode.light after toLight', () async {
      final cubit = await ThemeCubit.create();
      cubit.toLight();
      await Future<void>.delayed(Duration.zero);
      await cubit.close();

      final cubit2 = await ThemeCubit.create();
      expect(cubit2.state, ThemeMode.light);
      await cubit2.close();
    });

    test('persists ThemeMode.system after toSystem', () async {
      final cubit = await ThemeCubit.create();
      cubit.toSystem();
      await Future<void>.delayed(Duration.zero);
      await cubit.close();

      final cubit2 = await ThemeCubit.create();
      expect(cubit2.state, ThemeMode.system);
      await cubit2.close();
    });
  });
}
