// lib/packages/step_slider_package/step_slider_package.usecase.dart

import 'package:flutter/material.dart';
import 'package:step_slider_package/step_slider_package.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ---------------------------------------------------------------------------
// Default — all defaults, core knobs
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Default', type: StepSlider)
Widget stepSliderDefault(BuildContext context) {
  final min = context.knobs.double.slider(
    label: 'Min',
    initialValue: 0,
    min: -100,
    max: 0,
  );
  final max = context.knobs.double.slider(
    label: 'Max',
    initialValue: 100,
    min: 1,
    max: 500,
  );
  final step = context.knobs.double.slider(
    label: 'Step',
    initialValue: 1,
    min: 0.5,
    max: 25,
  );
  final showLabel = context.knobs.boolean(
    label: 'Show Label',
    initialValue: true,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: StepSlider(
        min: min,
        max: max,
        step: step,
        label: showLabel ? 'Value' : null,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Custom colours
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Custom Colours', type: StepSlider)
Widget stepSliderCustomColours(BuildContext context) {
  final activeColor = context.knobs.color(
    label: 'Active Track',
    initialValue: Colors.deepPurple,
  );
  final inactiveColor = context.knobs.color(
    label: 'Inactive Track',
    initialValue: Colors.deepPurple.shade100,
  );
  final thumbColor = context.knobs.color(
    label: 'Thumb',
    initialValue: Colors.deepPurple.shade700,
  );
  final buttonColor = context.knobs.color(
    label: 'Button',
    initialValue: Colors.deepPurple.shade200,
  );
  final buttonIconColor = context.knobs.color(
    label: 'Button Icon',
    initialValue: Colors.white,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: StepSlider(
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        thumbColor: thumbColor,
        buttonColor: buttonColor,
        buttonIconColor: buttonIconColor,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Step sizes
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Step Sizes', type: StepSlider)
Widget stepSliderStepSizes(BuildContext context) {
  return const Center(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LabelledSlider(label: 'Step 1', child: StepSlider()),
          SizedBox(height: 24),
          _LabelledSlider(
            label: 'Step 5',
            child: StepSlider(step: 5, divisions: 20),
          ),
          SizedBox(height: 24),
          _LabelledSlider(
            label: 'Step 10',
            child: StepSlider(step: 10, divisions: 10),
          ),
          SizedBox(height: 24),
          _LabelledSlider(
            label: 'Step 25',
            child: StepSlider(step: 25, divisions: 4),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Haptic feedback
// ---------------------------------------------------------------------------

const Map<String, HapticFeedbackType> _hapticOptions = {
  'light': HapticFeedbackType.light,
  'medium': HapticFeedbackType.medium,
  'heavy': HapticFeedbackType.heavy,
  'selection': HapticFeedbackType.selection,
  'vibrate': HapticFeedbackType.vibrate,
};

@widgetbook.UseCase(name: 'Haptic Feedback', type: StepSlider)
Widget stepSliderHaptic(BuildContext context) {
  final typeName = context.knobs.object.dropdown<String>(
    label: 'Haptic Type',
    options: _hapticOptions.keys.toList(),
    initialOption: 'light',
  );
  final buttonSize = context.knobs.double.slider(
    label: 'Button Size',
    initialValue: 36,
    min: 24,
    max: 64,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: StepSlider(
        enableHapticFeedback: true,
        hapticFeedbackType: _hapticOptions[typeName]!,
        buttonSize: buttonSize,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Private helper
// ---------------------------------------------------------------------------

class _LabelledSlider extends StatelessWidget {
  const _LabelledSlider({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}
