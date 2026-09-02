// packages/custom_widgets/lib/src/solid_screen_color/sollid_screen_color.dart

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter/widgets.dart';

/// Default fill color when none is provided.
const Color _kBlack = Colors.black;

/// Builds a [SystemUiOverlayStyle] that paints the status bar and system
/// navigation bar with [color], disables contrast enforcement, and uses
/// dark icon brightness on both bars.
SystemUiOverlayStyle _kOverlayStyle(Color color) => SystemUiOverlayStyle(
  statusBarColor: color,
  statusBarBrightness: Brightness.dark,
  statusBarIconBrightness: Brightness.dark,
  systemNavigationBarColor: color,
  systemNavigationBarDividerColor: color,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemStatusBarContrastEnforced: false,
  systemNavigationBarContrastEnforced: false,
);

/// {@template full_screen_color.dart}
/// A chrome-free surface that fills the screen with a single solid [color].
///
/// Paints the entire viewport, including the status bar and system
/// navigation bar regions, via an [AnnotatedRegion] carrying a matching
/// [SystemUiOverlayStyle]. Useful as a splash surface or backdrop where no
/// system chrome should be visible.
///
/// Defaults to [Colors.black].
///
/// ```dart
/// const SolidScreenColor(); // black
/// const SolidScreenColor(color: Colors.white);
/// ```
/// {@endtemplate}
final class SolidScreenColor extends StatelessWidget {
  /// {@macro full_screen_color.dart}
  ///
  /// [color] defaults to black.
  const SolidScreenColor({this.color = _kBlack, super.key});

  /// The color painted across the full screen and system bars.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _kOverlayStyle(color),
      child: ColoredBox(
        color: color,
        child: const SizedBox.expand(),
      ),
    );
  }
}
