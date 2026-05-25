// theme_widget/test/src/theme_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_manager/theme_manager.dart'
    show MaterialThemeCubit, MaterialThemeState;
import 'package:theme_widget/src/theme_selection_body.dart';
import 'package:theme_widget/theme_widget.dart';

class _StubMaterialThemeState implements MaterialThemeState {
  _StubMaterialThemeState({
    this.mode = ThemeMode.dark,
    ThemeData? dark,
    ThemeData? light,
  }) : dark = dark ?? ThemeData.dark(),
       light = light ?? ThemeData.light();

  @override
  final ThemeMode mode;

  @override
  final ThemeData dark;

  @override
  final ThemeData light;

  @override
  MaterialThemeState copyWith({
    ThemeMode? mode,
    ThemeData? dark,
    ThemeData? light,
  }) {
    return _StubMaterialThemeState(
      mode: mode ?? this.mode,
      dark: dark ?? this.dark,
      light: light ?? this.light,
    );
  }
}

class _RecordingMaterialThemeCubit extends Cubit<MaterialThemeState>
    implements MaterialThemeCubit {
  _RecordingMaterialThemeCubit(super.initialState);

  int toLightCallCount = 0;
  int toDarkCallCount = 0;
  int toSystemCallCount = 0;

  @override
  void toLight() {
    toLightCallCount++;
    emit(_StubMaterialThemeState(mode: ThemeMode.light));
  }

  @override
  void toDark() {
    toDarkCallCount++;
    emit(_StubMaterialThemeState(mode: ThemeMode.dark));
  }

  @override
  void toSystem() {
    toSystemCallCount++;
    emit(_StubMaterialThemeState(mode: ThemeMode.system));
  }
}

void main() {
  group('ThemeWidget', () {
    late _RecordingMaterialThemeCubit cubit;

    setUp(() {
      cubit = _RecordingMaterialThemeCubit(
        _StubMaterialThemeState(mode: ThemeMode.dark),
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    Widget buildSubject({
      String title = 'Theme',
      IconData systemIcon = Icons.brightness_auto,
      IconData darkIcon = Icons.dark_mode,
      IconData lightIcon = Icons.light_mode,
      String systemLabel = 'System',
      String darkLabel = 'Dark',
      String lightLabel = 'Light',
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ThemeWidget(
            cubit: cubit,
            title: title,
            systemIcon: systemIcon,
            darkIcon: darkIcon,
            lightIcon: lightIcon,
            systemLabel: systemLabel,
            darkLabel: darkLabel,
            lightLabel: lightLabel,
          ),
        ),
      );
    }

    testWidgets(
      'builds a ThemeSelectionBody bound to the cubit state',
      (tester) async {
        await tester.pumpWidget(buildSubject(title: 'Appearance'));

        final body = tester.widget<ThemeSelectionBody>(
          find.byType(ThemeSelectionBody),
        );

        expect(body.title, 'Appearance');
        expect(body.current, ThemeMode.dark);
        expect(body.options, hasLength(3));
      },
    );

    testWidgets(
      'options are emitted in order: system, dark, light, with the '
      'supplied icons and labels',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            systemIcon: Icons.settings_brightness,
            darkIcon: Icons.nights_stay,
            lightIcon: Icons.wb_sunny,
            systemLabel: 'Sistema',
            darkLabel: 'Oscuro',
            lightLabel: 'Claro',
          ),
        );

        final body = tester.widget<ThemeSelectionBody>(
          find.byType(ThemeSelectionBody),
        );
        final options = body.options;

        expect(options[0].mode, ThemeMode.system);
        expect(options[0].icon, Icons.settings_brightness);
        expect(options[0].label, 'Sistema');

        expect(options[1].mode, ThemeMode.dark);
        expect(options[1].icon, Icons.nights_stay);
        expect(options[1].label, 'Oscuro');

        expect(options[2].mode, ThemeMode.light);
        expect(options[2].icon, Icons.wb_sunny);
        expect(options[2].label, 'Claro');
      },
    );

    testWidgets(
      'rebuilds with the new mode when the cubit emits a new state',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        expect(
          tester.widget<ThemeSelectionBody>(find.byType(ThemeSelectionBody))
              .current,
          ThemeMode.dark,
        );

        cubit.emit(_StubMaterialThemeState(mode: ThemeMode.light));
        await tester.pump();

        expect(
          tester.widget<ThemeSelectionBody>(find.byType(ThemeSelectionBody))
              .current,
          ThemeMode.light,
        );
      },
    );

    testWidgets(
      '_onChanged routes ThemeMode.light to cubit.toLight',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        final body = tester.widget<ThemeSelectionBody>(
          find.byType(ThemeSelectionBody),
        );

        body.onChanged(ThemeMode.light);

        expect(cubit.toLightCallCount, 1);
        expect(cubit.toDarkCallCount, 0);
        expect(cubit.toSystemCallCount, 0);
      },
    );

    testWidgets(
      '_onChanged routes ThemeMode.dark to cubit.toDark',
      (tester) async {
        cubit
          ..close().ignore()
          ..toDarkCallCount = 0;
        cubit = _RecordingMaterialThemeCubit(
          _StubMaterialThemeState(mode: ThemeMode.light),
        );

        await tester.pumpWidget(buildSubject());

        final body = tester.widget<ThemeSelectionBody>(
          find.byType(ThemeSelectionBody),
        );

        body.onChanged(ThemeMode.dark);

        expect(cubit.toDarkCallCount, 1);
        expect(cubit.toLightCallCount, 0);
        expect(cubit.toSystemCallCount, 0);
      },
    );

    testWidgets(
      '_onChanged routes ThemeMode.system to cubit.toSystem',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        final body = tester.widget<ThemeSelectionBody>(
          find.byType(ThemeSelectionBody),
        );

        body.onChanged(ThemeMode.system);

        expect(cubit.toSystemCallCount, 1);
        expect(cubit.toLightCallCount, 0);
        expect(cubit.toDarkCallCount, 0);
      },
    );
  });
}
