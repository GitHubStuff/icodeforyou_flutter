// packages/sliders/lib/src/slider_button.dart
import 'package:flutter/material.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;
import 'package:sliders/src/constants.dart' show Constants;

/// One of the two buttons flanking a slider.
///
/// Shows [icon] inside an [IconButton] at a fixed size of
/// `Constants.iconSize` logical pixels. Tapping it triggers the [haptic]
/// feedback and then notifies the caller via [onTap].
///
/// ## Enabled state
///
/// Passing `null` for [onTap] disables the button: it renders in the
/// disabled style, is not focusable, and fires no haptic. This follows the
/// [IconButton.onPressed] convention, so the caller expresses "can't go any
/// further" simply by withholding the callback.
///
/// ## Accessibility
///
/// [hint] is shown as a tooltip on long-press and doubles as the semantic
/// label read by screen readers, which is why it is required rather than
/// optional.
///
/// ## Example
///
/// ```dart
/// SliderButton(
///   icon: const Icon(Icons.add_circle_outline),
///   hint: 'Increase',
///   haptic: HapticIntensity.medium,
///   onTap: () => debugPrint('tapped'),
/// )
/// ```
///
/// See also:
///
/// * `HSliderWithButtons`, which places one of these on each side of a
///   `HorizontalSlider`.
/// * [HapticIntensity], the feedback options available for [haptic].
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
  ///
  /// Usually an [Icon]; any widget that looks right at `Constants.iconSize`
  /// will do.
  final Widget icon;

  /// Tooltip text and accessibility label for the button.
  final String hint;

  /// Called after the haptic fires. `null` disables the button.
  final VoidCallback? onTap;

  /// The haptic feedback triggered on tap. Defaults to light.
  ///
  /// Use [HapticIntensity.none] to silence it.
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
