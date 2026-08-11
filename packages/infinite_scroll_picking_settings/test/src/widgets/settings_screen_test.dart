// infinite_scroll_picking_settings/test/src/widgets/settings_screen_test.dart

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
    show SettingsState;
import 'package:infinite_scroll_picking_settings/src/widgets/settings_screen.dart'
    show SettingsScreen;

/// No-op repository — screen-arm tests never persist.
final class _FakeRepository implements SettingsRepository {
  @override
  Future<PickerVisualSettings?> load() async => null;

  @override
  Future<void> save(PickerVisualSettings settings) async {}

  @override
  Future<void> clear() async {}
}

/// Cubit exposing [force] so tests can reach the defensive
/// initial/loading/error arms the real lifecycle never enters.
///
/// [force] must be called *before* the screen is pumped: the first
/// build reads `state` synchronously, making the target arm render on
/// the first frame with no dependence on stream-delivery timing.
final class _StageableSettingsCubit extends SettingsCubit {
  /// Creates a stageable cubit over [holder] and [repository].
  _StageableSettingsCubit({
    required super.holder,
    required SettingsRepository repository,
  }) : super(repository: repository);

  /// Forces the cubit into [state] regardless of lifecycle rules.
  void force(SettingsState state) => emit(state);
}

/// Pumps a [SettingsScreen] over [cubit] on a tall test surface.
///
/// [settle] must be `false` for the initial/loading arms — their
/// [CircularProgressIndicator] is an indeterminate animation that
/// repeats forever, so `pumpAndSettle` would time out.
Future<void> _pumpScreen(
  WidgetTester tester,
  SettingsCubit cubit, {
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<SettingsCubit>.value(
        value: cubit,
        child: const SettingsScreen(),
      ),
    ),
  );
  if (settle) await tester.pumpAndSettle();
}

void main() {
  group('SettingsScreen', () {
    late SettingsHolder holder;
    late _StageableSettingsCubit cubit;

    setUp(() {
      holder = SettingsHolder(const PickerVisualSettings());
      cubit = _StageableSettingsCubit(
        holder: holder,
        repository: _FakeRepository(),
      );
    });

    tearDown(() async {
      await cubit.close();
      holder.dispose();
    });

    testWidgets('loaded state renders preview, all sections, and readout', (
      tester,
    ) async {
      await _pumpScreen(tester, cubit);

      expect(find.text('Picker Settings'), findsOneWidget);
      expect(
        find.byType(InfiniteScrollPicker<int, String>),
        findsOneWidget,
      );
      expect(find.text('FRAME'), findsOneWidget);
      expect(find.text('WHEEL — DIMENSIONS'), findsOneWidget);
      expect(find.text('WHEEL — SELECTION BAND'), findsOneWidget);
      expect(find.text('WHEEL — PERSPECTIVE & MOTION'), findsOneWidget);
      expect(find.text('PICKER'), findsOneWidget);
      expect(find.text('Current settings'), findsOneWidget);
    });

    testWidgets('initial state shows the defensive progress indicator', (
      tester,
    ) async {
      cubit.force(const SettingsState.initial());

      await _pumpScreen(tester, cubit, settle: false);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('loading state shows the defensive progress indicator', (
      tester,
    ) async {
      cubit.force(const SettingsState.loading());

      await _pumpScreen(tester, cubit, settle: false);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('error state shows the message in the error color', (
      tester,
    ) async {
      cubit.force(const SettingsState.error(message: 'save exploded'));

      await _pumpScreen(tester, cubit, settle: false);
      await tester.pump();

      final text = tester.widget<Text>(find.text('save exploded'));
      final context = tester.element(find.text('save exploded'));
      expect(text.style?.color, Theme.of(context).colorScheme.error);
    });
  });
}
