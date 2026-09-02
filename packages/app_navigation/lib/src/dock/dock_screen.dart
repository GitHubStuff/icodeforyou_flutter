// packages/app_navigation/lib/src/dock/dock_screen.dart
import 'package:app_navigation/app_navigation.dart'
    show NavigableDestinationAbstract;
import 'package:app_navigation/src/cubit/cubit.dart'
    show NavigationCubit, NavigationState;
import 'package:app_navigation/src/dock/dock_destination_buttons.dart'
    show DockDestinationButtons;
import 'package:collection/collection.dart';
import 'package:custom_widgets/custom_widgets.dart' show SlideIndexedStack;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder, ReadContext;

/// {@template dock_screen}
/// The app's main screen in dock form: a content area above the
/// horizontal dock of destination buttons.
///
/// Selection lives in the [NavigationCubit] provided above
/// `NavigationChooser`, not here — so it survives the dock↔rail swaps
/// that rotation and window resizing trigger. This widget is
/// stateless: it renders the cubit's state and reports taps back
/// through [NavigationCubit.select]. The cubit's rail-visibility flag
/// is the rail's concern; the dock ignores it.
///
/// The cubit stores the selected destination as an enum member *name*,
/// since the dock and rail own separate destination enums. The name is
/// resolved against [values] here; a name with no member
/// in this list — a destination that exists only in the rail — falls
/// back to [initial].
///
/// Destination views are kept alive across switches: every view lives
/// in a [SlideIndexedStack] covering all of [values] — overflowed
/// destinations still have live views; the partition changes their entry
/// point, not their existence. [SlideIndexedStack] keeps the
/// [IndexedStack] contract — all children mounted for this widget's
/// lifetime — while sliding between views on selection, in the direction
/// implied by [values] declaration order.
///
/// The dock is placed along the bottom of the screen, below the
/// content area; this screen owns that placement decision.
/// {@endtemplate}
class DockScreen<T extends NavigableDestinationAbstract>
    extends StatelessWidget {
  /// {@macro dock_screen}
  /// Creates the app's main screen in dock form.
  const DockScreen({
    required this.values,
    required this.visible,
    required this.initial,
    super.key,
    this.overflowed = const [],
    this.sizeOverrides = const {},
  });

  /// The complete list of destination enum values.
  final List<T> values;

  /// The destination enum members rendered as visible dock buttons.
  final List<T> visible;

  /// The destination enum members placed in the overflow popover.
  final List<T> overflowed;

  /// The default fallback destination when state resolution fails.
  final T initial;

  /// Optional per-destination size overrides for visible buttons.
  final Map<T, Size> sizeOverrides;

  /// The member of [values] named by [state], falling
  /// back to [initial] when no member matches that name.
  T _selectedFrom(NavigationState state) =>
      values.firstWhereOrNull((e) => e.name == state.destinationName) ??
      initial;

  void _onSelect(BuildContext context, T destination) =>
      context.read<NavigationCubit>().select(destination.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<NavigationCubit, NavigationState>(
          builder: (context, state) {
            final selected = _selectedFrom(state);

            return Column(
              children: [
                Expanded(
                  child: SlideIndexedStack(
                    index: values.indexOf(selected),
                    children: [
                      for (final destination in values)
                        destination.viewBuilder(),
                    ],
                  ),
                ),
                DockDestinationButtons<T>(
                  visible: visible,
                  overflowed: overflowed,
                  selected: selected,
                  onSelect: (destination) => _onSelect(context, destination),
                  sizeOverrides: sizeOverrides,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
