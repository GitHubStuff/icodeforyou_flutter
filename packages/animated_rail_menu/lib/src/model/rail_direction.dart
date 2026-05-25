// animated_rail_menu/lib/src/model/rail_direction.dart

import 'package:animated_rail_menu/src/widget/animated_rail_menu_widget.dart'
    show AnimatedRailMenu;

/// The axis along which the [AnimatedRailMenu] bar is rendered.
enum RailDirection {
  /// [adaptive] - changes when the device rotates
  adaptive,

  /// [horizontal] - resides on the bottom of the device
  horizontal,

  /// [vertical] - resides on the side of the device
  vertical,
}
