// programs/widgetbook_workspace/lib/packages/theme_framework/theme_setting_screen.usecase.dart

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider;
import 'package:theme_framework/theme_framework.dart'
    show ThemeCubit, ThemeSettingScreen;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'in_memory_theme_storage.dart';

/// Presents [ThemeSettingScreen] live against its own [ThemeCubit].
///
/// The screen subscribes internally, so taps complete the round trip: a
/// selection writes through `setThemeMode` and the checkmark follows without
/// this use-case holding any state. The cubit is scoped here and backed by
/// [InMemoryThemeStorage], so nothing persists across workbench restarts.
///
/// The `Show app-bar action` knob exercises the [ThemeSettingScreen.actions]
/// slot with a single [IconButton]; off leaves the slot `null`, matching the
/// widget's default.
@widgetbook.UseCase(name: 'Default', type: ThemeSettingScreen)
Widget buildThemeSettingScreenUseCase(BuildContext context) {
  final showAction = context.knobs.boolean(
    label: 'Show app-bar action',
    initialValue: false,
  );

  return BlocProvider<ThemeCubit>(
    create: (_) {
      final cubit = ThemeCubit(InMemoryThemeStorage());
      unawaited(cubit.restore());
      return cubit;
    },
    child: ThemeSettingScreen(
      actions: showAction
          ? <Widget>[
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () =>
                    debugPrint('ThemeSettingScreen: action tapped'),
              ),
            ]
          : null,
    ),
  );
}
