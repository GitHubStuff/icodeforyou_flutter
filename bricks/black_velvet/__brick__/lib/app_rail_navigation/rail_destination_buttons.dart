// programs/{{name.snakeCase()}}/lib/app_rail_navigation/rail_destination_buttons.dart

import 'package:flutter/material.dart';
import 'package:rail_navigation/rail_navigation.dart'
    show RailButton, RailOverflowButton, RailPopoverTile;

import 'rail_destination_enum.dart' show RailDestinationEnum;

/// The default footprint used for every destination button, including
/// the overflow button.
///
/// 80x60 rather than the [RailButton] default of 48x48 because every
/// destination renders both an icon and a caption. The overflow button
/// uses the same size so the rail's geometry stays uniform whether or
/// not it appears. A visible destination escapes this footprint only
/// through an explicit [RailDestinationButtons.sizeOverrides] entry.
const Size _kButtonSize = Size(80, 60);

/// {@template rail_destination_buttons}
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
/// column of [RailButton]s. When it is non-empty, the
/// overflow button always occupies the last slot, after every visible
/// button.
///
/// The caller also owns distribution. The rail fills its height and
/// places the buttons per [mainAxisAlignment]; the default
/// [MainAxisAlignment.start] gives the standard side-rail layout,
/// with the buttons clustered at the top rather than spread across
/// the full screen height.
///
/// The caller owns sizing too. Every button defaults to the uniform
/// 80x60 footprint; a visible destination that genuinely needs a
/// different footprint gets one through an explicit [sizeOverrides]
/// entry, declared as const data exactly like the partition itself.
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
/// [visible] must not be empty, no destination may appear in both
/// [visible] and [overflowed], and [sizeOverrides] may only name
/// members of [visible]. The constructor is const, so these are
/// enforced by debug assertions at first build rather than at
/// construction.
/// {@endtemplate}
class RailDestinationButtons extends StatelessWidget {
  /// {@macro rail_destination_buttons}
  const RailDestinationButtons({
    required this.visible,
    required this.selected,
    required this.onSelect,
    super.key,
    this.overflowed = const <RailDestinationEnum>[],
    this.sizeOverrides = const <RailDestinationEnum, Size>{},
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

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

  /// Per-destination size overrides for visible rail buttons.
  ///
  /// Defaults to empty: every button, including the overflow button,
  /// renders at the uniform 80x60 footprint. An entry replaces that
  /// footprint for its destination's rail button only — popover tiles
  /// size themselves, and the overflow button always keeps the uniform
  /// footprint — so every key must be a member of [visible].
  ///
  /// Prefer the uniform rail; this is the escape hatch for the rare
  /// destination whose content genuinely needs different geometry, not
  /// a styling knob to reach for by default.
  final Map<RailDestinationEnum, Size> sizeOverrides;

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

  /// How the buttons are placed along the rail's height.
  ///
  /// The rail fills its height, so alignments have room to work with.
  /// Defaults to [MainAxisAlignment.start], the standard side-rail
  /// placement: buttons clustered at the top, per Material's
  /// `NavigationRail` convention. [MainAxisAlignment.center] is the
  /// usual alternative; the distribution alignments
  /// ([MainAxisAlignment.spaceEvenly] and friends) spread the buttons
  /// across the full screen height, which side rails rarely want.
  final MainAxisAlignment mainAxisAlignment;

  /// The rail button for [destination], sized by its [sizeOverrides]
  /// entry when one exists and [_kButtonSize] otherwise.
  Widget _railButton(RailDestinationEnum destination) => RailButton(
    size: sizeOverrides[destination] ?? _kButtonSize,
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
    assert(
      sizeOverrides.keys.every(visible.contains),
      'sizeOverrides may only name members of visible',
    );

    final selectedOverflowIndex = overflowed.indexOf(selected);

    return Column(
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
