// lib/src/_step_slider_body.dart
part of 'step_slider.dart';

/// Internal widget containing the slider and buttons layout.
class _StepSliderBody extends StatelessWidget {
  const _StepSliderBody({
    required this.min,
    required this.max,
    required this.step,
    required this.divisions,
    required this.label,
    required this.onChanged,
    required this.activeColor,
    required this.inactiveColor,
    required this.thumbColor,
    required this.buttonColor,
    required this.buttonIconColor,
    required this.buttonSize,
    required this.enableHapticFeedback,
    required this.hapticFeedbackType,
  });

  final double min;
  final double max;
  final double step;
  final int? divisions;
  final String? label;
  final ValueChanged<double>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final Color? buttonColor;
  final Color? buttonIconColor;
  final double buttonSize;
  final bool enableHapticFeedback;
  final HapticFeedbackType hapticFeedbackType;

  void _onChanged(BuildContext context, double value) {
    context.read<_SliderCubit>().update(value);
    onChanged?.call(value);
  }

  void _decrement(BuildContext context, double current) {
    final newValue = (current - step).clamp(min, max);
    _onChanged(context, newValue);
  }

  void _increment(BuildContext context, double current) {
    final newValue = (current + step).clamp(min, max);
    _onChanged(context, newValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveButtonColor = buttonColor ?? theme.colorScheme.primary;
    final effectiveIconColor = buttonIconColor ?? theme.colorScheme.onPrimary;

    return BlocBuilder<_SliderCubit, double>(
      builder: (context, value) {
        return Row(
          children: [
            _StepButton(
              icon: Icons.remove,
              onTap: value > min ? () => _decrement(context, value) : null,
              size: buttonSize,
              color: effectiveButtonColor,
              iconColor: effectiveIconColor,
              enableHapticFeedback: enableHapticFeedback,
              hapticFeedbackType: hapticFeedbackType,
            ),
            Expanded(
              child: Slider(
                value: value,
                onChanged: (val) => _onChanged(context, val),
                min: min,
                max: max,
                divisions: divisions,
                label: label ?? value.round().toString(),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                thumbColor: thumbColor,
              ),
            ),
            _StepButton(
              icon: Icons.add,
              onTap: value < max ? () => _increment(context, value) : null,
              size: buttonSize,
              color: effectiveButtonColor,
              iconColor: effectiveIconColor,
              enableHapticFeedback: enableHapticFeedback,
              hapticFeedbackType: hapticFeedbackType,
            ),
          ],
        );
      },
    );
  }
}
