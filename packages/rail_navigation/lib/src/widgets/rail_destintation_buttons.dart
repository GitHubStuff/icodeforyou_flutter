// packages/rail_navigation/lib/src/widgets/rail_destination_buttons.dart

import 'package:flutter/material.dart';
import 'package:black_velvet/rail_navigation/rail_destination_enum.dart'
    show RailDestinationEnum;
import 'package:rail_navigation/src/widgets/rail_button.dart' show RailButton;
import 'package:rail_navigation/src/widgets/rail_overflow_button.dart'
    show RailOverflowButton;
import 'package:rail_navigation/src/widgets/rail_popover_tile.dart'
    show RailPopoverTile;

/// The fixed footprint used for every destination button, including
/// the overflow button.
///
/// 64x64 rather than the [RailButton] default of 48x48 because every
/// destination renders both an icon and a caption. The overflow button
/// uses the same size so the rail's geometry stays uniform whether or
/// not it appears.
const Size _kButtonSize = Size(64, 64);

/// The rail's destination buttons: one [RailButton] per member of
/// [visible], in order, followed — when [overflowed] is non-empty —
/// by a [RailOverflowButton] whose popover lists the [overflowed]
/// members as [RailPopoverTile]s.
///
/// The caller owns the partition. Which destinations are rail
/// buttons, which live in the overflow popover, and therefore whether
/// an overflow button exists at all are stated explicitly through
/// [visible] and [overflowed]; this widget measures nothing and
/// guesses nothing. When [overflowed] is empty, the rail is exactly a
/// row (or column) of [RailButton]s. When it is non-empty, the
/// overflow button always occupies the last slot, after every visible
/// button.
///
/// The caller also owns distribution. The rail fills its main axis
/// and spreads the buttons per [mainAxisAlignment] — [Axis.horizontal]
/// with the default [MainAxisAlignment.spaceEvenly] gives the standard
/// bottom-navigation layout, with equal breathing room around every
/// button at any screen width.
///
/// This is the single mapping site between destination data and
/// widgets. Each member's [RailDestinationEnum.iconData] and
/// [RailDestinationEnum.caption] are wrapped in an [Icon] and [Text]
/// here, whether the member renders as a rail button or a popover
/// tile — the rail widgets render content as provided, so styling is
/// applied at this site.
///
/// Selection behaves as a radio group owned by the parent: [selected]
/// names the current destination, and every path — rail button tap or
/// popover tile pick — reports its member through [onSelect]. The
/// radio-group invariant holds across the partition: when [selected]
/// is an overflowed member, the overflow button itself renders
/// selected, and its popover opens scrolled to the selected tile with
/// its highlight showing.
///
/// [visible] must not be empty, and no destination may appear in both
/// [visible] and [overflowed]. The constructor is const, so these are
/// enforced by debug assertions at first build rather than at
/// construction.
class RailDestinationButtons extends StatelessWidget {
  /// Creates the rail's destination buttons laid out along [direction].
  const RailDestinationButtons({
    required this.direction,
    required this.visible,
    required this.selected,
    required this.onSelect,
    super.key,
    this.overflowed = const <RailDestinationEnum>[],
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
  });

  /// The axis along which the buttons are laid out.
  ///
  /// Required rather than defaulted: the rail's placement dictates the
  /// axis, and this widget has no basis for guessing it. A bottom rail
  /// is [Axis.horizontal]; a side rail is [Axis.vertical].
  final Axis direction;

  /// The destinations rendered as rail buttons, in this order.
  ///
  /// The caller decides membership and order; typically the app's
  /// primary destinations. Must not be empty.
  final List<RailDestinationEnum> visible;

  /// The destinations folded into the overflow popover, in this order.
  ///
  /// Defaults to empty, in which case no overflow button is rendered.
  /// When non-empty, the overflow button is always the rail's last
  /// slot, after every [visible] button. Must not share a member with
  /// [visible].
  final List<RailDestinationEnum> overflowed;

  /// The currently selected destination.
  ///
  /// The button (or overflow popover tile) whose enum member equals
  /// this value shows its selection indicator; when the member is in
  /// [overflowed], the overflow button renders selected as well.
  final RailDestinationEnum selected;

  /// Called with the chosen destination's enum member, whether it was
  /// tapped as a rail button or picked from the overflow popover.
  ///
  /// Rail button taps report every tap, including taps on the
  /// already-selected destination; whether that is a no-op is the
  /// parent's call. Dismissing the popover without a pick reports
  /// nothing.
  final ValueChanged<RailDestinationEnum> onSelect;

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

  /// The rail button for [destination].
  Widget _railButton(RailDestinationEnum destination) => RailButton(
    size: _kButtonSize,
    isSelected: destination == selected,
    icon: Icon(destination.iconData),
    caption: Text(destination.caption),
    onPressed: () => onSelect(destination),
  );

  /// The popover tile for an overflowed [destination].
  Widget _popoverTile(RailDestinationEnum destination) =>
      RailPopoverTile<RailDestinationEnum>(
        value: destination,
        isSelected: destination == selected,
        icon: Icon(destination.iconData),
        label: Text(destination.caption),
      );

  @override
  Widget build(BuildContext context) {
    assert(
      visible.isNotEmpty,
      'visible must contain at least one destination',
    );
    assert(
      !visible.any(overflowed.contains),
      'A destination cannot be both visible and overflowed',
    );

    final selectedOverflowIndex = overflowed.indexOf(selected);

    return Flex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        for (final destination in visible) _railButton(destination),
        if (overflowed.isNotEmpty)
          RailOverflowButton<RailDestinationEnum>(
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
