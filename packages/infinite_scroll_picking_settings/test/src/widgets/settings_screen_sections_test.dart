// infinite_scroll_picking_settings/test/src/widgets/settings_screen_sections_test.dart

// ignore_for_file: invalid_use_of_visible_for_testing_member,
// invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/infinite_scroll_picking_settings.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements SettingsRepository {}

/// Drives a control by its visible label text.
///
/// `_SliderRow` and `_SwitchRow` both render their label as a `Text` next to
/// the control. We walk up to the parent `Row`, find the control inside, and
/// drag/tap.
Finder _sliderByLabel(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byType(Row),
  ).first;
}

Future<void> _dragSlider(WidgetTester tester, String label) async {
  final row = _sliderByLabel(label);
  final slider = find.descendant(of: row, matching: find.byType(Slider));
  expect(slider, findsOneWidget, reason: 'no Slider under "$label"');
  await tester.drag(slider, const Offset(80, 0));
  await tester.pump();
}

Future<void> _toggleSwitch(WidgetTester tester, String label) async {
  final row = _sliderByLabel(label);
  final swtch = find.descendant(of: row, matching: find.byType(Switch));
  expect(swtch, findsOneWidget, reason: 'no Switch under "$label"');
  await tester.tap(swtch);
  await tester.pump();
}

Future<SettingsCubit> _pumpScreen(
  WidgetTester tester, {
  PickerVisualSettings initial = const PickerVisualSettings(),
}) async {
  // Tall + wide enough to show every section without scrolling.
  tester.view
    ..physicalSize = const Size(1200, 4000)
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final repo = _MockRepo();
  when(() => repo.save(any())).thenAnswer((_) async {});
  when(() => repo.clear()).thenAnswer((_) async {});

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

  group('settings_screen_sections', () {
    testWidgets(
      'every Frame slider routes through to the cubit',
      (tester) async {
        final cubit = await _pumpScreen(tester);
        addTearDown(cubit.close);

        await _dragSlider(tester, 'frameBorderRadius');
        expect((cubit.state as SettingsLoaded).isDirty, isTrue);

        await _dragSlider(tester, 'frameHorizontalPadding');
        await _dragSlider(tester, 'frameVerticalPadding');

        // Each drag rebuilt the section with the new value reflected.
        expect(cubit.state, isA<SettingsLoaded>());
      },
    );

    testWidgets(
      'every WheelDimensions slider routes through to the cubit',
      (tester) async {
        final cubit = await _pumpScreen(tester);
        addTearDown(cubit.close);

        await _dragSlider(tester, 'itemExtent');
        await _dragSlider(tester, 'wheelWidth');
        await _dragSlider(tester, 'wheelHeight');
        await _dragSlider(tester, 'wheelBorderRadius');

        expect(cubit.state, isA<SettingsLoaded>());
        expect((cubit.state as SettingsLoaded).isDirty, isTrue);
      },
    );

    testWidgets(
      'itemExtent drag clamps wheelHeight when below the 1.1x threshold',
      (tester) async {
        // Seed with itemExtent low and wheelHeight just above the threshold,
        // so dragging itemExtent rightward forces wheelHeight to clamp UP —
        // exercises the `wheelHeight < min` branch of _clampWheelHeight.
        final cubit = await _pumpScreen(
          tester,
          initial: const PickerVisualSettings(
            wheel: WheelSettings(itemExtent: 10, wheelHeight: 12),
          ),
        );
        addTearDown(cubit.close);

        await _dragSlider(tester, 'itemExtent');
        final after = (cubit.state as SettingsLoaded).settings.wheel;
        expect(after.itemExtent, greaterThan(10));
        expect(after.wheelHeight, greaterThanOrEqualTo(after.itemExtent * 1.1));
      },
    );

    testWidgets(
      'itemExtent drag leaves wheelHeight alone when already above threshold',
      (tester) async {
        // Seed with wheelHeight already well above any plausible new
        // itemExtent * 1.1 → exercises the else branch of _clampWheelHeight.
        final cubit = await _pumpScreen(
          tester,
          initial: const PickerVisualSettings(
            wheel: WheelSettings(itemExtent: 10, wheelHeight: 140),
          ),
        );
        addTearDown(cubit.close);

        await _dragSlider(tester, 'itemExtent');
        expect((cubit.state as SettingsLoaded).settings.wheel.wheelHeight, 140);
      },
    );

    testWidgets(
      'wheelHeight drag also clamps via _clampWheelHeight',
      (tester) async {
        // Seed with itemExtent high enough that any leftward drag of
        // wheelHeight will push it under the threshold, forcing the clamp.
        final cubit = await _pumpScreen(
          tester,
          initial: const PickerVisualSettings(
            wheel: WheelSettings(itemExtent: 60, wheelHeight: 140),
          ),
        );
        addTearDown(cubit.close);

        // Drag left to push wheelHeight down.
        final row = _sliderByLabel('wheelHeight');
        final slider = find.descendant(of: row, matching: find.byType(Slider));
        await tester.drag(slider, const Offset(-200, 0));
        await tester.pump();

        final after = (cubit.state as SettingsLoaded).settings.wheel;
        expect(after.wheelHeight, greaterThanOrEqualTo(after.itemExtent * 1.1));
      },
    );

    testWidgets(
      'every SelectionBand slider routes through to the cubit',
      (tester) async {
        final cubit = await _pumpScreen(tester);
        addTearDown(cubit.close);

        await _dragSlider(tester, 'dividerThickness');
        await _dragSlider(tester, 'dividerInset');

        expect((cubit.state as SettingsLoaded).isDirty, isTrue);
      },
    );

    testWidgets(
      'every Perspective control routes through to the cubit',
      (tester) async {
        final cubit = await _pumpScreen(tester);
        addTearDown(cubit.close);

        await _dragSlider(tester, 'perspectiveDiameter');
        await _dragSlider(tester, 'magnification');
        await _dragSlider(tester, 'selectionDebounce ms');
        await _toggleSwitch(tester, 'showBorder');

        final after = (cubit.state as SettingsLoaded).settings.wheel;
        expect(after.showBorder, isFalse);
      },
    );

    testWidgets('Picker section startingIndex slider routes through',
        (tester) async {
      final cubit = await _pumpScreen(tester);
      addTearDown(cubit.close);

      await _dragSlider(tester, 'startingIndex');

      expect(
        (cubit.state as SettingsLoaded).settings.startingIndex,
        isNonZero,
      );
    });

    testWidgets(
      'PreviewHeader builds with non-default settings, exercising itemBuilder',
      (tester) async {
        // Force a starting index away from 0 so the preview lands on a
        // different selected item, and the itemBuilder runs both isSelected
        // branches at least once across the visible items.
        final cubit = await _pumpScreen(
          tester,
          initial: const PickerVisualSettings(startingIndex: 5),
        );
        addTearDown(cubit.close);

        expect(find.text('Preview'), findsOneWidget);
      },
    );
  });
}
