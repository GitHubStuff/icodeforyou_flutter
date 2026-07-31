// packages/theme_framework/lib/src/theme_cubit.dart

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_framework/theme_framework.dart' show ThemeStore;


final class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._themeStore) : super(ThemeMode.dark);

  final ThemeStore _themeStore;

  void restore() => emit(_themeStore.read());

  Future<void> setThemeMode(ThemeMode mode) async {
    await _themeStore.write(mode);
    emit(mode);
  }

  Future<void> toLight() => setThemeMode(ThemeMode.light);

  Future<void> toDark() => setThemeMode(ThemeMode.dark);

  Future<void> toSystem() => setThemeMode(ThemeMode.system);
}