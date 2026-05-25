// theme_manager/test/src/theme_service/theme_service_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:service_locator/service_locator.dart' show ServiceClass;
import 'package:theme_manager/theme_manager.dart'
    show
        MaterialTheme,
        MaterialThemeCubit,
        ThemePersistenceAbstract,
        ThemeService;

class _InMemoryThemePersistence implements ThemePersistenceAbstract {
  ThemeMode _stored = ThemeMode.system;

  @override
  ThemeMode load() => _stored;

  @override
  void save(ThemeMode mode) {
    _stored = mode;
  }
}

void main() {
  group('ThemeService', () {
    late MaterialThemeCubit cubit;

    setUp(() {
      cubit = MaterialThemeCubit(
        theme: MaterialTheme(),
        themeModeStorage: _InMemoryThemePersistence(),
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('stores the cubit passed to the constructor', () {
      final service = ThemeService(cubit);
      expect(service.themeCubit, same(cubit));
    });

    test('implements ServiceClass', () {
      final service = ThemeService(cubit);
      expect(service, isA<ServiceClass>());
    });
  });
}
