// lib/src/model/rail_direction.dart

import 'package:animated_rail_menu/src/widget/_internal.dart'
    show RailNavigationWidget;

/// The axis along which the [RailNavigationWidget] bar is rendered.
enum RailDirection {
  /// [adaptive] - changes when the device rotates
  adaptive,

  /// [horizontal] - resides on the bottom of the device
  horizontal,

  /// [vertical] - resides on the side of the device
  vertical,
}
