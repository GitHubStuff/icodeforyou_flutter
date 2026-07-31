import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_framework/theme_framework.dart' show ThemeCubit;

import 'theme_mode_card.dart'; // point this at wherever your card lives

class ThemeSettingScreen extends StatelessWidget {
  const ThemeSettingScreen({this.actions, required this.themeMode});

  /// The global demo controls to show on this screen's app bar.
  final List<Widget>? actions;

  /// The current theme intent, owned above this screen and passed down.
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: colorScheme.tertiaryContainer,
        foregroundColor: colorScheme.onTertiaryContainer,
        actions: actions,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ThemeModeCard(
          value: themeMode,
          onChanged: (mode) => context.read<ThemeCubit>().setThemeMode(mode),
        ),
      ),
    );
  }
}
