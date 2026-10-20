// programs/widgetbook_workspace/lib/sliders/hslider_with_buttons.usecase.dart
import 'package:flutter/material.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;
import 'package:sliders/sliders.dart' show HSliderWithButtons;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

/// Knob-driven [HSliderWithButtons] with a live readout of `onChanged`.
///
/// The widget is uncontrolled and reads `initialValue` once, so the
/// `Initial value` knob is also used as the widget's [Key]: changing it
/// remounts the widget, which is the documented way to reset the value.
/// Changing `Min` or `Max` does *not* remount, so the clamp-on-range-change
/// behaviour can be observed directly.
@UseCase(name: 'Interactive', type: HSliderWithButtons)
Widget buildHSliderWithButtonsInteractive(BuildContext context) {
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  final min = context.knobs.double.input(label: 'Min', initialValue: 0);
  final max = context.knobs.double.input(label: 'Max', initialValue: 10);
  final step = context.knobs.double.input(label: 'Step', initialValue: 1);
  final initialValue = context.knobs.doubleOrNull.input(
    label: 'Initial value',
    initialValue: 5,
  );
  final divisions = context.knobs.intOrNull.slider(
    label: 'Divisions',
    initialValue: 10,
    min: 1,
    max: 50,
  );
  final color = context.knobs.colorOrNull(label: 'Color');
  final haptic = context.knobs.object.dropdown<HapticIntensity>(
    label: 'Haptic',
    options: HapticIntensity.values,
    initialOption: .light,
    labelBuilder: (haptic) => haptic.name,
  );
  final trackHeight = context.knobs.doubleOrNull.slider(
    label: 'Track height (sliderThemeData)',
    min: 1,
    max: 24,
  );

  if (min >= max) {
    return const Center(child: Text('Min must be less than Max.'));
  }
  if (step <= 0) {
    return const Center(child: Text('Step must be positive.'));
  }

  return _Readout(
    builder: (onChanged) => HSliderWithButtons(
      key: ValueKey(initialValue),
      step: step,
      initialValue: initialValue,
      min: min,
      max: max,
      divisions: divisions,
      color: color,
      haptic: haptic,
      sliderThemeData: trackHeight == null
          ? null
          : SliderThemeData(trackHeight: trackHeight),
      onChanged: enabled ? onChanged : null,
    ),
  );
}

/// The common configurations of [HSliderWithButtons] side by side.
@UseCase(name: 'Gallery', type: HSliderWithButtons)
Widget buildHSliderWithButtonsGallery(BuildContext context) {
  return _Gallery(
    rows: [
      (
        'Continuous, step 1',
        _Readout(
          builder: (onChanged) => HSliderWithButtons(
            step: 1,
            max: 10,
            onChanged: onChanged,
          ),
        ),
      ),
      (
        'Discrete, step 1',
        _Readout(
          builder: (onChanged) => HSliderWithButtons(
            step: 1,
            max: 10,
            divisions: 10,
            onChanged: onChanged,
          ),
        ),
      ),
      (
        'Coarse drag, fine step',
        _Readout(
          builder: (onChanged) => HSliderWithButtons(
            step: 0.25,
            max: 10,
            divisions: 5,
            onChanged: onChanged,
          ),
        ),
      ),
      (
        'Tinted',
        _Readout(
          builder: (onChanged) => HSliderWithButtons(
            step: 1,
            max: 10,
            color: Colors.deepOrange,
            onChanged: onChanged,
          ),
        ),
      ),
      (
        'Starts at min',
        _Readout(
          builder: (onChanged) => HSliderWithButtons(
            step: 1,
            max: 10,
            initialValue: 0,
            onChanged: onChanged,
          ),
        ),
      ),
      (
        'Starts at max',
        _Readout(
          builder: (onChanged) => HSliderWithButtons(
            step: 1,
            max: 10,
            initialValue: 10,
            onChanged: onChanged,
          ),
        ),
      ),
      (
        'Disabled',
        const HSliderWithButtons(step: 1, max: 10, initialValue: 4),
      ),
    ],
  );
}

/// Hosts an uncontrolled slider and prints the last value it reported.
class _Readout extends StatefulWidget {
  const _Readout({required this.builder});

  final Widget Function(ValueChanged<double> onChanged) builder;

  @override
  State<_Readout> createState() => _ReadoutState();
}

class _ReadoutState extends State<_Readout> {
  double? _last;

  void _onChanged(double value) => setState(() => _last = value);

  @override
  Widget build(BuildContext context) {
    final text = _last == null ? '—' : _last!.toStringAsFixed(2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.builder(_onChanged),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            'onChanged: $text',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

/// A labelled column of widgets, one per row.
class _Gallery extends StatelessWidget {
  const _Gallery({required this.rows});

  final List<(String, Widget)> rows;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (label, child) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: labelStyle),
                  const SizedBox(height: 4),
                  child,
                ],
              ),
            ),
        ],
      ),
    );
  }
}
