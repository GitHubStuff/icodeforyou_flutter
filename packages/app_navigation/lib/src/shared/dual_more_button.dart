// packages/app_navigation/lib/src/shared/dual_more_button.dart

import 'package:app_navigation/src/shared/dual_nav_button.dart'
    show DualNavButton;
import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';

/// The default caption label for [DualMoreButton].
const String _kMoreLabel = 'More';

/// A [DualNavButton] preset for revealing overflow navigation destinations.
///
/// Displays [Icons.more_horiz] with a default caption of `'More'`. Pass
/// a different [caption] to relabel it, or `caption: null` explicitly
/// for an icon-only button. All behavioral parameters pass straight
/// through to [DualNavButton].
///
/// Unlike the destination presets, this button typically opens an
/// overflow surface (menu, sheet, or expanded rail) rather than
/// navigating, so [isSelected] usually stays `false`. The parameter is
/// kept for uniformity: if the overflow surface is itself a screen, the
/// parent may select this button while that screen is active.
///
/// This widget is deliberately route-ignorant: what "more" reveals is
/// the caller's responsibility, wired through [onPressed].
class DualMoreButton extends StatelessWidget {
  /// Creates a [DualMoreButton].
  const DualMoreButton({
    required this.onPressed,
    super.key,
    this.caption = const Text(_kMoreLabel),
    this.size = const Size(48, 48),
    this.isSelected = false,
    this.tint,
    this.hapticIntensity = HapticIntensity.light,
  });

  /// See [DualNavButton.onPressed].
  final VoidCallback onPressed;

  /// See [DualNavButton.caption]. Defaults to `Text('More')`; pass `null`
  /// for an icon-only button.
  final Widget? caption;

  /// See [DualNavButton.size].
  final Size size;

  /// See [DualNavButton.isSelected].
  final bool isSelected;

  /// See [DualNavButton.tint].
  final Color? tint;

  /// See [DualNavButton.hapticIntensity].
  final HapticIntensity hapticIntensity;

  @override
  Widget build(BuildContext context) {
    return DualNavButton(
      onPressed: onPressed,
      icon: const Icon(Icons.more_horiz),
      caption: caption,
      size: size,
      isSelected: isSelected,
      tint: tint,
      hapticIntensity: hapticIntensity,
    );
  }
}
