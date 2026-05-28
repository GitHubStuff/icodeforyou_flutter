// programs/widgetbook_workspace/lib/packages/custom_widgets/directional_slider/directional_slider_and_buttons.usecase.dart
import 'package:custom_widgets/src/directional_slider/slider/directional_controller.dart';
import 'package:custom_widgets/src/directional_slider/slider/directional_slider.dart';
import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:extensions/placement/placement.dart' show Placement;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: DirectionalSlider)
Widget directionalSliderDefault(BuildContext context) {
  final axis = context.knobs.object.dropdown<Axis>(
    label: 'rotation',
    options: Axis.values,
    initialOption: Axis.horizontal,
    labelBuilder: (a) => a.name,
  );

  final minValueFirst = context.knobs.boolean(
    label: 'minValueFirst',
    initialValue: true,
  );

  final placement = context.knobs.object.dropdown<Placement>(
    label: 'placement',
    options: Placement.values,
    initialOption: Placement.bottom,
    labelBuilder: (p) => p.name,
  );

  final min = context.knobs.double.slider(
    label: 'min',
    initialValue: 0,
    min: -100,
    max: 100,
    divisions: 200,
  );

  final max = context.knobs.double.slider(
    label: 'max',
    initialValue: 10,
    min: -100,
    max: 100,
    divisions: 200,
  );

  final step = context.knobs.double.slider(
    label: 'step',
    initialValue: 1,
    min: 0.1,
    max: 10,
    divisions: 99,
  );

  final initial = context.knobs.double.slider(
    label: 'initial value',
    initialValue: 0,
    min: -100,
    max: 100,
    divisions: 200,
  );

  final label = context.knobs.stringOrNull(
    label: 'label',
    initialValue: null,
  );

  final activeColor = context.knobs.colorOrNull(
    label: 'activeColor',
    initialValue: null,
  );

  final inactiveColor = context.knobs.colorOrNull(
    label: 'inactiveColor',
    initialValue: null,
  );

  final thumbColor = context.knobs.colorOrNull(
    label: 'thumbColor',
    initialValue: null,
  );

  final enableHapticFeedback = context.knobs.boolean(
    label: 'enableHapticFeedback',
    initialValue: false,
  );

  final hapticIntensity = context.knobs.object.dropdown<HapticIntensity>(
    label: 'hapticIntensity',
    options: HapticIntensity.values,
    initialOption: HapticIntensity.selection,
    labelBuilder: (h) => h.name,
  );

  // Guard against invalid step-grid configurations the knobs can produce.
  // StepGrid asserts (max-min) is an integer multiple of step; show a hint
  // instead of crashing the usecase.
  if (min >= max) {
    return const _InvalidGridHint(
      message: 'min must be less than max',
    );
  }
  final span = ((max - min) * 1000).round();
  final stepScaled = (step * 1000).round();
  if (stepScaled <= 0 || span % stepScaled != 0) {
    return _InvalidGridHint(
      message:
          'step ($step) must evenly divide (max − min) = ${(max - min).toStringAsFixed(3)}',
    );
  }

  return _DirectionalSliderHost(
    initial: initial.clamp(min, max).toDouble(),
    builder: (controller) => Padding(
      padding: const EdgeInsets.all(24),
      child: DirectionalSlider(
        controller: controller,
        rotation: axis,
        min: min,
        max: max,
        step: step,
        minValueFirst: minValueFirst,
        placement: placement,
        label: label,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        thumbColor: thumbColor,
        enableHapticFeedback: enableHapticFeedback,
        hapticIntensity: hapticIntensity,
      ),
    ),
  );
}

/// Owns the [DirectionalController] lifecycle for the usecase. Widgetbook
/// usecase builders are stateless functions, so the controller must live in
/// a wrapper to be disposed correctly.
class _DirectionalSliderHost extends StatefulWidget {
  const _DirectionalSliderHost({
    required this.initial,
    required this.builder,
  });

  final double initial;
  final Widget Function(DirectionalController controller) builder;

  @override
  State<_DirectionalSliderHost> createState() => _DirectionalSliderHostState();
}

class _DirectionalSliderHostState extends State<_DirectionalSliderHost> {
  late final DirectionalController _controller = DirectionalController(
    initial: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_controller);
}

class _InvalidGridHint extends StatelessWidget {
  const _InvalidGridHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}
