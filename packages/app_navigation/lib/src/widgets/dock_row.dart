// packages/app_navigation/lib/src/widgets/dock_row.dart

import 'package:app_navigation/app_navigation.dart'
    show NavButtonProperties, NavSlot;
import 'package:app_navigation/src/widgets/nav_button.dart' show NavButton;
import 'package:app_navigation/src/widgets/more_nav_button.dart'
    show MoreNavButton;
import 'package:flutter/material.dart';

/// {@template dock_row}
/// A horizontal row of buttons for the bottom of the screen.
///
/// Renders [buttons] in list order, evenly spaced across the available
/// width, each with the shared [size]. The row is wrapped in a bottom
/// [SafeArea] so device chrome (home indicator, gesture bar) never
/// covers it.
///
/// Every button is a [NavButton] except the one whose slot is
/// [NavSlot.more], which becomes a [MoreNavButton] anchored to a popover
/// listing [overflow]. The button equal to [selected] is drawn
/// selected; the `more` button draws itself selected when [selected]
/// lives in [overflow].
///
/// Every chosen destination — tapped on the row or picked from the
/// popover — is reported unchanged through [onTap]. The `more` button
/// itself is never reported; it opens the popover and nothing else.
///
/// Background and elevation belong to the parent.
/// {@endtemplate}
class DockRow<T extends NavButtonProperties> extends StatelessWidget {
  /// {@macro dock_row}
  const DockRow({
    required this.buttons,
    required this.overflow,
    required this.size,
    required this.onTap,
    this.selected,
    super.key,
  });

  /// Buttons to draw, in display order. At most one has [NavSlot.more].
  final List<T> buttons;

  /// Destinations listed in the `more` popover, in display order. Empty
  /// when [buttons] has no `more`.
  final List<T> overflow;

  /// Footprint shared by every button in the row.
  final Size size;

  /// Invoked with the chosen destination. `null` disables every button.
  final ValueChanged<T>? onTap;

  /// The current destination, or `null` for none.
  final T? selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: size.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final item in buttons)
              if (item.slot == NavSlot.more)
                MoreNavButton<T>(
                  key: ValueKey<T>(item),
                  item: item,
                  size: size,
                  overflow: overflow,
                  selected: selected,
                  onSelect: onTap,
                )
              else
                NavButton<T>(
                  key: ValueKey<T>(item),
                  item: item,
                  size: size,
                  selected: item == selected,
                  onTap: onTap,
                ),
          ],
        ),
      ),
    );
  }
}
