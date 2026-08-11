// programs/widgetbook/lib/usecases/theme_framework/in_memory_theme_storage.dart

import 'package:flutter/material.dart' show ThemeMode;
import 'package:theme_framework/theme_framework.dart' show ThemeStorageAbstract;

/// A [ThemeStorageAbstract] holding its value in memory only.
///
/// Backs the `ThemeCubit` instances constructed inside Widgetbook use-cases,
/// where persistence is unwanted: every restart of the workbench starts from
/// a clean slate, so knob and tap experiments never leak between sessions.
final class InMemoryThemeStorage implements ThemeStorageAbstract {
  /// Creates an [InMemoryThemeStorage] holding no value.
  InMemoryThemeStorage();

  /// The last mode passed to [write], or `null` when none has been.
  ThemeMode? _mode;

  /// Returns the last written [ThemeMode], or `null` when nothing has been
  /// written since construction.
  @override
  Future<ThemeMode?> read() async => _mode;

  /// Holds [mode] so a subsequent [read] returns it.
  @override
  Future<void> write(ThemeMode mode) async => _mode = mode;
}
