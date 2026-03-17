// packages/rail_menu/lib/src/cubit/rail_menu_state.dart

import 'package:flutter/foundation.dart';
import 'package:rail_menu/src/model/rail_menu_item.dart';

/// The state emitted by [RailMenuCubit].
@immutable
class RailMenuState {
  /// Creates a [RailMenuState].
  const RailMenuState({
    required this.activeIndex,
    this.transition = RailMenuTransition.none,
  });

  /// The index of the currently active menu item.
  final int activeIndex;

  /// The transition to apply when navigating to the active item.
  final RailMenuTransition transition;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RailMenuState &&
          runtimeType == other.runtimeType &&
          activeIndex == other.activeIndex &&
          transition == other.transition;

  @override
  int get hashCode => Object.hash(activeIndex, transition);
}
