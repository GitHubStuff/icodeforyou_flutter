// infinite_scroll_picking_settings/test/src/widgets/settings_screen_test.dart

// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/src/picker_visual_settings/picker_visual_settings.dart';
import 'package:infinite_scroll_picking_settings/src/settings/settings_cubit.dart';
import 'package:infinite_scroll_picking_settings/src/settings/settings_state/settings_state.dart';
import 'package:infinite_scroll_picking_settings/src/widgets/settings_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

void main() {
  late _MockSettingsCubit cubit;

  setUp(() {
    cubit = _MockSettingsCubit();
  });

  Widget hostWidget() {
    return MaterialApp(
      home: BlocProvider<SettingsCubit>.value(
        value: cubit,
        child: SettingsScreen(),
      ),
    );
  }

  group('SettingsScreen', () {
    testWidgets('shows progress indicator on SettingsInitial', (tester) async {
      when(() => cubit.state).thenReturn(const SettingsInitial());

      await tester.pumpWidget(hostWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows progress indicator on SettingsLoading', (tester) async {
      when(() => cubit.state).thenReturn(const SettingsLoading());

      await tester.pumpWidget(hostWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message on SettingsError', (tester) async {
      when(() => cubit.state).thenReturn(const SettingsError(message: 'boom'));

      await tester.pumpWidget(hostWidget());

      expect(find.text('boom'), findsOneWidget);
    });

    testWidgets('shows loaded view on SettingsLoaded', (tester) async {
      when(() => cubit.state).thenReturn(
        SettingsLoaded(
          settings: PickerVisualSettings(),
          isDirty: false,
        ),
      );

      await tester.pumpWidget(hostWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Picker Settings'), findsOneWidget);
    });
  });
}
