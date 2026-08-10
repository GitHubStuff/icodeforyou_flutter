// infinite_scroll_picking_settings/test/src/widgets/settings_screen_widgets_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
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

/// Repository recording interactions for the action-button tests.
final class _FakeRepository implements SettingsRepository {
  /// Last settings received by [save]; null when never saved.
  PickerVisualSettings? saved;

  /// Number of [clear] invocations.
  int clearCalls = 0;

  @override
  Future<PickerVisualSettings?> load() async => saved;

  @override
  Future<void> save(PickerVisualSettings settings) async {
    saved = settings;
  }

  @override
  Future<void> clear() async {
    clearCalls++;
    saved = null;
  }
}

/// Seed distinct from defaults so Reset/Clear effects are observable.
const _kSeed = PickerVisualSettings(startingIndex: 3);

/// Finds the labeled [Switch] row's switch.
Finder get _showBorderSwitch => find.byType(Switch);

/// Pumps a [SettingsScreen] and returns the wired cubit, repository,
/// and holder for assertions.
Future<(SettingsCubit, _FakeRepository, SettingsHolder)> _pumpScreen(
  WidgetTester tester,
) async {
  tester.view.physicalSize = const Size(1200, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final holder = SettingsHolder(_kSeed);
  addTearDown(holder.dispose);
  final repository = _FakeRepository();
  final cubit = SettingsCubit(holder: holder, repository: repository);
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
  return (cubit, repository, holder);
}

/// Marks the cubit dirty through the UI by toggling the showBorder
/// switch — a single deterministic tap, unlike slider drags.
Future<void> _makeDirty(WidgetTester tester) async {
  await tester.ensureVisible(_showBorderSwitch);
  await tester.pumpAndSettle();
  await tester.tap(_showBorderSwitch);
  await tester.pumpAndSettle();
}

void main() {
  group('_SaveAction', () {
    testWidgets('is disabled while the state is clean', (tester) async {
      await _pumpScreen(tester);

      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Save'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('enables when dirty; tapping persists and propagates',
        (tester) async {
      final (cubit, repository, holder) = await _pumpScreen(tester);
      await _makeDirty(tester);

      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      final saved = repository.saved;
      expect(saved, isNotNull);
      expect(saved!.wheel.showBorder, isFalse);
      expect(holder.value, saved);
      expect((cubit.state as SettingsLoaded).isDirty, isFalse);
    });
  });

  group('_ResetAction', () {
    testWidgets('tapping resets to dirty defaults without saving',
        (tester) async {
      final (cubit, repository, holder) = await _pumpScreen(tester);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      final state = cubit.state as SettingsLoaded;
      expect(state.settings, const PickerVisualSettings());
      expect(state.isDirty, isTrue);
      expect(repository.saved, isNull);
      expect(holder.value, _kSeed);
    });
  });

  group('_ClearAction', () {
    testWidgets('tapping clears storage and resets the holder',
        (tester) async {
      final (cubit, repository, holder) = await _pumpScreen(tester);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(repository.clearCalls, 1);
      expect(holder.value, const PickerVisualSettings());
      expect(
        cubit.state,
        const SettingsLoaded(settings: PickerVisualSettings()),
      );
    });
  });

  group('_SwitchRow', () {
    testWidgets('toggling showBorder updates the wheel settings',
        (tester) async {
      final (cubit, _, _) = await _pumpScreen(tester);

      await _makeDirty(tester);

      final state = cubit.state as SettingsLoaded;
      expect(state.settings.wheel.showBorder, isFalse);
      expect(state.isDirty, isTrue);
    });
  });

  group('_StateReadout', () {
    testWidgets('shows no unsaved chip while clean', (tester) async {
      await _pumpScreen(tester);
      expect(find.text('unsaved'), findsNothing);
    });

    testWidgets('shows the unsaved chip and current values when dirty',
        (tester) async {
      await _pumpScreen(tester);
      await _makeDirty(tester);

      expect(find.text('unsaved'), findsOneWidget);
      expect(find.text('startingIndex: 3'), findsOneWidget);
      expect(find.text('itemExtent: 24.0'), findsOneWidget);
      expect(find.text('selectionDebounce: 0ms'), findsOneWidget);
    });
  });
}
