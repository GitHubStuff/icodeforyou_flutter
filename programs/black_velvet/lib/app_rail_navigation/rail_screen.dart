// programs/black_velvet/lib/app_rail_navigation/rail_screen.dart

import 'package:custom_widgets/custom_widgets.dart' show SlideIndexedStack;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder, ReadContext;

import '../app_shared_navigation/navigation_cubit.dart' show NavigationCubit;
import '../app_shared_navigation/navigation_state.dart' show NavigationState;
import 'rail_destination_buttons.dart' show RailDestinationButtons;
import 'rail_destination_enum.dart' show RailDestinationEnum;

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
/// resolved against [RailDestinationEnum] here; a name with no member
/// in this enum — a destination that exists only in the dock — falls
/// back to [RailDestinationEnum.initial].
///
/// Everything else app-specific is read from [RailDestinationEnum]:
/// the partition from [RailDestinationEnum.visible] and
/// [RailDestinationEnum.overflowed], and each destination's view from
/// [RailDestinationEnum.viewBuilder]. This file is never edited when
/// the destination set changes.
///
/// The rail can be hidden. A chevron above the buttons toggles
/// visibility, sliding the rail closed so the content area reflows
/// into its space — a persistent collapse, not a [Drawer]: nothing
/// overlays the content and no scrim appears. The chevron column
/// itself stays put so the rail can always be reopened. The buttons
/// remain mounted while hidden; only their width animates.
///
/// Destination views are kept alive across switches: every view lives
/// in a [SlideIndexedStack] covering all of
/// [RailDestinationEnum.values] — overflowed destinations still have
/// live views; the partition changes their entry point, not their
/// existence. [SlideIndexedStack] keeps the [IndexedStack] contract —
/// all children mounted for this widget's lifetime — while sliding
/// between views on selection, in the direction implied by
/// [RailDestinationEnum] declaration order.
///
/// The rail is placed along the left edge of the screen, beside the
/// content area; this screen owns that placement decision.
/// {@endtemplate}
class RailScreen extends StatelessWidget {
  /// {@macro rail_screen}
  /// Creates the app's main screen in rail form.
  const RailScreen({super.key});

  /// The member of [RailDestinationEnum] named by [state], falling
  /// back to [RailDestinationEnum.initial] when this enum has no
  /// member with that name.
  RailDestinationEnum _selectedFrom(NavigationState state) =>
      RailDestinationEnum.values.asNameMap()[state.destinationName] ??
      RailDestinationEnum.initial;

  void _onSelect(BuildContext context, RailDestinationEnum destination) =>
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
                          child: RailDestinationButtons(
                            visible: RailDestinationEnum.visible,
                            overflowed: RailDestinationEnum.overflowed,
                            selected: selected,
                            onSelect: (destination) =>
                                _onSelect(context, destination),
                            sizeOverrides: const {},
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SlideIndexedStack(
                    index: RailDestinationEnum.values.indexOf(selected),
                    children: [
                      for (final destination in RailDestinationEnum.values)
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
