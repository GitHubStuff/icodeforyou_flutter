// lib/src/constants.dart
part of '../theme_package.dart';

abstract final class _ThemeConstants {
  /// Hive box key for storing the theme mode value.
  static const String themeKey = 'theme_mode';

  /// Converts [ThemeMode] to a persistable string value.
  static String themeModeToString(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
    };
  }

  /// Converts a persisted string value to [ThemeMode].
  /// Defaults to [ThemeMode.system] if value is invalid or null.
  static ThemeMode stringToThemeMode(String? value) {
    return switch (value) {
      'system' => ThemeMode.system,
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
