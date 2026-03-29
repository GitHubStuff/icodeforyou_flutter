// lib/src/cubit/rail_menu_cubit.dart

import 'package:animated_rail_menu/animated_rail_menu.dart'
    show RailNavigationWidget;
import 'package:animated_rail_menu/src/cubit/cubit.dart';
import 'package:animated_rail_menu/src/model/model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// [RailMenuCubit] for mantaining state of a [RailNavigationWidget]
class RailMenuCubit extends Cubit<RailMenuState> implements RailMenuController {
  /// Creates a [RailMenuCubit].
  RailMenuCubit({int defaultIndex = 0})
    : super(RailMenuState(activeIndex: defaultIndex));

  @override
  int get activeIndex => state.activeIndex;

  @override
  RailTransition get transition => state.transition;

  @override
  void setActive(int index, RailTransition transition) {
    if (index == state.activeIndex) return;
    emit(RailMenuState(activeIndex: index, transition: transition));
  }

  /// Resolves the correct [RailTransition] for the slide direction based on
  /// the tap index relative to the current active index and rail direction.
  RailTransition resolveDirectional({
    required int tappedIndex,
    required RailDirection direction,
  }) {
    final isForward = tappedIndex > state.activeIndex;
    if (direction == RailDirection.horizontal) {
      return isForward ? RailTransition.slideRight : RailTransition.slideLeft;
    }
    return isForward ? RailTransition.slideDown : RailTransition.slideUp;
  }
}
