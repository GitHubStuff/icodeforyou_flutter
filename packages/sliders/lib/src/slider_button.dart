// packages/sliders/lib/src/slider_button.dart
import 'package:flutter/material.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;
import 'package:sliders/src/constants.dart' show Constants;

/// One of the two buttons flanking a slider.
///
/// Shows [icon] inside an [IconButton]. Tapping it triggers the
/// [haptic] feedback and then notifies the caller via [onTap].
///
/// Passing `null` for [onTap] disables the button: it renders in
/// the disabled style, is not focusable, and fires no haptic.
///
/// [hint] is shown as a tooltip on long-press and doubles as the
/// accessibility label, so it is required.
class SliderButton extends StatelessWidget {
  /// Creates a slider button.
  const SliderButton({
    required this.icon,
    required this.hint,
    this.onTap,
    this.haptic = .light,
    super.key,
  });

  /// The icon displayed inside the button.
  final Widget icon;

  /// Tooltip text and accessibility label for the button.
  final String hint;

  /// Called after the haptic fires. `null` disables the button.
  final VoidCallback? onTap;

  /// The haptic feedback triggered on tap. Defaults to light.
  final HapticIntensity haptic;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon,
      iconSize: Constants.iconSize,
      tooltip: hint,
      onPressed: haptic.wrap(onTap),
    );
  }
}
