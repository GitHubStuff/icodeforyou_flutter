// programs/widgetbook/lib/usecases/theme_manager/in_memory_theme_persistence.dart

import 'package:flutter/material.dart' show ThemeMode;
import 'package:theme_manager/theme_manager.dart' show ThemePersistenceAbstract;

/// The mode reported by [InMemoryThemePersistence.load] before any
/// [InMemoryThemePersistence.save], per the contract's requirement that
/// implementations return a sensible default rather than `null`.
const ThemeMode _kDefaultThemeMode = ThemeMode.system;

/// A [ThemePersistenceAbstract] holding its value in memory only.
///
/// Backs the `MaterialThemeCubit` instances constructed inside Widgetbook
/// use-cases, where persistence is unwanted: every restart of the workbench
/// starts from a clean slate, so tap experiments never leak between
/// sessions. Both members complete synchronously, exercising the
/// `FutureOr` half of the contract that disk-backed implementations do not.
final class InMemoryThemePersistence implements ThemePersistenceAbstract {
  /// Creates an [InMemoryThemePersistence] holding no saved value.
  InMemoryThemePersistence();

  /// The last mode passed to [save], or [_kDefaultThemeMode] when none has
  /// been.
  ThemeMode _mode = _kDefaultThemeMode;

  /// Returns the last saved [ThemeMode], or [_kDefaultThemeMode] when
  /// nothing has been saved since construction.
  @override
  ThemeMode load() => _mode;

  /// Holds [mode] so a subsequent [load] returns it.
  @override
  void save(ThemeMode mode) => _mode = mode;
}
