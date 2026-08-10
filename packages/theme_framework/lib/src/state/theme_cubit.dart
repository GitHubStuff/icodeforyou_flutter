import 'dart:async';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_framework/src/preferences/theme_storage_abstract.dart';

/// The mode held until [ThemeCubit.restore] completes.
///
/// Matches the black splash surface, so the first frame never paints light.
const ThemeMode _kSplashThemeMode = ThemeMode.dark;

/// The mode used when the device holds no valid preference.
const ThemeMode _kFirstLaunchThemeMode = ThemeMode.system;

/// Owns the app's active [ThemeMode], hydrated from and persisted to a
/// [ThemeStorageAbstract].
///
/// Seeds at [_kSplashThemeMode] so the tree is dark while the splash is up,
/// then settles on the stored preference once [restore] completes.
final class ThemeCubit extends Cubit<ThemeMode> {
  /// Creates a [ThemeCubit] backed by [storage].
  ThemeCubit(this._storage) : super(_kSplashThemeMode);

  final ThemeStorageAbstract _storage;

  /// Emits the persisted [ThemeMode], or [_kFirstLaunchThemeMode] when the
  /// device holds none.
  ///
  /// Runs as the first startup task so the theme resolves behind the splash and
  /// the user never sees the repaint.
  Future<void> restore() async {
    emit(await _storage.read() ?? _kFirstLaunchThemeMode);
  }

  /// Selects [mode] as the active theme and persists the choice.
  ///
  /// Emits synchronously for instant UI, then writes to storage off-frame.
  void setThemeMode(ThemeMode mode) {
    emit(mode);
    unawaited(_storage.write(mode));
  }
}
