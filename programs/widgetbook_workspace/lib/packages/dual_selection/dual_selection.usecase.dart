// programs/widgetbook_workspace/lib/packages/dual_selection/dual_selection.usecase.dart

import 'package:dual_selection/dual_selection.dart'
    show DualSelection, DualSelectionEnum;
import 'package:dual_selection/src/defaults.dart' show Defaults;
//import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Interactive', type: DualSelection)
Widget buildDualSelectionInteractiveUseCase(BuildContext context) {
  final knobs = context.knobs;

  return Center(
    child: DualSelection(
      first: const _HeaderButton(label: 'First'),
      second: const _HeaderButton(label: 'Second'),
      firstChild: const _Body(label: 'First body', color: Colors.blue),
      secondChild: const _Body(label: 'Second body', color: Colors.orange),
      borderColor: knobs.color(
        label: 'borderColor',
        initialValue: Colors.black,
      ),
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

@UseCase(name: 'Seeded With Second', type: DualSelection)
Widget buildDualSelectionSeededWithSecondUseCase(BuildContext context) {
  return const Center(
    child: DualSelection(
      first: _HeaderButton(label: 'First'),
      second: _HeaderButton(label: 'Second'),
      firstChild: _Body(label: 'First body', color: Colors.blue),
      secondChild: _Body(label: 'Second body', color: Colors.orange),
      borderColor: Colors.black,
      selection: .second,
    ),
  );
}

@UseCase(name: 'No Fade', type: DualSelection)
Widget buildDualSelectionNoFadeUseCase(BuildContext context) {
  return const Center(
    child: DualSelection(
      first: _HeaderButton(label: 'First'),
      second: _HeaderButton(label: 'Second'),
      firstChild: _Body(label: 'First body', color: Colors.blue),
      secondChild: _Body(label: 'Second body', color: Colors.orange),
      borderColor: Colors.black,
      fadeDuration: Duration.zero,
    ),
  );
}

@UseCase(name: 'Square Corners, No Border', type: DualSelection)
Widget buildDualSelectionSquareNoBorderUseCase(BuildContext context) {
  return const Center(
    child: DualSelection(
      first: _HeaderButton(label: 'First'),
      second: _HeaderButton(label: 'Second'),
      firstChild: _Body(label: 'First body', color: Colors.blue),
      secondChild: _Body(label: 'Second body', color: Colors.orange),
      borderColor: Colors.transparent,
      cornerRadius: 0,
      borderWidth: 0,
    ),
  );
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade300,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
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
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
