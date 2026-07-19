// theme_manager/lib/src/widgets/preference/material_preference.usecase.dart
// ignore_for_file: public_member_api_docs

import 'dart:async' show FutureOr;

import 'package:flutter/material.dart';
import 'package:theme_manager/theme_manager.dart'
    show
        MaterialPreference,
        MaterialTheme,
        MaterialThemeCubit,
        ThemePersistenceAbstract;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

const _kTitle = 'Theme';
const _kSystemLabel = 'System';
const _kDarkLabel = 'Dark';
const _kLightLabel = 'Light';

final _kIconNames = <IconData, String>{
  Icons.brightness_auto: 'brightness_auto',
  Icons.settings_brightness: 'settings_brightness',
  Icons.dark_mode: 'dark_mode',
  Icons.nights_stay: 'nights_stay',
  Icons.bedtime: 'bedtime',
  Icons.light_mode: 'light_mode',
  Icons.wb_sunny: 'wb_sunny',
};

const _kSystemIcons = <IconData>[
  Icons.brightness_auto,
  Icons.settings_brightness,
];
const _kDarkIcons = <IconData>[
  Icons.dark_mode,
  Icons.nights_stay,
  Icons.bedtime,
];
const _kLightIcons = <IconData>[
  Icons.light_mode,
  Icons.wb_sunny,
];

String _iconLabel(IconData icon) => _kIconNames[icon] ?? 'icon';

/// Knob-driven showcase of the package's public theme picker.
///
/// All copy and iconography are controllable from the Widgetbook panel so
/// the widget's full customization surface can be exercised in isolation.
@widgetbook.UseCase(name: 'Default', type: MaterialPreference)
Widget buildMaterialPreferenceUseCase(BuildContext context) {
  return _MaterialPreferenceDemo(
    title: context.knobs.string(
      label: 'Title',
      initialValue: _kTitle,
    ),
    systemLabel: context.knobs.string(
      label: 'System label',
      initialValue: _kSystemLabel,
    ),
    darkLabel: context.knobs.string(
      label: 'Dark label',
      initialValue: _kDarkLabel,
    ),
    lightLabel: context.knobs.string(
      label: 'Light label',
      initialValue: _kLightLabel,
    ),
    systemIcon: context.knobs.object.dropdown<IconData>(
      label: 'System icon',
      options: _kSystemIcons,
      initialOption: Icons.brightness_auto,
      labelBuilder: _iconLabel,
    ),
    darkIcon: context.knobs.object.dropdown<IconData>(
      label: 'Dark icon',
      options: _kDarkIcons,
      initialOption: Icons.dark_mode,
      labelBuilder: _iconLabel,
    ),
    lightIcon: context.knobs.object.dropdown<IconData>(
      label: 'Light icon',
      options: _kLightIcons,
      initialOption: Icons.light_mode,
      labelBuilder: _iconLabel,
    ),
  );
}

/// Fully localized showcase demonstrating branding/localization overrides.
@widgetbook.UseCase(name: 'Localized (Spanish)', type: MaterialPreference)
Widget buildMaterialPreferenceLocalizedUseCase(BuildContext context) {
  return const _MaterialPreferenceDemo(
    title: 'Apariencia',
    systemLabel: 'Sistema',
    darkLabel: 'Oscuro',
    lightLabel: 'Claro',
    systemIcon: Icons.settings_brightness,
    darkIcon: Icons.nights_stay,
    lightIcon: Icons.wb_sunny,
  );
}

/// Owns a [MaterialThemeCubit] for the lifetime of the use case.
///
/// The cubit is created once and closed on dispose; knob changes only
/// rebuild the presentation, so the selected mode survives edits.
class _MaterialPreferenceDemo extends StatefulWidget {
  const _MaterialPreferenceDemo({
    required this.title,
    required this.systemLabel,
    required this.darkLabel,
    required this.lightLabel,
    required this.systemIcon,
    required this.darkIcon,
    required this.lightIcon,
  });

  final String title;
  final String systemLabel;
  final String darkLabel;
  final String lightLabel;
  final IconData systemIcon;
  final IconData darkIcon;
  final IconData lightIcon;

  @override
  State<_MaterialPreferenceDemo> createState() =>
      _MaterialPreferenceDemoState();
}

class _MaterialPreferenceDemoState extends State<_MaterialPreferenceDemo> {
  late final MaterialThemeCubit _cubit = MaterialThemeCubit(
    theme: MaterialTheme(),
    themeModeStorage: _InMemoryThemePersistence(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Card(
          margin: const EdgeInsets.all(16),
          child: MaterialPreference(
            cubit: _cubit,
            title: widget.title,
            systemIcon: widget.systemIcon,
            darkIcon: widget.darkIcon,
            lightIcon: widget.lightIcon,
            systemLabel: widget.systemLabel,
            darkLabel: widget.darkLabel,
            lightLabel: widget.lightLabel,
          ),
        ),
      ),
    );
  }
}

/// In-memory [ThemePersistenceAbstract] so the use case has no dependency
/// on shared preferences or platform channels.
class _InMemoryThemePersistence implements ThemePersistenceAbstract {
  ThemeMode _mode = ThemeMode.dark;

  @override
  FutureOr<ThemeMode> load() => _mode;

  @override
  FutureOr<void> save(ThemeMode mode) => _mode = mode;
}
