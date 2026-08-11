// infinite_scroll_picking_settings/test/src/settings/settings_cubit_test.dart

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
    show SettingsError, SettingsLoaded, SettingsState;

/// Repository recording writes with switchable failure modes.
final class _FakeRepository implements SettingsRepository {
  /// Last settings received by [save]; null when never saved.
  PickerVisualSettings? saved;

  /// Number of [clear] invocations.
  int clearCalls = 0;

  /// When true, [save] throws.
  bool throwOnSave = false;

  /// When true, [clear] throws.
  bool throwOnClear = false;

  @override
  Future<PickerVisualSettings?> load() async => saved;

  @override
  Future<void> save(PickerVisualSettings settings) async {
    if (throwOnSave) throw Exception('disk full');
    saved = settings;
  }

  @override
  Future<void> clear() async {
    if (throwOnClear) throw Exception('store locked');
    clearCalls++;
    saved = null;
  }
}

/// Seed value distinct from defaults so holder mutations are observable.
const _kSeed = PickerVisualSettings(startingIndex: 3);

/// Edited value distinct from both defaults and [_kSeed].
const _kEdited = PickerVisualSettings(startingIndex: 8);

void main() {
  group('SettingsCubit', () {
    late SettingsHolder holder;
    late _FakeRepository repository;
    late SettingsCubit cubit;

    setUp(() {
      holder = SettingsHolder(_kSeed);
      repository = _FakeRepository();
      cubit = SettingsCubit(holder: holder, repository: repository);
    });

    tearDown(() async {
      await cubit.close();
      holder.dispose();
    });

    test('constructs directly into loaded(clean) seeded from the holder',
        () {
      expect(
        cubit.state,
        const SettingsState.loaded(settings: _kSeed),
      );
    });

    group('updateSettings', () {
      test('replaces the working copy and marks it dirty', () {
        cubit.updateSettings(_kEdited);

        expect(
          cubit.state,
          const SettingsState.loaded(settings: _kEdited, isDirty: true),
        );
      });

      test('does not touch the holder — preview only', () {
        cubit.updateSettings(_kEdited);
        expect(holder.value, _kSeed);
      });

      test('asserts when called outside loaded state', () async {
        repository.throwOnSave = true;
        cubit.updateSettings(_kEdited);
        await cubit.save();
        expect(cubit.state, isA<SettingsError>());

        expect(
          () => cubit.updateSettings(_kEdited),
          throwsAssertionError,
        );
      });
    });

    group('save', () {
      test('persists, propagates to the holder, and emits clean',
          () async {
        cubit.updateSettings(_kEdited);

        await cubit.save();

        expect(repository.saved, _kEdited);
        expect(holder.value, _kEdited);
        expect(
          cubit.state,
          const SettingsState.loaded(settings: _kEdited),
        );
      });

      test('on failure emits error and leaves the holder untouched',
          () async {
        repository.throwOnSave = true;
        cubit.updateSettings(_kEdited);

        await cubit.save();

        expect(holder.value, _kSeed);
        expect(
          cubit.state,
          isA<SettingsError>().having(
            (state) => state.message,
            'message',
            contains('Failed to save settings'),
          ),
        );
      });

      test('asserts when called outside loaded state', () async {
        repository.throwOnSave = true;
        cubit.updateSettings(_kEdited);
        await cubit.save();
        expect(cubit.state, isA<SettingsError>());

        expect(cubit.save, throwsAssertionError);
      });
    });

    group('reset', () {
      test('emits defaults dirty without touching storage or holder', () {
        cubit.reset();

        expect(
          cubit.state,
          const SettingsState.loaded(
            settings: PickerVisualSettings(),
            isDirty: true,
          ),
        );
        expect(holder.value, _kSeed);
        expect(repository.saved, isNull);
      });
    });

    group('clearPersisted', () {
      test('clears storage, resets the holder, and emits clean defaults',
          () async {
        await cubit.clearPersisted();

        expect(repository.clearCalls, 1);
        expect(holder.value, const PickerVisualSettings());
        expect(
          cubit.state,
          const SettingsState.loaded(settings: PickerVisualSettings()),
        );
      });

      test('on failure emits error and leaves the holder untouched',
          () async {
        repository.throwOnClear = true;

        await cubit.clearPersisted();

        expect(holder.value, _kSeed);
        expect(
          cubit.state,
          isA<SettingsError>().having(
            (state) => state.message,
            'message',
            contains('Failed to clear settings'),
          ),
        );
      });
    });

    test('SettingsLoaded state exposes isDirty with a false default', () {
      const state = SettingsLoaded(settings: _kSeed);
      expect(state.isDirty, isFalse);
    });
  });
}
