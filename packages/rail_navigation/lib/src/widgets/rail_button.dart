// packages/rail_navigation/lib/src/widgets/rail_button.dart

import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';

/// The default fixed footprint of a [RailButton].
///
/// Matches the Material minimum touch target of 48x48.
const Size _kDefaultSize = Size(48, 48);

/// Padding between the button edge and its content.
const EdgeInsets _kContentPadding = EdgeInsets.all(4);

/// Vertical gap between the icon and caption when both are present.
const double _kContentSpacing = 2;

/// A fixed-size, selectable navigation button for use along the bottom or
/// side of a screen.
///
/// A [RailButton] displays an [icon], a [caption], or both, stacked
/// vertically. At least one of the two must be provided; this is enforced
/// by an assertion.
///
/// The button occupies exactly [size]. Content that would not otherwise fit
/// (for example at large accessibility text scales) is scaled down to fit
/// rather than overflowing, so a group of these buttons always keeps a
/// uniform, predictable geometry.
///
/// Selection is owned by the parent. A group of these buttons is expected
/// to behave like a radio group: the parent tracks which button is selected
/// and rebuilds with the appropriate [isSelected] values. When selected,
/// a stadium-shaped indicator is painted behind the content in [tint];
/// the child widgets themselves are never recolored.
///
/// Tapping the button triggers [hapticIntensity] immediately before
/// invoking [onPressed].
class RailButton extends StatelessWidget {
  /// Creates a [RailButton].
  ///
  /// At least one of [icon] or [caption] must be non-null.
  const RailButton({
    required this.onPressed,
    super.key,
    this.icon,
    this.caption,
    this.size = _kDefaultSize,
    this.isSelected = false,
    this.tint,
    this.hapticIntensity = HapticIntensity.light,
  }) : assert(
         icon != null || caption != null,
         'RailButton requires an icon, a caption, or both.',
       );

  /// Called when the button is tapped, after the haptic feedback for
  /// [hapticIntensity] has been triggered.
  ///
  /// Always non-null: every button in a rail group is always tappable.
  /// Whether tapping the already-selected button has any effect is the
  /// parent group's decision.
  final VoidCallback onPressed;

  /// An optional icon to display above [caption].
  ///
  /// Rendered as provided; this widget never recolors it.
  final Widget? icon;

  /// An optional text widget to display below [icon].
  ///
  /// Rendered as provided; this widget never recolors it.
  final Widget? caption;

  /// The fixed footprint of the button.
  ///
  /// Defaults to [_kDefaultSize] (48x48), the Material minimum touch
  /// target. When both [icon] and [caption] are present, a larger size
  /// such as `Size(64, 64)` gives the caption more room; content is
  /// scaled down to fit regardless.
  final Size size;

  /// Whether this button is the currently selected one in its group.
  ///
  /// Defaults to `false`. When `true`, a stadium-shaped indicator in
  /// [tint] is painted behind the content.
  final bool isSelected;

  /// The color of the selection indicator shown when [isSelected] is
  /// `true`.
  ///
  /// When `null`, falls back to
  /// `Theme.of(context).colorScheme.secondaryContainer`, the Material 3
  /// navigation indicator color.
  final Color? tint;

  /// The haptic feedback triggered on tap, immediately before
  /// [onPressed] runs.
  ///
  /// Defaults to [HapticIntensity.light]. Use [HapticIntensity.none] to
  /// disable haptics for this button.
  final HapticIntensity hapticIntensity;

  @override
  Widget build(BuildContext context) {
    final resolvedTint =
        tint ?? Theme.of(context).colorScheme.secondaryContainer;

    return Semantics(
      button: true,
      selected: isSelected,
      child: SizedBox.fromSize(
        size: size,
        child: Material(
          color: isSelected ? resolvedTint : Colors.transparent,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: hapticIntensity.wrap(onPressed),
            customBorder: const StadiumBorder(),
            child: Padding(
              padding: _kContentPadding,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: _kContentSpacing,
                  children: [
                    if (icon != null) icon!,
                    if (caption != null) caption!,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
