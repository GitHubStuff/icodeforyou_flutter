// packages/rail_menu/lib/src/cubit/rail_menu_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rail_menu/src/cubit/rail_menu_controller.dart';
import 'package:rail_menu/src/cubit/rail_menu_state.dart';
import 'package:rail_menu/src/model/rail_menu_item.dart';

/// Owns the active index and transition state for a [RailMenu].
///
/// Provide above the widget tree via [BlocProvider].
///
/// ```dart
/// BlocProvider(
///   create: (_) => RailMenuCubit(defaultIndex: 0),
///   child: MyScaffold(),
/// )
/// ```
class RailMenuCubit extends Cubit<RailMenuState> implements RailMenuController {
  /// Creates a [RailMenuCubit].
  ///
  /// [defaultIndex] seeds the initial active item. Defaults to 0.
  RailMenuCubit({int defaultIndex = 0})
      : super(RailMenuState(activeIndex: defaultIndex));

  @override
  int get activeIndex => state.activeIndex;

  @override
  RailMenuTransition get transition => state.transition;

  @override
  void setActive(int index, RailMenuTransition transition) {
    if (index == state.activeIndex) return;
    emit(RailMenuState(activeIndex: index, transition: transition));
  }
}
