// programs/widgetbook_workspace/lib/packages/theme_framework/theme_mode_entry.usecase.dart

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider;
import 'package:theme_framework/theme_framework.dart'
    show ThemeCubit, ThemeModeEntry;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'in_memory_theme_storage.dart';

/// Inset around the entry so it does not touch the workbench edges.
const EdgeInsets _kPadding = EdgeInsets.all(16);

/// Presents [ThemeModeEntry] live against its own [ThemeCubit].
///
/// Unlike the controlled `ThemeModeCard` use-case, taps here complete the
/// round trip: the entry's internal `BlocBuilder` reads the cubit, a tap
/// writes back through `setThemeMode`, and the checkmark follows — which is
/// exactly the self-updating behaviour the entry exists to provide.
///
/// The cubit is scoped to this use-case and backed by [InMemoryThemeStorage],
/// so selections never persist across workbench restarts. `restore()` runs
/// unawaited on creation, mirroring the production hydration path: the entry
/// briefly shows the dark splash seed, then settles on
/// [ThemeMode.system] because the storage starts empty.
@widgetbook.UseCase(name: 'Live', type: ThemeModeEntry)
Widget buildThemeModeEntryUseCase(BuildContext context) {
  return BlocProvider<ThemeCubit>(
    create: (_) {
      final cubit = ThemeCubit(InMemoryThemeStorage());
      unawaited(cubit.restore());
      return cubit;
    },
    child: const SingleChildScrollView(
      padding: _kPadding,
      child: ThemeModeEntry(),
    ),
  );
}
