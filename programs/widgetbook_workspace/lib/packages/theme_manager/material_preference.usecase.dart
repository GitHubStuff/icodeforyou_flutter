// programs/widgetbook/lib/usecases/theme_manager/material_preference.usecase.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider, ReadContext;
import 'package:theme_manager/theme_manager.dart'
    show MaterialPreference, MaterialTheme, MaterialThemeCubit;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'in_memory_theme_persistence.dart';

/// Presents [MaterialPreference] live against its own [MaterialThemeCubit].
///
/// Unlike the controlled `ThemeSelectionBody` use-case, taps here complete
/// the round trip: the widget's internal `BlocBuilder` subscribes to the
/// supplied cubit, a tap dispatches through `toLight`/`toDark`/`toSystem`,
/// and the lit dot follows — the drop-in behaviour the widget exists to
/// provide.
///
/// The cubit takes its constructor dependencies rather than an ambient
/// provider, so the [BlocProvider] here exists purely for lifecycle — it
/// creates the cubit once and closes it when the use-case is torn down —
/// and the inner [Builder] reads it back out to pass explicitly. It is
/// backed by [InMemoryThemePersistence], so selections never persist across
/// workbench restarts, and seeded with a default [MaterialTheme], whose
/// initial mode is dark.
///
/// The `title` knob exercises the heading; icon and label parameters keep
/// their Material defaults, which the `ThemeRadioRow` use-case already
/// exercises individually. The [Material] ancestor exists because each
/// row's [InkWell] requires one; in production the enclosing [Scaffold]
/// provides it.
@widgetbook.UseCase(name: 'Live', type: MaterialPreference)
Widget buildMaterialPreferenceUseCase(BuildContext context) {
  final title = context.knobs.string(
    label: 'title',
    initialValue: 'Theme',
  );

  return BlocProvider<MaterialThemeCubit>(
    create: (_) => MaterialThemeCubit(
      theme: MaterialTheme(),
      themeModeStorage: InMemoryThemePersistence(),
    ),
    child: Material(
      type: MaterialType.transparency,
      child: SingleChildScrollView(
        child: Builder(
          builder: (context) => MaterialPreference(
            cubit: context.read<MaterialThemeCubit>(),
            title: title,
          ),
        ),
      ),
    ),
  );
}
