// programs/template_app/lib/screens/rail/rails.dart

import 'package:extensions/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:rail_navigation/rail_navigation.dart'
    show
        MainRailButton,
        RailPlacement,
        RailShell,
        RailTransition,
        SettingsRailButton;
import 'package:template_app/screens/rail/rail_destination_enum.dart'
    show RailDestinationEnum;

/// One rail destination: the [RailDestinationEnum] that names it paired with the
/// [widget] shown when it is selected.
///
/// Pairing both in a single object is what keeps a button and its screen
/// together; nothing downstream has to hold two lists in the same order.
final class RailContent {
  /// Creates a [RailContent].
  const RailContent({required this.identifier, required this.widget});

  /// The destination this content belongs to.
  final RailDestinationEnum identifier;

  /// The screen shown when [identifier] is selected.
  final Widget widget;
}

/// The app's rail navigation shell.
///
/// `RailShell` displays but never decides, so selection is owned here: this
/// widget holds the selected [RailDestinationEnum] and rebuilds the shell
/// with a new index and fresh `isSelected` flags.
///
/// [contents] is the single source of order. Buttons and screens are both
/// derived from it, and the visible index is looked up by identifier rather
/// than taken from [Enum.index], so listing destinations out of enum order —
/// or listing only some of them — stays correct.
class Rails extends StatefulWidget {
  /// Creates a [Rails].
  const Rails({
    required this.selection,
    required this.placement,
    required this.transition,
    required this.haptics,
    required this.contents,
    super.key,
  });

  /// The destination selected on first build.
  ///
  /// Must appear in [contents].
  final RailDestinationEnum selection;

  /// The haptic fired by every rail button on tap.
  final HapticIntensity haptics;

  /// Which screen edge the rail is anchored to.
  final RailPlacement placement;

  /// How screens animate when the selection changes.
  final RailTransition transition;

  /// The destinations, in rail order. Each contributes one button and one
  /// screen.
  final List<RailContent> contents;

  @override
  State<Rails> createState() => _RailsState();
}

class _RailsState extends State<Rails> {
  /// The destination currently displayed.
  late RailDestinationEnum _selected = widget.selection;

  /// Selects [item], redrawing the rail and swapping the screen.
  void _select(RailDestinationEnum item) => setState(() => _selected = item);

  /// The rail button for [identifier], wired to [_select].
  ///
  /// Exhaustive over [RailDestinationEnum] with no default arm, so a new
  /// destination is a compile error here until its button is supplied.
  Widget _buttonFor(RailDestinationEnum identifier) {
    final isSelected = identifier == _selected;
    return switch (identifier) {
      //-
      .main => MainRailButton(
        isSelected: isSelected,
        onPressed: () => _select(RailDestinationEnum.main),
        hapticIntensity: widget.haptics,
      ),
      //-
      .settings => SettingsRailButton(
        isSelected: isSelected,
        onPressed: () => _select(RailDestinationEnum.settings),
        hapticIntensity: widget.haptics,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final index = widget.contents.indexWhere(
      (content) => content.identifier == _selected,
    );
    assert(index >= 0, 'No RailContent supplied for $_selected.');

    return RailShell(
      placement: widget.placement,
      transition: widget.transition,
      currentIndex: index,
      railChildren: [
        for (final content in widget.contents) _buttonFor(content.identifier),
      ],
      screens: [for (final content in widget.contents) content.widget],
    );
  }
}
