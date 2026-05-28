// programs/widgetbook_workspace/lib/packages/custom_widgets/directional_slider/directional_slider_and_buttons.usecase.dart
import 'package:custom_widgets/src/directional_slider/buttons/directional_slider_and_buttons.dart';
import 'package:custom_widgets/src/directional_slider/slider/directional_controller.dart';
import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: DirectionalSliderAndButtons)
Widget directionalSliderAndButtonsDefault(BuildContext context) {
  final axis = context.knobs.object.dropdown<Axis>(
    label: 'axis',
    options: Axis.values,
    initialOption: Axis.horizontal,
    labelBuilder: (a) => a.name,
  );

  final minValueFirst = context.knobs.boolean(
    label: 'minValueFirst',
    initialValue: true,
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

  final gap = context.knobs.double.slider(
    label: 'gap',
    initialValue: 8,
    min: 0,
    max: 48,
    divisions: 48,
  );

  final buttonSize = context.knobs.doubleOrNull.slider(
    label: 'buttonSize',
    initialValue: null,
    min: 16,
    max: 96,
    divisions: 80,
  );

  final iconOptions = <String, IconData>{
    'remove': Icons.remove,
    'add': Icons.add,
    'arrow_downward': Icons.arrow_downward,
    'arrow_upward': Icons.arrow_upward,
    'chevron_left': Icons.chevron_left,
    'chevron_right': Icons.chevron_right,
  };

  final minusIconKey = context.knobs.object.dropdown<String>(
    label: 'minusIcon',
    options: iconOptions.keys.toList(),
    initialOption: 'remove',
  );

  final plusIconKey = context.knobs.object.dropdown<String>(
    label: 'plusIcon',
    options: iconOptions.keys.toList(),
    initialOption: 'add',
  );

  final haptics = context.knobs.object.dropdown<HapticIntensity>(
    label: 'haptics',
    options: HapticIntensity.values,
    initialOption: HapticIntensity.selection,
    labelBuilder: (h) => h.name,
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

  final buttonColor = context.knobs.colorOrNull(
    label: 'buttonColor',
    initialValue: null,
  );

  final buttonIconColor = context.knobs.colorOrNull(
    label: 'buttonIconColor',
    initialValue: null,
  );

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

  return _DirectionalSliderAndButtonsHost(
    initial: initial.clamp(min, max).toDouble(),
    builder: (controller) => Padding(
      padding: const EdgeInsets.all(24),
      child: DirectionalSliderAndButtons(
        controller: controller,
        min: min,
        max: max,
        step: step,
        axis: axis,
        minValueFirst: minValueFirst,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        thumbColor: thumbColor,
        buttonColor: buttonColor,
        buttonIconColor: buttonIconColor,
        buttonSize: buttonSize,
        gap: gap,
        minusIcon: iconOptions[minusIconKey]!,
        plusIcon: iconOptions[plusIconKey]!,
        haptics: haptics,
      ),
    ),
  );
}

/// Owns the [DirectionalController] lifecycle for the usecase.
class _DirectionalSliderAndButtonsHost extends StatefulWidget {
  const _DirectionalSliderAndButtonsHost({
    required this.initial,
    required this.builder,
  });

  final double initial;
  final Widget Function(DirectionalController controller) builder;

  @override
  State<_DirectionalSliderAndButtonsHost> createState() =>
      _DirectionalSliderAndButtonsHostState();
}

class _DirectionalSliderAndButtonsHostState
    extends State<_DirectionalSliderAndButtonsHost> {
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
