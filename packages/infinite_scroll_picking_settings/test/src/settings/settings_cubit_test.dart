// infinite_scroll_picking_settings/test/src/settings/settings_cubit_test.dart

// ignore_for_file: invalid_use_of_visible_for_testing_member,
// invalid_use_of_protected_member

import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/infinite_scroll_picking_settings.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements SettingsRepository {}

class _RepoFails implements SettingsRepository {
  _RepoFails({this.onSave, this.onClear});

  final Exception? onSave;
  final Exception? onClear;

  @override
  Future<PickerVisualSettings?> load() async => null;

  @override
  Future<void> save(PickerVisualSettings settings) async {
    if (onSave != null) throw onSave!;
  }

  @override
  Future<void> clear() async {
    if (onClear != null) throw onClear!;
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(const PickerVisualSettings());
  });

  group('SettingsCubit', () {
    late _MockRepo repo;
    late SettingsHolder holder;

    const initial = PickerVisualSettings(startingIndex: 2);
    const edited = PickerVisualSettings(startingIndex: 5);
    const defaults = PickerVisualSettings();

    setUp(() {
      repo = _MockRepo();
      holder = SettingsHolder(initial);
    });

    SettingsCubit build() => SettingsCubit(holder: holder, repository: repo);

    group('construction', () {
      test('emits loaded(holder.value, clean) immediately', () {
        final cubit = build();
        expect(
          cubit.state,
          const SettingsState.loaded(settings: initial),
        );
        addTearDown(cubit.close);
      });
    });

    group('updateSettings', () {
      test('emits loaded(working, dirty) without touching the holder', () {
        final cubit = build();
        addTearDown(cubit.close);

        cubit.updateSettings(edited);

        expect(
          cubit.state,
          const SettingsState.loaded(settings: edited, isDirty: true),
        );
        expect(holder.value, initial);
      });

      test('asserts and no-ops when called from a non-loaded state', () {
        final cubit = build();
        addTearDown(cubit.close);
        cubit.emit(const SettingsState.error(message: 'broken'));

        expect(
          () => cubit.updateSettings(edited),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('save', () {
      test('writes through, updates holder, emits loaded(clean)', () async {
        when(() => repo.save(any())).thenAnswer((_) async {});
        final cubit = build();
        addTearDown(cubit.close);

        cubit.updateSettings(edited);
        await cubit.save();

        expect(
          cubit.state,
          const SettingsState.loaded(settings: edited),
        );
        expect(holder.value, edited);
        verify(() => repo.save(edited)).called(1);
      });

      test(
        'emits error and leaves holder untouched when the repo throws',
        () async {
          final cubit = SettingsCubit(
            holder: holder,
            repository: _RepoFails(onSave: Exception('disk full')),
          );
          addTearDown(cubit.close);

          cubit.updateSettings(edited);
          await cubit.save();

          expect(cubit.state, isA<SettingsError>());
          final state = cubit.state as SettingsError;
          expect(state.message, contains('Failed to save settings'));
          expect(state.message, contains('disk full'));
          expect(holder.value, initial);
        },
      );

      test('asserts and no-ops when called from a non-loaded state', () async {
        final cubit = build();
        addTearDown(cubit.close);
        cubit.emit(const SettingsState.error(message: 'broken'));

        expect(cubit.save, throwsA(isA<AssertionError>()));
        verifyNever(() => repo.save(any()));
      });
    });

    group('reset', () {
      test('emits loaded(defaults, dirty) without touching storage or holder',
          () {
        final cubit = build();
        addTearDown(cubit.close);

        cubit.reset();

        expect(
          cubit.state,
          const SettingsState.loaded(settings: defaults, isDirty: true),
        );
        expect(holder.value, initial);
        verifyNever(() => repo.save(any()));
        verifyNever(() => repo.clear());
      });
    });

    group('clearPersisted', () {
      test(
        'clears storage, resets holder to defaults, emits loaded(defaults)',
        () async {
          when(() => repo.clear()).thenAnswer((_) async {});
          final cubit = build();
          addTearDown(cubit.close);

          await cubit.clearPersisted();

          expect(
            cubit.state,
            const SettingsState.loaded(settings: defaults),
          );
          expect(holder.value, defaults);
          verify(() => repo.clear()).called(1);
        },
      );

      test(
        'emits error and leaves holder untouched when the repo throws',
        () async {
          final cubit = SettingsCubit(
            holder: holder,
            repository: _RepoFails(onClear: Exception('lock held')),
          );
          addTearDown(cubit.close);

          await cubit.clearPersisted();

          expect(cubit.state, isA<SettingsError>());
          final state = cubit.state as SettingsError;
          expect(state.message, contains('Failed to clear settings'));
          expect(state.message, contains('lock held'));
          expect(holder.value, initial);
        },
      );
    });
  });
}
