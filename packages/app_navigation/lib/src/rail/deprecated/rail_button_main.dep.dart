// packages/app_navigation/lib/src/rail/deprecated/rail_button_main.dart

import 'package:app_navigation/src/shared/dual_nav_button.dart'
    show DualNavButton;
import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';

/// The default caption label for [MainRailButton].
const String _kMainLabel = 'Main';

/// A [DualNavButton] preset for navigating to the main screen.
///
/// Displays [Icons.home] with a default caption of `'Main'`. Pass a
/// different [caption] to relabel it, or `caption: null` explicitly for
/// an icon-only button. All behavioral parameters pass straight through
/// to [DualNavButton].
///
/// This widget is deliberately route-ignorant: navigation is the
/// caller's responsibility, wired through [onPressed].
class MainRailButton extends StatelessWidget {
  /// Creates a [MainRailButton].
  const MainRailButton({
    required this.onPressed,
    super.key,
    this.caption = const Text(_kMainLabel),
    this.size = const Size(48, 48),
    this.isSelected = false,
    this.tint,
    this.hapticIntensity = HapticIntensity.light,
  });

  /// See [DualNavButton.onPressed].
  final VoidCallback onPressed;

  /// See [DualNavButton.caption]. Defaults to `Text('Main')`; pass `null`
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
      icon: const Icon(Icons.home),
      caption: caption,
      size: size,
      isSelected: isSelected,
      tint: tint,
      hapticIntensity: hapticIntensity,
    );
  }
}
