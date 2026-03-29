// lib/src/theme_cubit.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:theme_manager/src/theme_cubit_base.dart';
import 'package:theme_manager/src/theme_persistence.dart';

class ThemeCubit extends ThemeCubitBase {
  ThemeCubit._(this._persistence, this._darkTheme, this._lightTheme)
    : super(ThemeMode.dark);

  factory ThemeCubit() => throw UnsupportedError(
    'Cannot invoke ThemeCubit() directly.\n'
    'Use DefaultThemeCubit.create() instead.\n'
    ' note: "create()" is async and returns'
    '  Future<ThemeCubit> create()',
  );

  final ThemePersistenceAbstract _persistence;
  final ThemeData _darkTheme;
  final ThemeData _lightTheme;

  static Future<ThemeCubit> create({
    ThemeData? darkTheme,
    ThemeData? lightTheme,
  }) async {
    final persistence = await ThemePersistence.create();
    final restoredMode = persistence.load();
    final cubit = ThemeCubit._(
      persistence,
      darkTheme ?? ThemeData.dark(),
      lightTheme ?? ThemeData.light(),
    );
    if (restoredMode != cubit.state) {
      cubit.emit(restoredMode);
    }
    return cubit;
  }

  @override
  ThemeData get dark => _darkTheme;

  @override
  ThemeData get light => _lightTheme;

  @override
  void toLight() => _emit(ThemeMode.light);

  @override
  void toDark() => _emit(ThemeMode.dark);

  @override
  void toSystem() => _emit(ThemeMode.system);

  void _emit(ThemeMode mode) {
    emit(mode);
    _persistence.save(mode);
  }
}
