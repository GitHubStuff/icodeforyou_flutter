// programs/black_velvet/lib/app_dock_navigation/dock_screen.dart

import 'package:custom_widgets/custom_widgets.dart' show SlideIndexedStack;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:since_when_dev/app_dock_navigation/dock_destination_buttons.dart'
    show DockDestinationButtons;
import 'package:since_when_dev/app_dock_navigation/dock_destination_enum.dart'
    show DockDestinationEnum;
import 'package:since_when_dev/app_shared_navigation/navigation_cubit.dart'
    show NavigationCubit;
import 'package:since_when_dev/app_shared_navigation/navigation_state.dart'
    show NavigationState;

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
/// resolved against [DockDestinationEnum] here; a name with no member
/// in this enum — a destination that exists only in the rail — falls
/// back to [DockDestinationEnum.initial].
///
/// Everything else app-specific is read from [DockDestinationEnum]:
/// the partition from [DockDestinationEnum.visible] and
/// [DockDestinationEnum.overflowed], and each destination's view from
/// [DockDestinationEnum.viewBuilder]. This file is never edited when
/// the destination set changes.
///
/// Destination views are kept alive across switches: every view lives
/// in a [SlideIndexedStack] covering all of
/// [DockDestinationEnum.values] — overflowed destinations still have
/// live views; the partition changes their entry point, not their
/// existence. [SlideIndexedStack] keeps the [IndexedStack] contract —
/// all children mounted for this widget's lifetime — while sliding
/// between views on selection, in the direction implied by
/// [DockDestinationEnum] declaration order.
///
/// The dock is placed along the bottom of the screen, below the
/// content area; this screen owns that placement decision.
/// {@endtemplate}
class DockScreen extends StatelessWidget {
  /// {@macro dock_screen}
  /// Creates the app's main screen in dock form.
  const DockScreen({super.key});

  /// The member of [DockDestinationEnum] named by [state], falling
  /// back to [DockDestinationEnum.initial] when this enum has no
  /// member with that name.
  DockDestinationEnum _selectedFrom(NavigationState state) =>
      DockDestinationEnum.values.asNameMap()[state.destinationName] ??
      DockDestinationEnum.initial;

  void _onSelect(BuildContext context, DockDestinationEnum destination) =>
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
                    index: DockDestinationEnum.values.indexOf(selected),
                    children: [
                      for (final destination in DockDestinationEnum.values)
                        destination.viewBuilder(),
                    ],
                  ),
                ),
                DockDestinationButtons(
                  visible: DockDestinationEnum.visible,
                  overflowed: DockDestinationEnum.overflowed,
                  selected: selected,
                  onSelect: (destination) => _onSelect(context, destination),
                  sizeOverrides: const {},
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
