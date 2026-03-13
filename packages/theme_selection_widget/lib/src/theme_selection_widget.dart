// lib/src/theme_selection_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder;
import 'package:theme_manager/theme_manager.dart' show ThemeCubitBase;
import 'package:theme_selection_widget/src/_theme_option.dart';
import 'package:theme_selection_widget/src/_theme_selection_body.dart';

class ThemeSelectionWidget extends StatelessWidget {
  const ThemeSelectionWidget({
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

  final ThemeCubitBase cubit;
  final String title;
  final IconData systemIcon;
  final IconData darkIcon;
  final IconData lightIcon;
  final String systemLabel;
  final String darkLabel;
  final String lightLabel;

  List<ThemeOption> get _options => [
    ThemeOption(mode: ThemeMode.system, icon: systemIcon, label: systemLabel),
    ThemeOption(mode: ThemeMode.dark, icon: darkIcon, label: darkLabel),
    ThemeOption(mode: ThemeMode.light, icon: lightIcon, label: lightLabel),
  ];

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
