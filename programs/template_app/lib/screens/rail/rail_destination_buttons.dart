// packages/rail_navigation/lib/src/widgets/rail_destination_buttons.dart

import 'package:flutter/material.dart';
import 'package:rail_navigation/rail_navigation.dart' show RailButton;
import 'package:template_app/screens/rail/rail_destination_enum.dart'
    show RailDestinationEnum;

/// The fixed footprint used for every destination button.
///
/// 64x64 rather than the [RailButton] default of 48x48 because every
/// destination renders both an icon and a caption.
const Size _kButtonSize = Size(64, 64);

/// The full set of rail destination buttons, one [RailButton] per
/// [RailDestinationEnum] member, laid out along [direction].
///
/// This is the single mapping site between destination data and button
/// widgets. Each member's [RailDestinationEnum.iconData] and
/// [RailDestinationEnum.caption] are wrapped in an [Icon] and [Text]
/// here — [RailButton] renders them as provided and never recolors
/// them, so any styling the rail wants is applied at this site.
///
/// Layout is owned by the caller: the rail's placement determines the
/// axis, so a bottom rail passes [Axis.horizontal] and a side rail
/// passes [Axis.vertical]. This widget imposes no opinion of its own;
/// it lays the buttons along whatever [direction] it is given.
///
/// Selection behaves as a radio group owned by the parent: [selected]
/// names the current destination, each button's `isSelected` is derived
/// from enum equality, and tapping any button reports its member
/// through [onSelect]. Tapping the already-selected destination still
/// invokes [onSelect]; whether that is a no-op is the parent's call.
///
/// Adding a destination requires no change to this file: new
/// [RailDestinationEnum] members appear automatically in declaration
/// order.
class RailDestinationButtons extends StatelessWidget {
  /// Creates the rail's destination buttons laid out along [direction].
  const RailDestinationButtons({
    required this.direction,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  /// The axis along which the buttons are laid out.
  ///
  /// Required rather than defaulted: the rail's placement dictates the
  /// axis, and this widget has no basis for guessing it. A bottom rail
  /// is [Axis.horizontal]; a side rail is [Axis.vertical].
  final Axis direction;

  /// The currently selected destination.
  ///
  /// The button whose enum member equals this value paints its
  /// selection indicator.
  final RailDestinationEnum selected;

  /// Called with the tapped destination's enum member.
  ///
  /// Invoked after the button's haptic feedback, for every tap —
  /// including taps on the already-selected destination.
  final ValueChanged<RailDestinationEnum> onSelect;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: direction,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final destination in RailDestinationEnum.values)
          RailButton(
            size: _kButtonSize,
            isSelected: destination == selected,
            icon: Icon(destination.iconData),
            caption: Text(destination.caption),
            onPressed: () => onSelect(destination),
          ),
      ],
    );
  }
}
