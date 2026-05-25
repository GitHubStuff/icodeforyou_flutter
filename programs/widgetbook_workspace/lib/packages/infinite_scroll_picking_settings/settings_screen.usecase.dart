// widgetbook_workspace/lib/packages/infinite_scroll_picking_settings/settings_screen.usecase.dart

// Not needed for widget-demo
// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_picking_settings/infinite_scroll_picking_settings.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ── Pre-seeded values ────────────────────────────────────────────────────────

const _kChunkySeed = PickerVisualSettings(
  wheel: WheelSettings(
    itemExtent: 36,
    wheelWidth: 80,
    wheelHeight: 120,
    magnification: 1.5,
    perspectiveDiameter: 1.4,
    wheelBorderRadius: 16,
    dividerThickness: 2,
    dividerInset: 8,
  ),
  startingIndex: 25,
  frameBorderRadius: 16,
  frameHorizontalPadding: 20,
  frameVerticalPadding: 12,
);

const _kCompactSeed = PickerVisualSettings(
  wheel: WheelSettings(
    itemExtent: 16,
    wheelWidth: 32,
    wheelHeight: 28,
    magnification: 1.1,
    showBorder: false,
    dividerThickness: 0.5,
  ),
  startingIndex: 7,
  frameBorderRadius: 4,
  frameHorizontalPadding: 8,
  frameVerticalPadding: 4,
);

// ── Fakes ────────────────────────────────────────────────────────────────────

/// In-memory fake. `load()` returns whatever was last saved (or [_seed] if
/// nothing). `save()` mutates an internal slot. `clear()` drops it.
class _InMemoryRepository implements SettingsRepository {
  _InMemoryRepository(this._seed);

  final PickerVisualSettings _seed;
  PickerVisualSettings? _stored;

  @override
  Future<PickerVisualSettings?> load() async => _stored ?? _seed;

  @override
  Future<void> save(PickerVisualSettings settings) async {
    _stored = settings;
  }

  @override
  Future<void> clear() async {
    _stored = null;
  }
}

/// Always throws — exercises the error path.
class _ThrowingRepository implements SettingsRepository {
  @override
  Future<PickerVisualSettings?> load() async {
    throw Exception('simulated load failure');
  }

  @override
  Future<void> save(PickerVisualSettings settings) async {
    throw Exception('simulated save failure');
  }

  @override
  Future<void> clear() async {
    throw Exception('simulated clear failure');
  }
}

/// Hangs forever — keeps the cubit in `loading`.
class _HangingRepository implements SettingsRepository {
  @override
  Future<PickerVisualSettings?> load() {
    final c = Completer<PickerVisualSettings?>();
    return c.future;
  }

  @override
  Future<void> save(PickerVisualSettings settings) async {}

  @override
  Future<void> clear() async {}
}

// ── Knob enums ───────────────────────────────────────────────────────────────

enum _StateVariant {
  loaded('Loaded'),
  loading('Loading'),
  error('Error')
  ;

  const _StateVariant(this.label);
  final String label;
}

enum _Seed {
  chunky('Chunky'),
  compact('Compact'),
  defaults('Defaults')
  ;

  const _Seed(this.label);
  final String label;
}

// ── Usecase ──────────────────────────────────────────────────────────────────

@widgetbook.UseCase(name: 'Default', type: SettingsScreen)
Widget settingsScreenUseCase(BuildContext context) {
  final variant = context.knobs.object.dropdown<_StateVariant>(
    label: 'State variant',
    options: _StateVariant.values,
    initialOption: _StateVariant.loaded,
    labelBuilder: (v) => v.label,
  );

  final seed = context.knobs.object.dropdown<_Seed>(
    label: 'Seed (Loaded only)',
    options: _Seed.values,
    initialOption: _Seed.chunky,
    labelBuilder: (v) => v.label,
  );

  final seeded = switch (seed) {
    _Seed.chunky => _kChunkySeed,
    _Seed.compact => _kCompactSeed,
    _Seed.defaults => const PickerVisualSettings(),
  };

  final SettingsRepository repository = switch (variant) {
    _StateVariant.loaded => _InMemoryRepository(seeded),
    _StateVariant.loading => _HangingRepository(),
    _StateVariant.error => _ThrowingRepository(),
  };

  return BlocProvider<SettingsCubit>(
    // ValueKey forces BlocProvider to rebuild the cubit when the user
    // switches knob values, so the new repository actually takes effect.
    key: ValueKey('${variant.name}-${seed.name}'),
    create: (_) => SettingsCubit(
      repository: repository,
      holder: SettingsHolder(seeded),
    ),
    child: const SettingsScreen(),
  );
}
