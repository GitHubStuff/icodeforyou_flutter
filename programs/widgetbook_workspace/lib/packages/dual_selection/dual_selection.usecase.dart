// programs/widgetbook_workspace/lib/packages/dual_selection/dual_selection.usecase.dart
// (placeholder path — use your actual usecase location)

import 'package:dual_selection/dual_selection.dart'
    show Defaults, DualSelection, DualSelectionEnum;
import 'package:flutter/material.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Interactive', type: DualSelection)
Widget buildDualSelectionInteractiveUseCase(BuildContext context) {
  final knobs = context.knobs;
  final colorScheme = Theme.of(context).colorScheme;

  // Null means "follow the active theme"; a picked value overrides it.
  // These must stay `colorOrNull` — a `color` knob with a concrete
  // initialValue freezes on first build and stops tracking theme changes.
  final borderColor =
      knobs.colorOrNull(label: 'borderColor') ?? colorScheme.outline;
  final selectedHeaderColor =
      knobs.colorOrNull(label: 'selectedHeaderColor') ??
      colorScheme.primaryContainer;
  final unselectedHeaderColor =
      knobs.colorOrNull(label: 'unselectedHeaderColor') ??
      colorScheme.surfaceContainerHighest;
  final headerTextColor =
      knobs.colorOrNull(label: 'headerTextColor') ?? colorScheme.onSurface;

  return Center(
    child: DualSelection(
      first: _HeaderLabel('First', color: headerTextColor),
      second: _HeaderLabel('Second', color: headerTextColor),
      firstChild: const _Body(label: 'First body', color: Colors.blue),
      secondChild: const _Body(label: 'Second body', color: Colors.orange),
      borderColor: borderColor,
      selectedHeaderColor: selectedHeaderColor,
      unselectedHeaderColor: unselectedHeaderColor,
      selection: knobs.object.dropdown<DualSelectionEnum>(
        label: 'selection',
        options: DualSelectionEnum.values,
        initialOption: Defaults.kFirstSelection,
        labelBuilder: (option) => option.name,
      ),
      fadeDuration: Duration(
        milliseconds: knobs.int.slider(
          label: 'fadeDuration (ms)',
          initialValue: Defaults.kFadeDuration.inMilliseconds,
          min: 0,
          max: 2000,
        ),
      ),
      cornerRadius: knobs.double.slider(
        label: 'cornerRadius',
        initialValue: Defaults.kCornerRadius,
        min: 0,
        max: 40,
      ),
      haptic: knobs.object.dropdown<HapticIntensity>(
        label: 'haptic',
        options: HapticIntensity.values,
        initialOption: Defaults.kHaptic,
        labelBuilder: (option) => option.name,
      ),
      borderWidth: knobs.double.slider(
        label: 'borderWidth',
        initialValue: Defaults.kBorderWidth,
        min: 0,
        max: 12,
      ),
      headerHeight: knobs.double.slider(
        label: 'headerHeight',
        initialValue: Defaults.kHeaderHeight,
        min: 24,
        max: 120,
      ),
      bodyHeight: knobs.double.slider(
        label: 'bodyHeight',
        initialValue: Defaults.kBodyHeight,
        min: 60,
        max: 500,
      ),
      width: knobs.double.slider(
        label: 'width',
        initialValue: Defaults.kWidth,
        min: 120,
        max: 400,
      ),
      onSelectionChanged: (selection) =>
          debugPrint('onSelectionChanged: ${selection.name}'),
    ),
  );
}

/// Header slot content: foreground only. The background is painted by
/// [DualSelection] from `selectedHeaderColor` / `unselectedHeaderColor`,
/// so this must not paint its own.
class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel(this.label, {required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
