// packages/theme_framework/lib/src/widgets/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:theme_framework/theme_framework.dart'
    show ThemeCubit, ThemeModeCard;

/// The default title shown in the screen's app bar.
const String _kTitle = 'Settings';

/// Inset around the screen's content.
const EdgeInsets _kPadding = EdgeInsets.all(16);

/// Vertical gap between adjacent preference entries.
const double _kGap = 16;

/// A settings screen that presents a caller-supplied list of preference
/// widgets as a scrollable column.
///
/// The screen owns no preference content of its own: [preferences] is
/// rendered top-to-bottom inside a [ListView], so callers decide what
/// appears and in what order. Each entry is typically a self-contained
/// card that reads and writes its own state.
///
/// For the common case of a theme selector as the first entry, use
/// [PreferencesScreen.withTheme].
class SettingsScreen extends StatelessWidget {
  /// Creates a [SettingsScreen] presenting [preferences] in order.
  const SettingsScreen({
    required this.preferences,
    super.key,
    this.actions,
    this.title = _kTitle,
  });

  /// Creates a [SettingsScreen] whose first entry is a theme-mode
  /// selector, followed by [preferences] in order.
  ///
  /// The theme entry reads the active [ThemeMode] from the ambient
  /// [ThemeCubit] through a [BlocBuilder] and writes selections back
  /// through [ThemeCubit.setThemeMode], which emits and persists.
  ///
  /// The subscription is deliberately internal rather than a constructor
  /// parameter. This screen is built once — in `main`, captured by a
  /// `GoRoute.builder` and held alive as a member of the rail's screen
  /// stack — so a [ThemeMode] passed in at construction is pinned to its
  /// launch value for the life of the process: tapping a row would retint
  /// the app while the checkmark stayed put. Subscribing inside the entry
  /// puts the read below the point of construction, where rebuilds
  /// actually happen.
  ///
  /// A [ThemeCubit] must therefore be available above the enclosing
  /// [Navigator]; the usual placement — a [BlocProvider] wrapping the
  /// [MaterialApp] — satisfies this.
  factory SettingsScreen.withTheme({
    Key? key,
    List<Widget>? actions,
    String title = _kTitle,
    List<Widget> preferences = const <Widget>[],
  }) {
    return SettingsScreen(
      key: key,
      actions: actions,
      title: title,
      preferences: <Widget>[
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) => ThemeModeCard(
            value: mode,
            onChanged: context.read<ThemeCubit>().setThemeMode,
          ),
        ),
        ...preferences,
      ],
    );
  }

  /// The preference widgets presented, in order, as a scrollable list.
  final List<Widget> preferences;

  /// Widgets placed in the app bar's action slot.
  ///
  /// Optional; `null` leaves the slot empty.
  final List<Widget>? actions;

  /// The title shown in the screen's app bar.
  ///
  /// Defaults to `'Preferences'`.
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: colorScheme.tertiaryContainer,
        foregroundColor: colorScheme.onTertiaryContainer,
        actions: actions,
      ),
      body: ListView.separated(
        padding: _kPadding,
        itemCount: preferences.length,
        separatorBuilder: (context, index) => const Gap(_kGap),
        itemBuilder: (context, index) => preferences[index],
      ),
    );
  }
}
