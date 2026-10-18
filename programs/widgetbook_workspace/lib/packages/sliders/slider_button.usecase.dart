// programs/widgetbook_workspace/lib/packages/sliders/slider_button.usecase.dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;
import 'package:sliders/sliders.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Icons offered by the "Icon" knob.
enum _IconChoice {
  decrease('Decrease (−)', Icons.remove_circle_outline),
  increase('Increase (+)', Icons.add_circle_outline),
  chevronLeft('Chevron left', Icons.chevron_left),
  chevronRight('Chevron right', Icons.chevron_right),
  reset('Reset', Icons.restart_alt);

  const _IconChoice(this.label, this.icon);

  final String label;
  final IconData icon;
}

@widgetbook.UseCase(name: 'Interactive', type: SliderButton)
Widget buildSliderButtonInteractiveUseCase(BuildContext context) {
  final enabled = context.knobs.boolean(
    label: 'Enabled',
    initialValue: true,
  );
  final hint = context.knobs.string(label: 'hint', initialValue: 'Increase');
  final choice = context.knobs.object.dropdown<_IconChoice>(
    label: 'Icon',
    options: _IconChoice.values,
    initialOption: _IconChoice.increase,
    labelBuilder: (choice) => choice.label,
  );
  final color = context.knobs.colorOrNull(label: 'Icon colour');
  final haptic = context.knobs.object.dropdown<HapticIntensity>(
    label: 'haptic',
    options: HapticIntensity.values,
    initialOption: .light,
    labelBuilder: (haptic) => haptic.name,
  );

  return _SliderButtonHarness(
    enabled: enabled,
    hint: hint,
    icon: Icon(choice.icon, color: color),
    haptic: haptic,
  );
}

/// Hosts a [SliderButton] and counts its taps.
///
/// The button is stateless and only observable through `onTap`, so the
/// count is the proof that the callback fired.
class _SliderButtonHarness extends StatefulWidget {
  const _SliderButtonHarness({
    required this.enabled,
    required this.hint,
    required this.icon,
    required this.haptic,
  });

  final bool enabled;
  final String hint;
  final Widget icon;
  final HapticIntensity haptic;

  @override
  State<_SliderButtonHarness> createState() => _SliderButtonHarnessState();
}

class _SliderButtonHarnessState extends State<_SliderButtonHarness> {
  int _taps = 0;

  void _onTap() => setState(() => _taps++);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderButton(
            icon: widget.icon,
            hint: widget.hint,
            haptic: widget.haptic,
            onTap: widget.enabled ? _onTap : null,
          ),
          const Gap(8),
          Text(
            'onTap called $_taps time${_taps == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Gap(4),
          Text(
            'Long-press the button to see the tooltip.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
