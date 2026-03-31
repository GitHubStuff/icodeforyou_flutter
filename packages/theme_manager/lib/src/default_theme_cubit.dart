// lib/src/theme_cubit.dart

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:theme_manager/src/theme_cubit_base.dart';
import 'package:theme_manager/src/theme_persistence.dart';

class DefaultThemeCubit extends ThemeCubitBase {
  factory DefaultThemeCubit() => throw UnsupportedError(
    'Cannot invoke ThemeCubit() directly.\n'
    'Use DefaultThemeCubit.create() instead.\n'
    ' note: "create()" is async and returns'
    '  Future<ThemeCubit> create()',
  );

  DefaultThemeCubit._(this._persistence, this._darkTheme, this._lightTheme)
    : super(ThemeMode.dark);

  final ThemePersistenceAbstract _persistence;
  final ThemeData _darkTheme;
  final ThemeData _lightTheme;

  static Future<DefaultThemeCubit> create({
    required ThemeData darkTheme,
    required ThemeData lightTheme,
  }) async {
    final persistence = await ThemePersistence.create();
    final restoredMode = persistence.load();
    final cubit = DefaultThemeCubit._(
      persistence,
      darkTheme,
      lightTheme,
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
