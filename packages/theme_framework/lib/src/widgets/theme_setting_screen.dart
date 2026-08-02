// packages/theme_framework/lib/src/widgets/theme_setting_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_framework/theme_framework.dart' show ThemeCubit;

import 'theme_mode_card.dart';

/// The title shown in the screen's app bar.
const String _kTitle = 'Settings';

/// Inset around the screen's content.
const EdgeInsets _kPadding = EdgeInsets.all(16);

/// A settings screen whose sole control is a [ThemeModeCard].
///
/// Reads the active [ThemeMode] from the ambient [ThemeCubit] through a
/// [BlocBuilder] and writes selections back through
/// [ThemeCubit.setThemeMode], which emits and persists.
///
/// The subscription is deliberately internal rather than a constructor
/// parameter. This screen is built once — in `main`, captured by a
/// `GoRoute.builder` and held alive as a member of the rail's screen stack —
/// so a `ThemeMode` passed in at construction is pinned to its launch value
/// for the life of the process: tapping a row would retint the app while the
/// checkmark stayed put. Subscribing here puts the read below the point of
/// construction, where rebuilds actually happen.
///
/// A [ThemeCubit] must therefore be available above the enclosing
/// [Navigator]; the usual placement — a [BlocProvider] wrapping the
/// [MaterialApp] — satisfies this.
class ThemeSettingScreen extends StatelessWidget {
  /// Creates a [ThemeSettingScreen].
  const ThemeSettingScreen({super.key, this.actions});

  /// Widgets placed in the app bar's action slot.
  ///
  /// Optional; `null` leaves the slot empty.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(_kTitle),
        centerTitle: true,
        backgroundColor: colorScheme.tertiaryContainer,
        foregroundColor: colorScheme.onTertiaryContainer,
        actions: actions,
      ),
      body: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) => SingleChildScrollView(
          padding: _kPadding,
          child: ThemeModeCard(
            value: mode,
            onChanged: context.read<ThemeCubit>().setThemeMode,
          ),
        ),
      ),
    );
  }
}
