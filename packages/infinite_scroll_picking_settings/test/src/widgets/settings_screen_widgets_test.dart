// infinite_scroll_picking_settings/test/src/widgets/settings_screen_widgets_test.dart

// ignore_for_file: invalid_use_of_visible_for_testing_member,
// invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/infinite_scroll_picking_settings.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements SettingsRepository {}

Future<SettingsCubit> _pumpScreen(
  WidgetTester tester, {
  PickerVisualSettings initial = const PickerVisualSettings(),
  SettingsRepository? repository,
}) async {
  // Tall + wide enough to show every section without scrolling.
  tester.view
    ..physicalSize = const Size(1200, 4000)
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final SettingsRepository repo;
  if (repository != null) {
    repo = repository;
  } else {
    final mock = _MockRepo();
    when(() => mock.save(any())).thenAnswer((_) async {});
    when(() => mock.clear()).thenAnswer((_) async {});
    repo = mock;
  }

  final holder = SettingsHolder(initial);
  final cubit = SettingsCubit(holder: holder, repository: repo);

  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<SettingsCubit>.value(
        value: cubit,
        child: const SettingsScreen(),
      ),
    ),
  );

  return cubit;
}

void main() {
  setUpAll(() {
    registerFallbackValue(const PickerVisualSettings());
  });

  group('AppBar actions', () {
    group('_SaveAction', () {
      testWidgets(
        'is disabled while the cubit is clean',
        (tester) async {
          final cubit = await _pumpScreen(tester);
          addTearDown(cubit.close);

          final button = tester.widget<TextButton>(
            find.ancestor(
              of: find.text('Save'),
              matching: find.byType(TextButton),
            ),
          );
          expect(button.onPressed, isNull);
        },
      );

      testWidgets(
        'is enabled and calls cubit.save() when the cubit is dirty',
        (tester) async {
          final cubit = await _pumpScreen(tester);
          addTearDown(cubit.close);

          // Force dirty state via the cubit's public API.
          cubit.updateSettings(const PickerVisualSettings(startingIndex: 5));
          await tester.pump();

          await tester.tap(find.text('Save'));
          await tester.pump();

          // After save the cubit lands back on loaded(clean).
          expect((cubit.state as SettingsLoaded).isDirty, isFalse);
        },
      );
    });

    testWidgets('_ResetAction calls cubit.reset()', (tester) async {
      final cubit = await _pumpScreen(
        tester,
        initial: const PickerVisualSettings(startingIndex: 7),
      );
      addTearDown(cubit.close);

      await tester.tap(find.byTooltip('Reset to defaults'));
      await tester.pump();

      // reset() emits loaded(defaults, dirty).
      final state = cubit.state as SettingsLoaded;
      expect(state.settings, const PickerVisualSettings());
      expect(state.isDirty, isTrue);
    });

    testWidgets('_ClearAction calls cubit.clearPersisted()', (tester) async {
      final cubit = await _pumpScreen(
        tester,
        initial: const PickerVisualSettings(startingIndex: 7),
      );
      addTearDown(cubit.close);

      await tester.tap(find.byTooltip('Clear stored settings'));
      await tester.pump();

      // clearPersisted() emits loaded(defaults, clean).
      final state = cubit.state as SettingsLoaded;
      expect(state.settings, const PickerVisualSettings());
      expect(state.isDirty, isFalse);
    });
  });

  group('_ErrorView', () {
    testWidgets('renders the message text in the error color', (tester) async {
      final cubit = await _pumpScreen(tester);
      addTearDown(cubit.close);

      cubit.emit(const SettingsState.error(message: 'boom'));
      await tester.pump();

      expect(find.text('boom'), findsOneWidget);

      // The Text inside _ErrorView styles itself with the colorScheme.error.
      final text = tester.widget<Text>(find.text('boom'));
      final BuildContext ctx = tester.element(find.text('boom'));
      expect(text.style?.color, Theme.of(ctx).colorScheme.error);
      expect(text.textAlign, TextAlign.center);
    });
  });

  group('_StateReadout', () {
    testWidgets(
      'shows current values and hides the unsaved chip when clean',
      (tester) async {
        final cubit = await _pumpScreen(
          tester,
          initial: const PickerVisualSettings(startingIndex: 3),
        );
        addTearDown(cubit.close);

        expect(find.text('Current settings'), findsOneWidget);
        expect(find.text('startingIndex: 3'), findsOneWidget);
        expect(find.text('frameBorderRadius: 8.0'), findsOneWidget);
        expect(find.text('frameHorizontalPadding: 12.0'), findsOneWidget);
        expect(find.text('frameVerticalPadding: 6.0'), findsOneWidget);
        expect(find.text('itemExtent: 24.0'), findsOneWidget);
        expect(find.text('wheelWidth: 56.0'), findsOneWidget);
        expect(find.text('wheelHeight: 48.0'), findsOneWidget);
        expect(find.text('magnification: 1.25'), findsOneWidget);
        expect(find.text('selectionDebounce: 0ms'), findsOneWidget);

        // No Chip while clean.
        expect(find.byType(Chip), findsNothing);
      },
    );

    testWidgets(
      'shows the "unsaved" chip when the cubit is dirty',
      (tester) async {
        final cubit = await _pumpScreen(tester);
        addTearDown(cubit.close);

        cubit.updateSettings(const PickerVisualSettings(startingIndex: 1));
        await tester.pump();

        expect(find.text('unsaved'), findsOneWidget);
        expect(find.byType(Chip), findsOneWidget);
      },
    );
  });

  group('_SliderRow', () {
    testWidgets(
      'displays the label, value, and a Slider with the right range',
      (tester) async {
        final cubit = await _pumpScreen(
          tester,
          // Pick a frameBorderRadius value to verify exact display.
          initial: const PickerVisualSettings(frameBorderRadius: 12),
        );
        addTearDown(cubit.close);

        // Label appears.
        expect(find.text('frameBorderRadius'), findsOneWidget);

        // Value text uses the configured fractionDigits (1 by default).
        expect(find.text('12.0'), findsWidgets);

        // The slider's value matches.
        final row = find
            .ancestor(of: find.text('frameBorderRadius'), matching: find.byType(Row))
            .first;
        final slider = tester.widget<Slider>(
          find.descendant(of: row, matching: find.byType(Slider)),
        );
        expect(slider.value, 12);
        expect(slider.min, 0);
        expect(slider.max, 24);
      },
    );

    testWidgets(
      'clamps the displayed slider value when the source is out of range',
      (tester) async {
        // wheelHeight default is 48; range is (8, 140). Pick a starting
        // value outside the range to exercise the value.clamp(...) path.
        final cubit = await _pumpScreen(
          tester,
          initial: const PickerVisualSettings(
            wheel: WheelSettings(itemExtent: 70, wheelHeight: 200),
          ),
        );
        addTearDown(cubit.close);

        final row = find
            .ancestor(of: find.text('wheelHeight'), matching: find.byType(Row))
            .first;
        final slider = tester.widget<Slider>(
          find.descendant(of: row, matching: find.byType(Slider)),
        );
        // Slider.value clamped to the configured max.
        expect(slider.value, lessThanOrEqualTo(slider.max));
      },
    );
  });

  group('_SwitchRow', () {
    testWidgets(
      'reflects the current bool and toggles via onChanged',
      (tester) async {
        final cubit = await _pumpScreen(tester);
        addTearDown(cubit.close);

        // Default showBorder is true.
        final row = find
            .ancestor(of: find.text('showBorder'), matching: find.byType(Row))
            .first;
        var swtch = tester.widget<Switch>(
          find.descendant(of: row, matching: find.byType(Switch)),
        );
        expect(swtch.value, isTrue);

        await tester.tap(find.descendant(of: row, matching: find.byType(Switch)));
        await tester.pump();

        // Re-find after rebuild.
        final row2 = find
            .ancestor(of: find.text('showBorder'), matching: find.byType(Row))
            .first;
        swtch = tester.widget<Switch>(
          find.descendant(of: row2, matching: find.byType(Switch)),
        );
        expect(swtch.value, isFalse);
      },
    );
  });

  group('_SectionHeader', () {
    testWidgets('uppercases its label text', (tester) async {
      final cubit = await _pumpScreen(tester);
      addTearDown(cubit.close);

      // Sections in the screen pass labels like 'Frame', 'Picker', etc.
      expect(find.text('FRAME'), findsOneWidget);
      expect(find.text('PICKER'), findsOneWidget);
      expect(find.text('WHEEL — DIMENSIONS'), findsOneWidget);
    });
  });
}
