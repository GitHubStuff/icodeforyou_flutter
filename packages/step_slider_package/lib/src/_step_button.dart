// lib/src/_step_button.dart
part of 'step_slider.dart';

/// Internal widget for the increment/decrement buttons.
class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.size,
    required this.color,
    required this.iconColor,
    required this.enableHapticFeedback,
    required this.hapticFeedbackType,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color color;
  final Color iconColor;
  final bool enableHapticFeedback;
  final HapticFeedbackType hapticFeedbackType;

  bool get _isEnabled => onTap != null;

  void _handleTap() {
    if (enableHapticFeedback) hapticFeedbackType.trigger();
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: _isEnabled ? color : color.withValues(alpha: 0.4),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _isEnabled ? _handleTap : null,
          customBorder: const CircleBorder(),
          child: Icon(
            icon,
            color: _isEnabled ? iconColor : iconColor.withValues(alpha: 0.4),
            size: size * 0.6,
          ),
        ),
      ),
    );
  }
}
