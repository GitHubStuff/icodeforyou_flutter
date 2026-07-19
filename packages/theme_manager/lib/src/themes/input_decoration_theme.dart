// packages/theme_manager/lib/src/themes/input_decoration_theme.dart
import 'package:flutter/material.dart';

/// Builds the outlined input decoration for every text field.
///
/// Each border state takes its colour from the matching parameter, all of
/// which default to the [scheme] so omitting them keeps every state on-palette:
/// [outlineColor] -> enabled, [primaryColor] -> focused, [errorColor] ->
/// unfocused error, [focusedErrorColor] -> focused error. Pass any of them to
/// go off-palette. Widths follow Material's focus emphasis — 1px at rest, 2px
/// when focused.
InputDecorationTheme inputDecorationTheme(
  ColorScheme scheme, {
  Color? outlineColor,
  Color? primaryColor,
  Color? errorColor,
  Color? focusedErrorColor,
}) {
  OutlineInputBorder side(Color color, double width) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: width),
  );
  return InputDecorationTheme(
    border: const OutlineInputBorder(),
    enabledBorder: side(outlineColor ?? scheme.outline, 1),
    focusedBorder: side(primaryColor ?? scheme.primary, 2),
    errorBorder: side(errorColor ?? scheme.error, 1),
    focusedErrorBorder: side(focusedErrorColor ?? scheme.error, 2),
  );
}
