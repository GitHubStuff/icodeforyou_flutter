// lib/src/cubit/rail_menu_state.dart

import 'package:animated_rail_menu/animated_rail_menu.dart' show RailMenuCubit;
import 'package:animated_rail_menu/src/model/rail_transition.dart';
import 'package:flutter/foundation.dart';

/// The state emitted by [RailMenuCubit].
@immutable
class RailMenuState {
  /// Creates a [RailMenuState].
  const RailMenuState({
    required this.activeIndex,
    this.transition = RailTransition.crossFade,
  });

  /// The index of the currently active menu item.
  final int activeIndex;

  /// The transition used to reach the active item.
  final RailTransition transition;

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
