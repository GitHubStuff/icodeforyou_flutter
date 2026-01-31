// lib/src/constants.dart
part of '../theme_package.dart';

abstract final class _ThemeConstants {
  /// Hive box key for storing the theme mode value.
  static const String themeKey = 'theme_mode';

  /// Default dark theme using Material 3.
  static ThemeData get darkTheme => ThemeData.dark(useMaterial3: true);

  /// Default light theme using Material 3.
  static ThemeData get lightTheme => ThemeData.light(useMaterial3: true);

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
