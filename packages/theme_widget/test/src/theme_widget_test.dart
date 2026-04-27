// test/src/theme_widget_test.dart

// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async' show StreamController;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:theme_manager/theme_manager.dart';
import 'package:theme_widget/src/theme_selection_body.dart'
    show ThemeSelectionBody;
import 'package:theme_widget/theme_widget.dart' show ThemeWidget;

class _MockThemeCubit extends Mock implements MaterialThemeCubit {}

void main() {
  late _MockThemeCubit cubit;

  setUp(() {
    cubit = _MockThemeCubit();
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.state.mode).thenReturn(ThemeMode.system);
    when(cubit.toLight).thenReturn(null);
    when(cubit.toDark).thenReturn(null);
    when(cubit.toSystem).thenReturn(null);
  });

  Widget _buildSubject({ThemeMode state = ThemeMode.system}) {
    when(() => cubit.state.mode).thenReturn(state);
    return MaterialApp(
      home: Scaffold(
        body: ThemeWidget(cubit: cubit),
      ),
    );
  }

  group('ThemeSelectionWidget', () {
    testWidgets('renders ThemeSelectionBody', (tester) async {
      await tester.pumpWidget(_buildSubject());
      expect(find.byType(ThemeSelectionBody), findsOneWidget);
    });

    testWidgets('passes default title to body', (tester) async {
      await tester.pumpWidget(_buildSubject());
      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('passes custom title to body', (tester) async {
      when(() => cubit.state.mode).thenReturn(ThemeMode.dark);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeWidget(cubit: cubit, title: 'Appearance'),
          ),
        ),
      );
      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('calls toLight when light row tapped', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.tap(find.text('Light'));
      verify(cubit.toLight).called(1);
    });

    testWidgets('calls toDark when dark row tapped', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.tap(find.text('Dark'));
      verify(cubit.toDark).called(1);
    });

    testWidgets('calls toSystem when system row tapped', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.tap(find.text('System'));
      verify(cubit.toSystem).called(1);
    });

    testWidgets('rebuilds when cubit emits new state', (tester) async {
      final controller = StreamController<MaterialThemeState>();
      when(() => cubit.stream).thenAnswer((_) => controller.stream);
      when(() => cubit.state.mode).thenReturn(ThemeMode.system);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeWidget(cubit: cubit),
          ),
        ),
      );

      when(() => cubit.state.mode).thenReturn(ThemeMode.dark);
      controller.add(cubit.state);
      await tester.pump();

      final body = tester.widget<ThemeSelectionBody>(
        find.byType(ThemeSelectionBody),
      );
      expect(body.current, ThemeMode.dark);

      await controller.close();
    });
  });
}
