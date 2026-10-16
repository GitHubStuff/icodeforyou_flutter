// programs/widgetbook_workspace/lib/packages/sliders/hslider_with_buttons.usecase.dart
import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sliders/sliders.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Interactive', type: HSliderWithButtons)
Widget buildHSliderWithButtonsInteractiveUseCase(BuildContext context) {
  final enabled = context.knobs.boolean(
    label: 'Enabled',
    initialValue: true,
  );
  final min = context.knobs.double.input(label: 'min', initialValue: 0);
  final rawMax = context.knobs.double.input(label: 'max', initialValue: 10);
  final step = context.knobs.double.input(label: 'step', initialValue: 1);
  final initialValue = context.knobs.doubleOrNull.input(
    label: 'initialValue (null = midpoint)',
  );
  final divisions = context.knobs.intOrNull.slider(
    label: 'divisions (null = continuous)',
    min: 1,
    max: 20,
  );
  final color = context.knobs.colorOrNull(label: 'color');
  final haptic = context.knobs.object.dropdown<HapticIntensity>(
    label: 'haptic',
    options: HapticIntensity.values,
    initialOption: .light,
    labelBuilder: (haptic) => haptic.name,
  );

  // The widget asserts `min < max` and `step > 0`; keep the knobs from
  // ever violating either.
  final max = rawMax > min ? rawMax : min + 1;
  final safeStep = step > 0 ? step : 1.0;

  return _HSliderWithButtonsHarness(
    // The widget reads `initialValue` once, when its state is created.
    // Keying on it remounts the widget whenever the knob changes, so the
    // knob is not silently ignored.
    key: ValueKey(initialValue),
    enabled: enabled,
    min: min,
    max: max,
    step: safeStep,
    initialValue: initialValue,
    divisions: divisions,
    color: color,
    haptic: haptic,
  );
}

/// Hosts an [HSliderWithButtons] and echoes the last value it reported.
///
/// The widget under test owns its value, so the only way to observe it
/// from outside is through `onChanged`; this harness shows what the
/// parent would receive.
class _HSliderWithButtonsHarness extends StatefulWidget {
  const _HSliderWithButtonsHarness({
    required this.enabled,
    required this.min,
    required this.max,
    required this.step,
    required this.initialValue,
    required this.divisions,
    required this.color,
    required this.haptic,
    super.key,
  });

  final bool enabled;
  final double min;
  final double max;
  final double step;
  final double? initialValue;
  final int? divisions;
  final Color? color;
  final HapticIntensity haptic;

  @override
  State<_HSliderWithButtonsHarness> createState() =>
      _HSliderWithButtonsHarnessState();
}

class _HSliderWithButtonsHarnessState
    extends State<_HSliderWithButtonsHarness> {
  double? _reported;

  void _onChanged(double value) => setState(() => _reported = value);

  @override
  Widget build(BuildContext context) {
    final reported = _reported;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HSliderWithButtons(
            min: widget.min,
            max: widget.max,
            step: widget.step,
            initialValue: widget.initialValue,
            divisions: widget.divisions,
            color: widget.color,
            haptic: widget.haptic,
            onChanged: widget.enabled ? _onChanged : null,
          ),
          const Gap(8),
          Text(
            reported == null
                ? 'onChanged: (not yet called)'
                : 'onChanged: ${reported.toStringAsFixed(4)}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
