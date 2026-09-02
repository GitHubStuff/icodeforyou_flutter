// packages/app_navigation/lib/src/rail/deprecated/rail_button_settings.dart

import 'package:app_navigation/src/shared/dual_nav_button.dart';
import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';

/// The default caption label for [SettingsRailButton].
const String _kSettingsLabel = 'Settings';

/// A [DualNavButton] preset for navigating to the settings screen.
///
/// Displays [Icons.settings] with a default caption of `'Settings'`.
/// Pass a different [caption] to relabel it, or `caption: null`
/// explicitly for an icon-only button. All behavioral parameters pass
/// straight through to [DualNavButton].
///
/// This widget is deliberately route-ignorant: navigation is the
/// caller's responsibility, wired through [onPressed].
class SettingsRailButton extends StatelessWidget {
  /// Creates a [SettingsRailButton].
  const SettingsRailButton({
    required this.onPressed,
    super.key,
    this.caption = const Text(_kSettingsLabel),
    this.size = const Size(48, 48),
    this.isSelected = false,
    this.tint,
    this.hapticIntensity = HapticIntensity.light,
  });

  /// See [DualNavButton.onPressed].
  final VoidCallback onPressed;

  /// See [DualNavButton.caption]. Defaults to `Text('Settings')`; pass
  /// `null` for an icon-only button.
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
      icon: const Icon(Icons.settings),
      caption: caption,
      size: size,
      isSelected: isSelected,
      tint: tint,
      hapticIntensity: hapticIntensity,
    );
  }
}
