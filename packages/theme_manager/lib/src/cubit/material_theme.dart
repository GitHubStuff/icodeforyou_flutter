// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:theme_manager/src/cubit/material_theme_state.dart'
    show MaterialThemeState;

final class MaterialTheme implements MaterialThemeState {
  MaterialTheme({ThemeMode? mode, ThemeData? dark, ThemeData? light})
    : mode = mode ?? .dark,
      dark = dark ?? ThemeData.dark(useMaterial3: true),
      light = light ?? ThemeData.light(useMaterial3: true);
  @override
  final ThemeMode mode;

  @override
  final ThemeData dark;

  @override
  final ThemeData light;

  @override
  MaterialTheme copyWith({
    ThemeMode? mode,
    ThemeData? dark,
    ThemeData? light,
  }) {
    return MaterialTheme(
      mode: mode ?? this.mode,
      dark: dark ?? this.dark,
      light: light ?? this.light,
    );
  }
}
