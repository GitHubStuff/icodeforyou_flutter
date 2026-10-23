// packages/app_navigation/lib/src/rail/rail_destination_buttons.dart

import 'package:app_navigation/app_navigation.dart'
    show NavigableDestinationAbstract;
import 'package:app_navigation/src/shared/dual_nav_button.dart'
    show DualNavButton;
import 'package:app_navigation/src/shared/dual_overflow_button.dart'
    show DualOverflowButton;
import 'package:app_navigation/src/shared/dual_popover_tile.dart'
    show DualPopoverTile;
import 'package:flutter/material.dart';

///
class RailDestinationButtons<T extends NavigableDestinationAbstract>
    extends StatelessWidget {
  /// {@macro rail_destination_buttons}
  const RailDestinationButtons({
    required this.visibleList,
    required this.selected, required this.onSelect, this.hiddenList = [],
    super.key,
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
  });

  /// The destinations rendered as rail buttons, in this order.
  ///

  final List<T> buttonList;

  /// The currently selected destination.
  ///
  /// The button (or overflow popover tile) whose enum member equals
  /// this value shows its selection indicator; when the member is in
  /// [overflowed], the overflow button renders selected as well.
  final T selected;

  /// Called with the chosen destination's enum member, whether it was
  /// tapped as a rail button or picked from the overflow popover.
  ///
  /// Rail button taps report every tap, including taps on the
  /// already-selected destination; whether that is a no-op is the
  /// parent's call. Dismissing the popover without a pick reports
  /// nothing.
  final ValueChanged<T> onSelect;

  /// How the buttons are distributed along the rail's main axis.
  ///
  /// The rail fills its main axis, so distribution alignments have
  /// room to work with. Defaults to [MainAxisAlignment.spaceEvenly],
  /// the standard bottom-navigation distribution: equal space before,
  /// between, and after the buttons. [MainAxisAlignment.spaceAround]
  /// and [MainAxisAlignment.spaceBetween] are the usual alternatives;
  /// [MainAxisAlignment.start] or [MainAxisAlignment.center] cluster
  /// the buttons for side rails that shouldn't spread across the full
  /// screen height.
  final MainAxisAlignment mainAxisAlignment;

  /// The rail button for [destination], sized by its [sizeOverrides]
  /// entry when one exists and [_kButtonSize] otherwise.
  Widget _railButton(T destination) => DualNavButton(
    size: const Size(80, 60),
    isSelected: destination == selected,
    icon: Icon(destination.iconData),
    caption: Text(destination.caption),
    onPressed: () => onSelect(destination),
  );

  /// The popover tile for an overflowed [destination].
  Widget _popoverTile(T destination) => DualPopoverTile<T>(
    value: destination,
    isSelected: destination == selected,
    icon: Icon(destination.iconData),
    label: Text(destination.caption),
  );

  @override
  Widget build(BuildContext context) {
    final selectedOverflowIndex = buttonList.indexOf(selected);

    return Flex(
      direction: Axis.vertical,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        for (final destination in visible) _railButton(destination),
        if (overflowed.isNotEmpty)
          DualOverflowButton<T>(
            size: _kButtonSize,
            isSelected: selectedOverflowIndex != -1,
            initialScrollIndex: selectedOverflowIndex != -1
                ? selectedOverflowIndex
                : 0,
            onSelected: onSelect,
            popoverChildren: [
              for (final destination in overflowed) _popoverTile(destination),
            ],
          ),
      ],
    );
  }
}
