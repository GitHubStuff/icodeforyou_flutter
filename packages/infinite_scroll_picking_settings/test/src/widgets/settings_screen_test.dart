// packages/infinite_scroll_picking_settings/test/src/widgets/settings_screen_test.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/src/picker_visual_settings/picker_visual_settings.dart';
import 'package:infinite_scroll_picking_settings/src/settings/settings_cubit.dart';
import 'package:infinite_scroll_picking_settings/src/settings/settings_holder.dart';
import 'package:infinite_scroll_picking_settings/src/settings/settings_repository.dart';
import 'package:infinite_scroll_picking_settings/src/settings/settings_state/settings_state.dart';
import 'package:infinite_scroll_picking_settings/src/widgets/settings_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsHolder extends Mock implements SettingsHolder {}

class _MockSettingsRepository extends Mock implements SettingsRepository {}

class _TestSettingsCubit extends SettingsCubit {
  _TestSettingsCubit({required super.holder, required super.repository});

  int updateCount = 0;

  @override
  void updateSettings(PickerVisualSettings settings) {
    updateCount++;
    super.updateSettings(settings);
  }

  void seed(SettingsState state) => emit(state);
}

void main() {
  late _MockSettingsHolder holder;
  late _MockSettingsRepository repository;

  setUpAll(() {
    registerFallbackValue(const PickerVisualSettings());
  });

  setUp(() {
    holder = _MockSettingsHolder();
    repository = _MockSettingsRepository();
    when(() => holder.value).thenReturn(const PickerVisualSettings());
    when(() => holder.update(any())).thenAnswer((_) {});
    when(() => repository.save(any())).thenAnswer((_) async {});
    when(() => repository.clear()).thenAnswer((_) async {});
  });

  _TestSettingsCubit buildCubit() =>
      _TestSettingsCubit(holder: holder, repository: repository);

  Future<_TestSettingsCubit> pumpScreen(
    WidgetTester tester, {
    _TestSettingsCubit? cubit,
  }) async {
    final c = cubit ?? buildCubit();
    addTearDown(c.close);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SettingsCubit>.value(
          value: c,
          // child: const SettingsScreen(),
          child: SettingsScreen(),
        ),
      ),
    );
    // await tester.pumpAndSettle();
    await tester.pump();
    return c;
  }

  Finder sliderFor(String label) => find.descendant(
    of: find.ancestor(of: find.text(label), matching: find.byType(Row)).first,
    matching: find.byType(Slider),
  );

  Future<void> dragSlider(WidgetTester tester, String label) async {
    final slider = sliderFor(label);
    await tester.ensureVisible(slider);
    await tester.pumpAndSettle();
    await tester.drag(slider, const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.drag(sliderFor(label), const Offset(400, 0));
    await tester.pumpAndSettle();
  }

  SettingsLoaded loadedState(_TestSettingsCubit cubit) =>
      cubit.state as SettingsLoaded;

  group('SettingsScreen state arms', () {
    testWidgets('shows a progress indicator for initial and loading states', (
      tester,
    ) async {
      final cubit = buildCubit()..seed(const SettingsState.initial());
      await pumpScreen(tester, cubit: cubit);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      cubit.seed(const SettingsState.loading());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows the error view for the error state', (tester) async {
      final cubit = buildCubit()
        ..seed(const SettingsState.error(message: 'kaboom'));
      await pumpScreen(tester, cubit: cubit);
      expect(find.text('kaboom'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows the loaded view with all sections and a clean readout', (
      tester,
    ) async {
      await pumpScreen(tester);
      expect(find.text('Picker Settings'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('FRAME'), findsOneWidget);
      expect(find.text('WHEEL — DIMENSIONS'), findsOneWidget);
      expect(find.text('WHEEL — SELECTION BAND'), findsOneWidget);
      expect(find.text('WHEEL — PERSPECTIVE & MOTION'), findsOneWidget);
      expect(find.text('PICKER'), findsOneWidget);
      expect(find.text('Current settings'), findsOneWidget);
      expect(find.text('unsaved'), findsNothing);
    });
  });

  group('slider rows', () {
    testWidgets('every slider drives updateSettings and dirties the state', (
      tester,
    ) async {
      final cubit = await pumpScreen(tester);
      const labels = [
        'frameBorderRadius',
        'frameHorizontalPadding',
        'frameVerticalPadding',
        'itemExtent',
        'wheelWidth',
        'wheelHeight',
        'wheelBorderRadius',
        'dividerThickness',
        'dividerInset',
        'perspectiveDiameter',
        'magnification',
        'selectionDebounce ms',
        'startingIndex',
      ];
      for (final label in labels) {
        final before = cubit.updateCount;
        await dragSlider(tester, label);
        expect(cubit.updateCount, greaterThan(before), reason: label);
      }
      expect(loadedState(cubit).isDirty, isTrue);
      expect(find.text('unsaved'), findsOneWidget);
    });

    testWidgets('wheelHeight is clamped to stay valid against itemExtent', (
      tester,
    ) async {
      final cubit = await pumpScreen(tester);
      await dragSlider(tester, 'itemExtent');
      await dragSlider(tester, 'wheelHeight');
      final wheel = loadedState(cubit).settings.wheel;
      expect(
        wheel.wheelHeight,
        greaterThanOrEqualTo(wheel.itemExtent * 1.1),
      );
    });
  });

  group('showBorder switch', () {
    testWidgets('toggles the wheel border flag', (tester) async {
      final cubit = await pumpScreen(tester);
      final before = loadedState(cubit).settings.wheel.showBorder;
      final sw = find.byType(Switch);
      await tester.ensureVisible(sw);
      await tester.pumpAndSettle();
      await tester.tap(sw);
      await tester.pumpAndSettle();
      expect(loadedState(cubit).settings.wheel.showBorder, !before);
    });
  });

  group('AppBar actions', () {
    const edited = PickerVisualSettings(startingIndex: 5);

    testWidgets('Save is disabled while clean and enabled once dirty', (
      tester,
    ) async {
      final cubit = await pumpScreen(tester);
      final saveButton = find.widgetWithText(TextButton, 'Save');
      expect(tester.widget<TextButton>(saveButton).onPressed, isNull);

      cubit.updateSettings(edited);
      await tester.pumpAndSettle();
      expect(tester.widget<TextButton>(saveButton).onPressed, isNotNull);
    });

    testWidgets('Save persists, updates the holder, and cleans the state', (
      tester,
    ) async {
      final cubit = await pumpScreen(tester);
      cubit.updateSettings(edited);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      verify(() => repository.save(edited)).called(1);
      verify(() => holder.update(edited)).called(1);
      expect(cubit.state, const SettingsState.loaded(settings: edited));
      expect(find.text('unsaved'), findsNothing);
    });

    testWidgets('Save failure surfaces the error view and spares the holder', (
      tester,
    ) async {
      when(() => repository.save(any())).thenThrow(Exception('disk full'));
      final cubit = await pumpScreen(tester);
      cubit.updateSettings(edited);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to save settings'), findsOneWidget);
      verifyNever(() => holder.update(any()));
    });

    testWidgets('Reset restores defaults as a dirty preview', (tester) async {
      final cubit = await pumpScreen(tester);
      cubit.updateSettings(edited);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Reset to defaults'));
      await tester.pumpAndSettle();

      expect(
        cubit.state,
        const SettingsState.loaded(
          settings: PickerVisualSettings(),
          isDirty: true,
        ),
      );
      expect(find.text('unsaved'), findsOneWidget);
    });

    testWidgets('Clear wipes storage, resets the holder, and cleans state', (
      tester,
    ) async {
      final cubit = await pumpScreen(tester);
      await tester.tap(find.byTooltip('Clear stored settings'));
      await tester.pumpAndSettle();

      verify(() => repository.clear()).called(1);
      verify(() => holder.update(const PickerVisualSettings())).called(1);
      expect(
        cubit.state,
        const SettingsState.loaded(settings: PickerVisualSettings()),
      );
    });

    testWidgets('Clear failure surfaces the error view and spares the holder', (
      tester,
    ) async {
      when(() => repository.clear()).thenThrow(Exception('locked'));
      await pumpScreen(tester);

      await tester.tap(find.byTooltip('Clear stored settings'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to clear settings'), findsOneWidget);
      verifyNever(() => holder.update(any()));
    });
  });
}
