// theme_widget/lib/src/theme_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder;
import 'package:theme_manager/theme_manager.dart' show ThemeCubitBase;
import 'package:theme_widget/src/theme_option.dart' show ThemeOption;
import 'package:theme_widget/src/theme_selection_body.dart'
    show ThemeSelectionBody;

/// A drop-in theme picker widget that binds a [ThemeCubitBase] to a
/// titled, bordered panel of selectable [ThemeMode] options.
///
/// Serves as the public entry point of the `theme_widget` package,
/// wiring a [ThemeCubitBase] from the `theme_manager` package to a
/// [ThemeSelectionBody] via [BlocBuilder]. Rebuilds automatically when
/// the cubit emits a new [ThemeMode], and delegates user selections back
/// to the cubit through its [ThemeCubitBase.toLight], [ThemeCubitBase.toDark],
/// and [ThemeCubitBase.toSystem] methods.
///
/// Presents three fixed options in order — system, dark, light — with
/// customizable icons and labels for each. All presentation parameters
/// default to sensible Material values, allowing the widget to be used
/// with a single required [cubit] argument while still permitting full
/// customization of copy and iconography for localization or branding.
///
/// Because this widget owns neither the selected mode nor the
/// persistence layer, it can be placed anywhere in the widget tree — a
/// settings screen, a dialog, a drawer — without additional state
/// management boilerplate. The supplied [cubit] is the single source of
/// truth for the current theme and is responsible for any persistence.
///
/// Example:
/// ```dart
/// ThemeWidget(
///   cubit: context.read<ThemeCubit>(),
///   title: 'Appearance',
/// );
/// ```
///
/// Example with full customization:
/// ```dart
/// ThemeWidget(
///   cubit: themeCubit,
///   title: 'Apariencia',
///   systemLabel: 'Sistema',
///   darkLabel: 'Oscuro',
///   lightLabel: 'Claro',
///   systemIcon: Icons.settings_brightness,
///   darkIcon: Icons.nights_stay,
///   lightIcon: Icons.wb_sunny,
/// );
/// ```
class ThemeWidget extends StatelessWidget {
  /// Creates a [ThemeWidget] bound to the provided [cubit].
  ///
  /// Only [cubit] is required; all other parameters customize the
  /// panel's presentation and default to standard Material icons and
  /// English labels.
  ///
  /// * [cubit] — the [ThemeCubitBase] that holds the current [ThemeMode]
  ///   and receives selection changes.
  /// * [title] — the heading rendered above the option list. Defaults to
  ///   `'Theme'`.
  /// * [systemIcon] — icon for the system option. Defaults to
  ///   [Icons.brightness_auto].
  /// * [darkIcon] — icon for the dark option. Defaults to
  ///   [Icons.dark_mode].
  /// * [lightIcon] — icon for the light option. Defaults to
  ///   [Icons.light_mode].
  /// * [systemLabel] — label for the system option. Defaults to
  ///   `'System'`.
  /// * [darkLabel] — label for the dark option. Defaults to `'Dark'`.
  /// * [lightLabel] — label for the light option. Defaults to `'Light'`.
  const ThemeWidget({
    required this.cubit,
    this.title = 'Theme',
    this.systemIcon = Icons.brightness_auto,
    this.darkIcon = Icons.dark_mode,
    this.lightIcon = Icons.light_mode,
    this.systemLabel = 'System',
    this.darkLabel = 'Dark',
    this.lightLabel = 'Light',
    super.key,
  });

  /// The cubit that holds the current [ThemeMode] and applies changes.
  ///
  /// [BlocBuilder] subscribes to this cubit to drive rebuilds, and user
  /// selections are dispatched to its [ThemeCubitBase.toLight],
  /// [ThemeCubitBase.toDark], and [ThemeCubitBase.toSystem] methods.
  final ThemeCubitBase cubit;

  /// The heading text rendered above the option list.
  final String title;

  /// The icon displayed for the system theme option.
  final IconData systemIcon;

  /// The icon displayed for the dark theme option.
  final IconData darkIcon;

  /// The icon displayed for the light theme option.
  final IconData lightIcon;

  /// The label displayed for the system theme option.
  final String systemLabel;

  /// The label displayed for the dark theme option.
  final String darkLabel;

  /// The label displayed for the light theme option.
  final String lightLabel;

  /// The ordered list of [ThemeOption]s rendered by this widget.
  ///
  /// Always yields three entries in a fixed order — system, dark, light —
  /// each constructed from the corresponding icon and label fields.
  List<ThemeOption> get _options => [
    ThemeOption(mode: ThemeMode.system, icon: systemIcon, label: systemLabel),
    ThemeOption(mode: ThemeMode.dark, icon: darkIcon, label: darkLabel),
    ThemeOption(mode: ThemeMode.light, icon: lightIcon, label: lightLabel),
  ];

  /// Dispatches the selected [mode] to the appropriate [cubit] method.
  ///
  /// Routes [ThemeMode.light] to [ThemeCubitBase.toLight],
  /// [ThemeMode.dark] to [ThemeCubitBase.toDark], and [ThemeMode.system]
  /// to [ThemeCubitBase.toSystem].
  void _onChanged(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        cubit.toLight();
      case ThemeMode.dark:
        cubit.toDark();
      case ThemeMode.system:
        cubit.toSystem();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubitBase, ThemeMode>(
      bloc: cubit,
      builder: (context, current) => ThemeSelectionBody(
        title: title,
        options: _options,
        current: current,
        onChanged: _onChanged,
      ),
    );
  }
}
