// programs/{{name.snakeCase()}}/lib/app_shared_navigation/navigation_chooser.dart

import 'package:flutter/material.dart';

import '../app_dock_navigation/dock_screen.dart' show DockScreen;
import '../app_rail_navigation/rail_screen.dart' show RailScreen;

/// Widths below this render the dock; at or above it, the rail.
///
/// Material 3's compact/medium breakpoint: phones in portrait fall
/// below it, phones in landscape and tablets in any orientation land
/// at or above it, and web crosses it as the window is resized.
const double _kRailBreakpoint = 600;

/// {@template navigation_chooser}
/// Chooses between [DockScreen] and [RailScreen] by available width.
///
/// The only place in the app that knows both navigations exist, and
/// the only place that knows why one is showing: width below
/// [_kRailBreakpoint] gets the dock, width at or above it gets the
/// rail. Neither screen receives that reason; each simply renders.
///
/// Phone rotation, tablet orientation, and web window resizing all
/// reduce to width changes, so a single [MediaQuery.sizeOf] read —
/// which rebuilds this widget whenever the size changes — covers
/// every case without platform or orientation detection.
/// {@endtemplate}
class NavigationChooser extends StatelessWidget {
  /// {@macro navigation_chooser}
  const NavigationChooser({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.sizeOf(context).width < _kRailBreakpoint
        ? const DockScreen()
        : const RailScreen();
  }
}
