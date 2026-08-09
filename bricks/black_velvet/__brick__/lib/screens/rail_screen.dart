// programs/{{name.snakeCase()}}/lib/screens/app_screen.dart

import 'package:analog_clock_widget/analog_clock_widget.dart' show AnalogClock;
import 'package:flutter/material.dart';

import '../app_rail_navigation/rail_destination_enum.dart'
    show RailDestinationEnum;
import '../app_rail_navigation/rail_destintation_buttons.dart'
    show RailDestinationButtons;

/// The destination shown when the app screen first appears.
const RailDestinationEnum _kInitialDestination = RailDestinationEnum.home;

/// The destinations shown as rail buttons, in rail order.
///
/// This screen's partition policy, together with
/// [_kOverflowedDestinations]: primary destinations get buttons,
/// secondary ones live behind the overflow button. Moving a member
/// between the two lists is the whole change needed to promote or
/// demote it.
const List<RailDestinationEnum> _kVisibleDestinations = [
  RailDestinationEnum.home,
  RailDestinationEnum.database,
  RailDestinationEnum.search,
];

/// The destinations folded into the overflow popover, in tile order.
///
/// Non-empty, so the rail renders an overflow button in its last
/// slot; tapping it opens a popover listing these as tiles.
const List<RailDestinationEnum> _kOverflowedDestinations = [
  RailDestinationEnum.library,
  RailDestinationEnum.settings,
];

/// The app's main screen: a content area plus the rail of destination
/// buttons.
///
/// This widget is the route child for `RoutesFramework.app` and the
/// owner of rail selection state — the one responsibility
/// [RailDestinationButtons] deliberately does not take on. It holds the
/// selected [RailDestinationEnum], passes it down, and rebuilds when a
/// tap reports a new destination through `onSelect`. It also owns the
/// rail's partition policy — which destinations are visible buttons
/// and which overflow — declared in [_kVisibleDestinations] and
/// [_kOverflowedDestinations].
///
/// Selection arrives through the same `onSelect` callback regardless
/// of whether the user tapped a rail button or picked an overflow
/// popover tile; this screen cannot tell the difference and does not
/// need to.
///
/// Destination views are kept alive across switches: every view lives
/// in an [IndexedStack] covering all of [RailDestinationEnum.values] —
/// overflowed destinations still have live views; the partition
/// changes their entry point, not their existence.
///
/// The rail is placed along the bottom, so the buttons are laid out
/// with [Axis.horizontal]; this screen owns that placement decision and
/// states the axis explicitly, as [RailDestinationButtons] requires.
class RailScreen extends StatefulWidget {
  /// Creates the app's main screen.
  const RailScreen({super.key});

  @override
  State<RailScreen> createState() => _RailScreenState();
}

class _RailScreenState extends State<RailScreen> {
  RailDestinationEnum _selected = _kInitialDestination;

  void _onSelect(RailDestinationEnum destination) {
    if (destination == _selected) {
      return;
    }
    setState(() {
      _selected = destination;
    });
  }

  /// The view for [destination].
  ///
  /// The single mapping site between destinations and their content,
  /// mirroring how `RailDestinationButtons` is the single mapping site
  /// between destinations and their buttons. The switch is exhaustive:
  /// adding a [RailDestinationEnum] member is a compile error here
  /// until its view is declared.
  Widget _destinationView(RailDestinationEnum destination) =>
      switch (destination) {
        RailDestinationEnum.home => Center(child: AnalogClock(radius: 105)),
        RailDestinationEnum.database => const Center(child: Text('Database')),
        RailDestinationEnum.library => const Center(child: Text('Library')),
        RailDestinationEnum.search => const Center(child: Text('Search')),
        RailDestinationEnum.settings => const Center(child: Text('Settings')),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: RailDestinationEnum.values.indexOf(_selected),
                children: [
                  for (final destination in RailDestinationEnum.values)
                    _destinationView(destination),
                ],
              ),
            ),
            RailDestinationButtons(
              direction: Axis.horizontal,
              visible: _kVisibleDestinations,
              overflowed: _kOverflowedDestinations,
              selected: _selected,
              onSelect: _onSelect,
            ),
          ],
        ),
      ),
    );
  }
}
