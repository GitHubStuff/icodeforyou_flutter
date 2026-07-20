// packages/rail_navigation/lib/src/widgets/rail_button_database.dart

import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:rail_navigation/src/widgets/rail_button.dart';

/// The default caption label for [DatabaseRailButton].
const String _kDatabaseLabel = 'Database';

/// A [RailButton] preset for navigating to the database screen.
///
/// Displays [Icons.storage] with a default caption of `'Database'`.
/// Pass a different [caption] to relabel it, or `caption: null`
/// explicitly for an icon-only button. All behavioral parameters pass
/// straight through to [RailButton].
///
/// This widget is deliberately route-ignorant: navigation is the
/// caller's responsibility, wired through [onPressed].
class DatabaseRailButton extends StatelessWidget {
  /// Creates a [DatabaseRailButton].
  const DatabaseRailButton({
    required this.onPressed,
    super.key,
    this.caption = const Text(_kDatabaseLabel),
    this.size = const Size(48, 48),
    this.isSelected = false,
    this.tint,
    this.hapticIntensity = HapticIntensity.light,
  });

  /// See [RailButton.onPressed].
  final VoidCallback onPressed;

  /// See [RailButton.caption]. Defaults to `Text('Database')`; pass
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
      icon: const Icon(Icons.storage),
      caption: caption,
      size: size,
      isSelected: isSelected,
      tint: tint,
      hapticIntensity: hapticIntensity,
    );
  }
}
