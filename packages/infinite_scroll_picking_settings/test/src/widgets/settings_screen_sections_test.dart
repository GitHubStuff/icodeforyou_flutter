// packages/infinite_scroll_picking_settings/test/src/widgets/settings_screen_sections_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking/infinite_scroll_picking.dart'
    show InfiniteScrollPicker;
import 'package:infinite_scroll_picking_settings/src/picker_visual_settings/picker_visual_settings.dart'
    show PickerVisualSettings;
import 'package:infinite_scroll_picking_settings/src/settings/settings_cubit.dart'
    show SettingsCubit;
import 'package:infinite_scroll_picking_settings/src/settings/settings_holder.dart'
    show SettingsHolder;
import 'package:infinite_scroll_picking_settings/src/settings/settings_repository.dart'
    show SettingsRepository;
import 'package:infinite_scroll_picking_settings/src/settings/settings_state/settings_state.dart'
    show SettingsLoaded;
import 'package:infinite_scroll_picking_settings/src/widgets/settings_screen.dart'
    show SettingsScreen;

/// No-op repository — section tests never persist.
final class _FakeRepository implements SettingsRepository {
  @override
  Future<PickerVisualSettings?> load() async => null;

  @override
  Future<void> save(PickerVisualSettings settings) async {}

  @override
  Future<void> clear() async {}
}

/// Reads the current loaded settings out of [cubit].
PickerVisualSettings _settingsOf(SettingsCubit cubit) =>
    (cubit.state as SettingsLoaded).settings;

/// Finds the [Slider] in the row labeled [label].
Finder _sliderFor(String label) => find.descendant(
  of: find.widgetWithText(Row, label),
  matching: find.byType(Slider),
);

/// Scrolls the labeled slider into view, then drags it by [dx].
///
/// Material [Slider] gesture semantics: the gesture starts at the
/// widget's *center*, and the thumb jumps to the touch-down position
/// before tracking the move. The resulting value is therefore relative
/// to the range midpoint, not the current value. Saturating drags
/// (|dx| well beyond the track width) deterministically land on the
/// range min/max; small drags land near mid-range.
Future<void> _dragSlider(
  WidgetTester tester,
  String label,
  double dx,
) async {
  final finder = _sliderFor(label);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.drag(finder, Offset(dx, 0));
  await tester.pumpAndSettle();
}

/// Pumps a [SettingsScreen] over a fresh cubit on a tall surface and
/// returns the cubit for state assertions.
Future<SettingsCubit> _pumpScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final holder = SettingsHolder(const PickerVisualSettings());
  addTearDown(holder.dispose);
  final cubit = SettingsCubit(
    holder: holder,
    repository: _FakeRepository(),
  );
  addTearDown(cubit.close);

  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<SettingsCubit>.value(
        value: cubit,
        child: const SettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  group('Frame section', () {
    testWidgets('all three frame sliders update their fields', (tester) async {
      final cubit = await _pumpScreen(tester);

      await _dragSlider(tester, 'frameBorderRadius', 200);
      expect(_settingsOf(cubit).frameBorderRadius, isNot(8.0));

      await _dragSlider(tester, 'frameHorizontalPadding', 200);
      expect(_settingsOf(cubit).frameHorizontalPadding, isNot(12.0));

      await _dragSlider(tester, 'frameVerticalPadding', 200);
      expect(_settingsOf(cubit).frameVerticalPadding, isNot(6.0));

      expect((cubit.state as SettingsLoaded).isDirty, isTrue);
    });
  });

  group('Wheel dimensions section', () {
    testWidgets('raising itemExtent clamps wheelHeight up with it', (
      tester,
    ) async {
      final cubit = await _pumpScreen(tester);

      await _dragSlider(tester, 'itemExtent', 600);

      final wheel = _settingsOf(cubit).wheel;
      expect(wheel.itemExtent, 70);
      expect(wheel.wheelHeight, moreOrLessEquals(70 * 1.1 + 0.1));
    });

    testWidgets('a moderate itemExtent leaves a tall-enough wheelHeight '
        'untouched', (tester) async {
      final cubit = await _pumpScreen(tester);

      // Center-jump lands the value near the range midpoint (~39).
      // Any itemExtent below 43.5 keeps min height under the current
      // wheelHeight of 48, exercising the clamp's pass-through branch.
      await _dragSlider(tester, 'itemExtent', -60);

      final wheel = _settingsOf(cubit).wheel;
      expect(wheel.itemExtent, isNot(24.0));
      expect(wheel.itemExtent * 1.1 + 0.1, lessThan(48));
      expect(wheel.wheelHeight, 48.0);
    });

    testWidgets('wheelWidth and wheelBorderRadius sliders update', (
      tester,
    ) async {
      final cubit = await _pumpScreen(tester);

      await _dragSlider(tester, 'wheelWidth', 200);
      expect(_settingsOf(cubit).wheel.wheelWidth, isNot(56.0));

      await _dragSlider(tester, 'wheelBorderRadius', 200);
      expect(_settingsOf(cubit).wheel.wheelBorderRadius, isNot(8.0));
    });

    testWidgets('dragging wheelHeight below the minimum clamps it', (
      tester,
    ) async {
      final cubit = await _pumpScreen(tester);

      await _dragSlider(tester, 'wheelHeight', -900);

      expect(
        _settingsOf(cubit).wheel.wheelHeight,
        moreOrLessEquals(24 * 1.1 + 0.1),
      );
    });

    testWidgets('dragging wheelHeight above the minimum passes through', (
      tester,
    ) async {
      final cubit = await _pumpScreen(tester);

      await _dragSlider(tester, 'wheelHeight', 300);

      expect(_settingsOf(cubit).wheel.wheelHeight, greaterThan(48));
    });
  });

  group('Selection band section', () {
    testWidgets('divider sliders update their fields', (tester) async {
      final cubit = await _pumpScreen(tester);

      await _dragSlider(tester, 'dividerThickness', 200);
      expect(_settingsOf(cubit).wheel.dividerThickness, isNot(1.0));

      await _dragSlider(tester, 'dividerInset', 200);
      expect(_settingsOf(cubit).wheel.dividerInset, isNot(4.0));
    });
  });

  group('Perspective & motion section', () {
    testWidgets('perspective and magnification sliders update', (tester) async {
      final cubit = await _pumpScreen(tester);

      await _dragSlider(tester, 'perspectiveDiameter', 200);
      expect(_settingsOf(cubit).wheel.perspectiveDiameter, isNot(1.2));

      await _dragSlider(tester, 'magnification', 200);
      expect(_settingsOf(cubit).wheel.magnification, isNot(1.25));
    });

    testWidgets('debounce slider produces a rounded-millisecond Duration', (
      tester,
    ) async {
      final cubit = await _pumpScreen(tester);

      await _dragSlider(tester, 'selectionDebounce ms', 300);

      final debounce = _settingsOf(cubit).wheel.selectionDebounce;
      expect(debounce, greaterThan(Duration.zero));
      expect(debounce.inMilliseconds % 25, 0);
    });
  });

  group('Picker section', () {
    testWidgets('startingIndex slider rounds to an int', (tester) async {
      final cubit = await _pumpScreen(tester);

      await _dragSlider(tester, 'startingIndex', 300);

      expect(_settingsOf(cubit).startingIndex, greaterThan(0));
    });
  });

  group('Preview header', () {
    testWidgets('scrolling the preview wheel fires onItemSelected '
        'without error', (tester) async {
      await _pumpScreen(tester);
      final picker = find.byType(InfiniteScrollPicker<int, String>);
      expect(picker, findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);

      await tester.drag(picker, const Offset(0, -48));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
