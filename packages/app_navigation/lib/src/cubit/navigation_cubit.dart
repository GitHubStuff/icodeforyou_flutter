// packages/app_navigation/lib/src/cubit/navigation_cubit.dart

import 'package:app_navigation/src/cubit/navigation_state.dart'
    show NavigationState;
import 'package:flutter_bloc/flutter_bloc.dart';

/// Contract defining navigation cubit behavior for dependency inversion.
abstract interface class NavigationCubitInterface
    implements StateStreamableSource<NavigationState> {
  /// Selects the destination with [name].
  void select(String name);

  /// Toggles the rail's visibility.
  void toggleRail();
}

/// {@template navigation_cubit}
/// Owns [NavigationState] for the navigation shell.
///
/// Lives above `NavigationChooser`, so it survives the dock↔rail swap
/// that rotation and window resizing trigger: the screens' subtrees
/// are rebuilt from scratch on every swap, but selection and rail
/// visibility read from here and carry across.
/// {@endtemplate}
final class NavigationCubit extends Cubit<NavigationState>
    implements NavigationCubitInterface {
  /// {@macro navigation_cubit}
  /// Starts at [initialDestinationName] with the rail shown.
  NavigationCubit({String initialDestinationName = ''})
    : super(NavigationState(destinationName: initialDestinationName));

  /// Selects the destination with [name].
  @override
  void select(String name) => emit(state.copyWith(destinationName: name));

  /// Toggles the rail's visibility.
  @override
  void toggleRail() => emit(state.copyWith(railVisible: !state.railVisible));
}
