// ppackages/rail_navigation/lib/src/widgets/rail_button_main.dartshow 

import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:rail_navigation/src/widgets/rail_button.dart';

/// The default caption label for [MainRailButton].
const String _kMainLabel = 'Main';

/// A [RailButton] preset for navigating to the main screen.
///
/// Displays [Icons.home] with a default caption of `'Main'`. Pass a
/// different [caption] to relabel it, or `caption: null` explicitly for
/// an icon-only button. All behavioral parameters pass straight through
/// to [RailButton].
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

  /// See [RailButton.onPressed].
  final VoidCallback onPressed;

  /// See [RailButton.caption]. Defaults to `Text('Main')`; pass `null`
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
      icon: const Icon(Icons.home),
      caption: caption,
      size: size,
      isSelected: isSelected,
      tint: tint,
      hapticIntensity: hapticIntensity,
    );
  }
}
