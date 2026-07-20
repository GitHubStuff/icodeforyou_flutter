// packages/rail_navigation/lib/src/widgets/rail_button_more.dart

import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:rail_navigation/src/widgets/rail_button.dart';

/// The default caption label for [MoreRailButton].
const String _kMoreLabel = 'More';

/// A [RailButton] preset for revealing overflow navigation destinations.
///
/// Displays [Icons.more_horiz] with a default caption of `'More'`. Pass
/// a different [caption] to relabel it, or `caption: null` explicitly
/// for an icon-only button. All behavioral parameters pass straight
/// through to [RailButton].
///
/// Unlike the destination presets, this button typically opens an
/// overflow surface (menu, sheet, or expanded rail) rather than
/// navigating, so [isSelected] usually stays `false`. The parameter is
/// kept for uniformity: if the overflow surface is itself a screen, the
/// parent may select this button while that screen is active.
///
/// This widget is deliberately route-ignorant: what "more" reveals is
/// the caller's responsibility, wired through [onPressed].
class MoreRailButton extends StatelessWidget {
  /// Creates a [MoreRailButton].
  const MoreRailButton({
    required this.onPressed,
    super.key,
    this.caption = const Text(_kMoreLabel),
    this.size = const Size(48, 48),
    this.isSelected = false,
    this.tint,
    this.hapticIntensity = HapticIntensity.light,
  });

  /// See [RailButton.onPressed].
  final VoidCallback onPressed;

  /// See [RailButton.caption]. Defaults to `Text('More')`; pass `null`
  /// for an icon-only button.
  final Widget? caption;

  /// See [RailButton.size].
  final Size size;

  /// See [RailButton.isSelected].
  final bool isSelected;

  /// See [RailButton.tint].
  final Color? tint;

  /// See [RailButton.hapticIntensity].
  final HapticIntensity hapticIntensity;

  @override
  Widget build(BuildContext context) {
    return RailButton(
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
