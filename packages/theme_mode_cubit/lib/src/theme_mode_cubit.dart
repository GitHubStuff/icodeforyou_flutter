// packages/theme_mode_cubit/lib/src/theme_mode_cubit.dart

import 'dart:async' show unawaited;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:theme_mode_cubit/src/theme_mode_storage_abstract.dart'
    show ThemeModeStorageAbstract;

/// Manages the application's [ThemeMode] state and persists changes to storage.
///
/// Defaults to [ThemeMode.dark] on initialization until the stored theme mode
/// is asynchronously loaded from [storage].
class ThemeModeCubit extends Cubit<ThemeMode> {
  /// Creates a [ThemeModeCubit] with the given [storage] backend.
  ///
  /// Immediately initiates an asynchronous read from [storage] to restore
  /// the persisted [ThemeMode].
  ThemeModeCubit({required this.storage}) : super(ThemeMode.dark) {
    unawaited(storage.read().then(setTheme));
  }

  /// The persistence layer used to read and write the active [ThemeMode].
  final ThemeModeStorageAbstract storage;

  /// Updates the current [ThemeMode] to [mode] and persists it via [storage].
  ///
  /// Does nothing if [mode] is identical to the current [state].
  void setTheme(ThemeMode mode) {
    if (mode == state) return;
    unawaited(storage.write(mode));
    emit(mode);
  }
}
