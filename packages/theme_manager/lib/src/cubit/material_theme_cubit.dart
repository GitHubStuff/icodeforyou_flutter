//
// ignore_for_file: always_use_package_imports, public_member_api_docs

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../persistence/theme_persistence_abstract.dart'
    show ThemePersistenceAbstract;
import '../themes/material_theme.dart' show MaterialTheme;
import 'material_theme_state.dart' show MaterialThemeState;

class MaterialThemeCubit extends Cubit<MaterialThemeState> {
  MaterialThemeCubit({
    required MaterialTheme theme,
    required ThemePersistenceAbstract themeModeStorage,
  }) : _themePersistence = themeModeStorage,
       super(theme);

  final ThemePersistenceAbstract _themePersistence;

  /// Emits [mode] to listeners and asynchronously persists it.
  ///
  /// The emit happens synchronously so UI updates are immediate; the
  /// persistence write is fire-and-forget and does not block state changes.
  Future<void> _emit({
    ThemeMode? mode,
    ThemeData? dark,
    ThemeData? light,
  }) async {
    final newState = state.copyWith(mode: mode, dark: dark, light: light);
    emit(newState);
    await _themePersistence.save(newState.mode);
  }

  void _newMode(ThemeMode mode) {
    if (mode != state.mode) unawaited(_emit(mode: mode));
  }

  void toDark() => _newMode(.dark);

  void toLight() => _newMode(.light);

  void toSystem() => _newMode(.system);
}
