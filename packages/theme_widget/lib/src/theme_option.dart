// theme_widget/lib/src/_theme_option.dart
import 'package:flutter/material.dart';

/// A configuration object that pairs a [ThemeMode] with its visual
/// representation for use in theme selection UI controls within the
/// `theme_widget` package.
///
/// Used to define the available theme choices (typically system, light, and
/// dark) that a user can select from. Each option bundles the underlying
/// [ThemeMode] value with a display [icon] and human-readable [label],
/// allowing consuming widgets (such as segmented buttons, dropdowns, or
/// toggle groups) to render consistent theme pickers without duplicating
/// presentation logic at the call site.
///
/// This class is immutable and intended to be constructed as a `const`
/// instance, typically within a predefined list of options consumed by a
/// theme selector widget provided by the `theme_widget` package.
///
/// Example:
/// ```dart
/// const options = <ThemeOption>[
///   ThemeOption(
///     mode: ThemeMode.system,
///     icon: Icons.brightness_auto,
///     label: 'System',
///   ),
///   ThemeOption(
///     mode: ThemeMode.light,
///     icon: Icons.light_mode,
///     label: 'Light',
///   ),
///   ThemeOption(
///     mode: ThemeMode.dark,
///     icon: Icons.dark_mode,
///     label: 'Dark',
///   ),
/// ];
/// ```
class ThemeOption {
  /// Creates a [ThemeOption] that associates a [ThemeMode] with its
  /// presentation metadata.
  ///
  /// All parameters are required:
  /// * [mode] — the [ThemeMode] this option represents.
  /// * [icon] — the [IconData] displayed alongside or in place of the label.
  /// * [label] — the human-readable text identifying this option.
  const ThemeOption({
    required this.mode,
    required this.icon,
    required this.label,
  });

  /// The [ThemeMode] applied when this option is selected.
  final ThemeMode mode;

  /// The icon representing this theme option in the UI.
  final IconData icon;

  /// The human-readable label describing this theme option.
  final String label;
}
