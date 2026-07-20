// packages/rail_navigation/lib/src/widgets/rail_button_settings.dart

import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:rail_navigation/src/widgets/rail_button.dart';

/// The default caption label for [SettingsRailButton].
const String _kSettingsLabel = 'Settings';

/// A [RailButton] preset for navigating to the settings screen.
///
/// Displays [Icons.settings] with a default caption of `'Settings'`.
/// Pass a different [caption] to relabel it, or `caption: null`
/// explicitly for an icon-only button. All behavioral parameters pass
/// straight through to [RailButton].
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

  /// See [RailButton.onPressed].
  final VoidCallback onPressed;

  /// See [RailButton.caption]. Defaults to `Text('Settings')`; pass
  /// `null` for an icon-only button.
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
      icon: const Icon(Icons.settings),
      caption: caption,
      size: size,
      isSelected: isSelected,
      tint: tint,
      hapticIntensity: hapticIntensity,
    );
  }
}
