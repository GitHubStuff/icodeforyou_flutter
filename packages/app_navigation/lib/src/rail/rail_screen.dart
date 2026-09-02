// packages/app_navigation/lib/src/rail/rail_screen.dart

import 'package:app_navigation/app_navigation.dart'
    show NavigableDestinationAbstract;
import 'package:app_navigation/src/cubit/navigation_cubit.dart'
    show NavigationCubit;
import 'package:app_navigation/src/cubit/navigation_state.dart'
    show NavigationState;
import 'package:app_navigation/src/rail/rail_destination_buttons.dart'
    show RailDestinationButtons;
import 'package:collection/collection.dart';
import 'package:custom_widgets/custom_widgets.dart' show SlideIndexedStack;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// How long the rail's show/hide slide runs.
const Duration _kToggleDuration = Duration(milliseconds: 250);

/// {@template rail_screen}
/// The app's main screen in rail form: a content area beside the
/// vertical rail of destination buttons.
///
/// Selection and rail visibility live in the [NavigationCubit]
/// provided above `NavigationChooser`, not here — so both survive the
/// dock↔rail swaps that rotation and window resizing trigger. This
/// widget is stateless: it renders the cubit's state and reports
/// interactions back through [NavigationCubit.select] and
/// [NavigationCubit.toggleRail].
///
/// The cubit stores the selected destination as an enum member *name*,
/// since the dock and rail own separate destination enums. The name is
/// resolved against [values] here; a name with no member
/// in this list — a destination that exists only in the dock — falls
/// back to [initial].
///
/// The rail can be hidden. A chevron above the buttons toggles
/// visibility, sliding the rail closed so the content area reflows
/// into its space — a persistent collapse, not a [Drawer]: nothing
/// overlays the content and no scrim appears. The chevron column
/// itself stays put so the rail can always be reopened. The buttons
/// remain mounted while hidden; only their width animates.
///
/// Destination views are kept alive across switches: every view lives
/// in a [SlideIndexedStack] covering all of [values] — overflowed
/// destinations still have live views; the partition changes their entry
/// point, not their existence. [SlideIndexedStack] keeps the
/// [IndexedStack] contract — all children mounted for this widget's
/// lifetime — while sliding between views on selection, in the direction
/// implied by [values] declaration order.
///
/// The rail is placed along the left edge of the screen, beside the
/// content area; this screen owns that placement decision.
/// {@endtemplate}
class RailScreen<T extends NavigableDestinationAbstract>
    extends StatelessWidget {
  /// {@macro rail_screen}
  /// Creates the app's main screen in rail form.
  const RailScreen({
    required this.values,
    required this.visible,
    required this.initial,
    super.key,
    this.overflowed = const [],
    this.sizeOverrides = const {},
  });

  /// The complete list of destination enum values.
  final List<T> values;

  /// The destination enum members rendered as visible rail buttons.
  final List<T> visible;

  /// The destination enum members placed in the overflow popover.
  final List<T> overflowed;

  /// The default fallback destination when state resolution fails.
  final T initial;

  /// Optional per-destination size overrides for visible buttons.
  final Map<T, Size> sizeOverrides;

  /// The member of [values] named by [state], falling
  /// back to [initial] when this collection has no
  /// member with that name.
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

            return Row(
              children: [
                Column(
                  children: [
                    IconButton(
                      tooltip: state.railVisible ? 'Hide rail' : 'Show rail',
                      icon: Icon(
                        state.railVisible
                            ? Icons.chevron_left
                            : Icons.chevron_right,
                      ),
                      onPressed: () =>
                          context.read<NavigationCubit>().toggleRail(),
                    ),
                    Expanded(
                      child: ClipRect(
                        child: AnimatedAlign(
                          alignment: Alignment.topLeft,
                          widthFactor: state.railVisible ? 1 : 0,
                          duration: _kToggleDuration,
                          curve: Curves.easeInOutCubic,
                          child: RailDestinationButtons<T>(
                            visible: visible,
                            overflowed: overflowed,
                            selected: selected,
                            onSelect: (destination) =>
                                _onSelect(context, destination),
                            sizeOverrides: sizeOverrides,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SlideIndexedStack(
                    index: values.indexOf(selected),
                    children: [
                      for (final destination in values)
                        destination.viewBuilder(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
