// packages/theme_framework/lib/src/widgets/theme_mode_entry.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_widget/settings_widget.dart' show AppSettingsEntry;
import 'package:theme_framework/src/widgets/theme_mode_card.dart' show ThemeModeCard;
import 'package:theme_framework/theme_framework.dart' show ThemeCubit;


/// The appearance row of a settings surface: a [ThemeModeCard] bound to the
/// ambient [ThemeCubit].
///
/// [ThemeModeCard] is controlled — it takes a value and a callback and owns
/// nothing — which keeps it host-agnostic but means something must supply
/// the value and rebuild it. This entry is that something, and the
/// subscription has to live here rather than at the call site: a settings
/// surface is constructed once, whether captured by a `GoRoute.builder` or
/// held alive as a member of a rail's screen stack, so a [ThemeMode] read
/// where the surface is composed is pinned to its value at that moment.
/// Tapping a row would retint the app while the checkmark stayed put.
/// [BlocBuilder] puts the read below the point of construction, where
/// rebuilds happen.
///
/// Requires a [ThemeCubit] above the enclosing [Navigator]; `ThemeApp`
/// satisfies this by providing it above the [MaterialApp].
///
/// ## Example
///
/// ```dart
/// SettingsContent(
///   title: const Text('Settings'),
///   entries: const [ThemeModeEntry()],
/// )
/// ```
class ThemeModeEntry extends AppSettingsEntry {
  /// Creates a [ThemeModeEntry].
  ///
  /// Takes no value or callback: both resolve from the ambient
  /// [ThemeCubit], which is what makes the row self-updating.
  const ThemeModeEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) => ThemeModeCard(
        value: mode,
        onChanged: context.read<ThemeCubit>().setThemeMode,
      ),
    );
  }
}
