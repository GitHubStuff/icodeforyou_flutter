// lib/src/state.dart
part of '../theme_package.dart';

final class _ThemeState {
  const _ThemeState({
    required this.themeMode,
  });

  final ThemeMode themeMode;

  _ThemeState copyWith({
    ThemeMode? themeMode,
  }) {
    return _ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ThemeState && other.themeMode == themeMode;
  }

  @override
  int get hashCode => themeMode.hashCode;
}
