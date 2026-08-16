// programs/{{name.snakeCase()}}/lib/app_navigation/navigation_cubit.dart

import 'package:{{name.snakeCase()}}/app_shared_navigation/navigation_state.dart'
    show NavigationState;
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template navigation_cubit}
/// Owns [NavigationState] for the navigation shell.
///
/// Lives above `NavigationChooser`, so it survives the dock↔rail swap
/// that rotation and window resizing trigger: the screens' subtrees
/// are rebuilt from scratch on every swap, but selection and rail
/// visibility read from here and carry across.
/// {@endtemplate}
final class NavigationCubit extends Cubit<NavigationState> {
  /// {@macro navigation_cubit}
  /// Starts at [initialDestinationName] with the rail shown.
  NavigationCubit({required String initialDestinationName})
    : super(NavigationState(destinationName: initialDestinationName));

  /// Selects the destination with [name].
  void select(String name) => emit(state.copyWith(destinationName: name));

  /// Toggles the rail's visibility.
  void toggleRail() => emit(state.copyWith(railVisible: !state.railVisible));
}
