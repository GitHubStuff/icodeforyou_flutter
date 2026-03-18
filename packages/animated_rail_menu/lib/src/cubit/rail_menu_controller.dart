// lib/src/cubit/rail_menu_controller.dart

import 'package:animated_rail_menu/src/model/rail_transition.dart';

/// Abstract interface for controlling the active [AnimatedRailMenu] item.
///
/// Callers depend on this interface, not on [RailMenuCubit] directly.
abstract class RailMenuController {
  /// The index of the currently active menu item.
  int get activeIndex;

  /// The transition that was used to reach the current active item.
  RailTransition get transition;

  /// Sets the active item to [index] using the given [transition].
  void setActive(int index, RailTransition transition);
}
