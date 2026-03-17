// packages/rail_menu/lib/src/cubit/rail_menu_controller.dart

import 'package:rail_menu/src/model/rail_menu_item.dart';

/// Abstract interface for controlling the active [RailMenu] item.
///
/// Callers depend on this interface, not on [RailMenuCubit] directly.
abstract class RailMenuController {
  /// The index of the currently active menu item.
  int get activeIndex;

  /// The transition to apply when navigating to the active item.
  RailMenuTransition get transition;

  /// Sets the active menu item to [index] with the given [transition].
  void setActive(int index, RailMenuTransition transition);
}
