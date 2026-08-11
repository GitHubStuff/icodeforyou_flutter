// programs/widgetbook/lib/usecases/theme_framework/settings_screen.usecase.dart

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider;
import 'package:theme_framework/theme_framework.dart'
    show SettingsScreen, ThemeCubit;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'in_memory_theme_storage.dart';

/// Placeholder preference entries demonstrating that [SettingsScreen] owns
/// no preference content: the caller supplies the list, the screen only
/// lays it out with separators.
const List<Widget> _kSampleEntries = <Widget>[
  Card(
    margin: EdgeInsets.zero,
    child: ListTile(
      leading: Icon(Icons.notifications_outlined),
      title: Text('Notifications'),
      subtitle: Text('Sample caller-supplied entry'),
    ),
  ),
  Card(
    margin: EdgeInsets.zero,
    child: ListTile(
      leading: Icon(Icons.storage_outlined),
      title: Text('Storage'),
      subtitle: Text('Sample caller-supplied entry'),
    ),
  ),
];

/// Presents [SettingsScreen] with caller-supplied entries only.
///
/// No [ThemeCubit] is provided, and none is needed: the default constructor
/// carries no theme entry, so this use-case doubles as proof that the screen
/// has no hidden bloc dependency. The `title` knob exercises the app-bar
/// title; the two sample cards stand in for arbitrary preference widgets.
@widgetbook.UseCase(name: 'Custom entries', type: SettingsScreen)
Widget buildSettingsScreenUseCase(BuildContext context) {
  final title = context.knobs.string(
    label: 'title',
    initialValue: 'Settings',
  );

  return SettingsScreen(
    title: title,
    preferences: _kSampleEntries,
  );
}

/// Presents [SettingsScreen.withTheme] live against its own [ThemeCubit].
///
/// The factory prepends a theme-mode selector whose `BlocBuilder` subscribes
/// internally, so taps complete the round trip while the sample entries
/// below it stay inert. The cubit is scoped here and backed by
/// [InMemoryThemeStorage], so nothing persists across workbench restarts.
@widgetbook.UseCase(name: 'With theme', type: SettingsScreen)
Widget buildSettingsScreenWithThemeUseCase(BuildContext context) {
  final title = context.knobs.string(
    label: 'title',
    initialValue: 'Settings',
  );

  return BlocProvider<ThemeCubit>(
    create: (_) {
      final cubit = ThemeCubit(InMemoryThemeStorage());
      unawaited(cubit.restore());
      return cubit;
    },
    child: SettingsScreen.withTheme(
      title: title,
      preferences: _kSampleEntries,
    ),
  );
}
