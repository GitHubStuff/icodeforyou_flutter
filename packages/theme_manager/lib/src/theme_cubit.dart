// lib/src/theme_cubit.dart

import 'package:flutter/material.dart';
import 'package:theme_manager/src/theme_cubit_base.dart';
import 'package:theme_manager/src/theme_persistence.dart';

class ThemeCubit extends ThemeCubitBase {
  ThemeCubit._(super.initialState, this._persistence);

  final ThemePersistence _persistence;

  static Future<ThemeCubit> create() async {
    final persistence = await ThemePersistence.create();
    return ThemeCubit._(persistence.load(), persistence);
  }

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
