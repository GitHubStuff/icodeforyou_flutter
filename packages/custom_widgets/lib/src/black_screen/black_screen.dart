// packages/splash_framework/lib/src/widgets/black_screen.dart

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const Color _kBlack = Colors.purple;
//const Color _kBlack = Color(0xFF000000);

const SystemUiOverlayStyle _kOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: _kBlack,
  statusBarBrightness: Brightness.dark,
  statusBarIconBrightness: Brightness.dark,
  systemNavigationBarColor: _kBlack,
  systemNavigationBarDividerColor: _kBlack,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemStatusBarContrastEnforced: false,
  systemNavigationBarContrastEnforced: false,
);

/// An opaque black surface filling the window, and nothing else.
///
/// Holds no content and takes no child: it paints and blacks out the system
/// bars. Stack something over it to put content on screen.
///
/// Immune to the app's theme. No `Scaffold`, no `Theme`, no `ThemeData` — this
/// file does not import `material.dart`, so no theme property can reach it. It
/// paints identically whether built before or after the theme resolves.
///
/// Bleeds edge to edge, behind the status bar and the system navigation bar,
/// and stays black while the keyboard opens or the device rotates.
final class BlackScreen extends StatelessWidget {
  /// Creates a [BlackScreen].
  const BlackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: _kOverlayStyle,
      child: ColoredBox(
        color: _kBlack,
        child: SizedBox.expand(),
      ),
    );
  }
}
