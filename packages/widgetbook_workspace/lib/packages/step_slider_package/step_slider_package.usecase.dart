// lib/step_slider_package/step_slider.usecase.dart
import 'package:flutter/material.dart';
import 'package:step_slider_package/step_slider_package.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: StepSlider)
Widget buildStepSliderDefault(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: StepSlider(
          initialValue: context.knobs.double.slider(
            label: 'Initial Value',
            initialValue: 50,
            min: 0,
            max: 100,
          ),
          min: context.knobs.double.input(label: 'Min', initialValue: 0),
          max: context.knobs.double.input(label: 'Max', initialValue: 100),
          step: context.knobs.double.input(label: 'Step', initialValue: 1),
          divisions: context.knobs.intOrNull.input(
            label: 'Divisions',
            initialValue: null,
          ),
          buttonSize: context.knobs.double.slider(
            label: 'Button Size',
            initialValue: 36,
            min: 24,
            max: 56,
          ),
          enableHapticFeedback: context.knobs.boolean(
            label: 'Enable Haptic Feedback',
            initialValue: false,
          ),
          hapticFeedbackType: context.knobs.list(
            label: 'Haptic Type',
            options: HapticFeedbackType.values,
            initialOption: HapticFeedbackType.light,
            labelBuilder: (type) => type.name,
          ),
          onChanged: (value) => debugPrint('Value: $value'),
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'With Custom Colors', type: StepSlider)
Widget buildStepSliderCustomColors(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: StepSlider(
          initialValue: 50,
          max: 100,
          step: 5,
          activeColor: context.knobs.color(
            label: 'Active Color',
            initialValue: Colors.purple,
          ),
          inactiveColor: context.knobs.color(
            label: 'Inactive Color',
            initialValue: Colors.purple.shade100,
          ),
          thumbColor: context.knobs.color(
            label: 'Thumb Color',
            initialValue: Colors.deepPurple,
          ),
          buttonColor: context.knobs.color(
            label: 'Button Color',
            initialValue: Colors.purple,
          ),
          buttonIconColor: context.knobs.color(
            label: 'Button Icon Color',
            initialValue: Colors.white,
          ),
          onChanged: (value) => debugPrint('Value: $value'),
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Discrete Steps', type: StepSlider)
Widget buildStepSliderDiscrete(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: StepSlider(
          initialValue: 0,
          min: 0,
          max: 10,
          step: 1,
          divisions: 10,
          enableHapticFeedback: context.knobs.boolean(
            label: 'Enable Haptic Feedback',
            initialValue: true,
          ),
          hapticFeedbackType: HapticFeedbackType.selection,
          onChanged: (value) => debugPrint('Step: ${value.round()}'),
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Decimal Precision', type: StepSlider)
Widget buildStepSliderDecimal(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: StepSlider(
          initialValue: 1.0,
          min: 0.5,
          max: 3.0,
          step: 0.1,
          divisions: 25,
          label: 'Zoom',
          onChanged: (value) =>
              debugPrint('Zoom: ${value.toStringAsFixed(1)}x'),
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Multiple Sliders', type: StepSlider)
Widget buildStepSliderMultiple(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLabeledSlider(
            label: 'Volume',
            child: const StepSlider(
              initialValue: 75,
              max: 100,
              step: 5,
              enableHapticFeedback: true,
              hapticFeedbackType: HapticFeedbackType.light,
            ),
          ),
          const SizedBox(height: 24),
          _buildLabeledSlider(
            label: 'Brightness',
            child: const StepSlider(
              initialValue: 50,
              max: 100,
              step: 10,
              enableHapticFeedback: true,
              hapticFeedbackType: HapticFeedbackType.medium,
            ),
          ),
          const SizedBox(height: 24),
          _buildLabeledSlider(
            label: 'Contrast',
            child: const StepSlider(initialValue: 50, max: 100, step: 5),
          ),
          const SizedBox(height: 24),
          _buildLabeledSlider(
            label: 'Saturation',
            child: const StepSlider(initialValue: 50, max: 100, step: 5),
          ),
        ],
      ),
    ),
  );
}

Widget _buildLabeledSlider({required String label, required Widget child}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 48.0, bottom: 4.0),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      child,
    ],
  );
}

@widgetbook.UseCase(name: 'Haptic Feedback Comparison', type: StepSlider)
Widget buildStepSliderHapticComparison(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final type in HapticFeedbackType.values) ...[
            _buildLabeledSlider(
              label: 'Haptic: ${type.name}',
              child: StepSlider(
                initialValue: 50,
                max: 100,
                step: 10,
                enableHapticFeedback: true,
                hapticFeedbackType: type,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    ),
  );
}
