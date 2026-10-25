// packages/app_navigation/lib/src/widgets/dock_row.dart

import 'package:app_navigation/app_navigation.dart' show NavButtonProperties;
import 'package:app_navigation/src/widgets/button_widget.dart' show NavButton;
import 'package:flutter/material.dart';

/// {@template dock_row}
/// A horizontal row of [NavButton]s for the bottom of the screen.
///
/// Renders [buttons] — typically `ButtonListManager.fitted()` — in list
/// order, evenly spaced across the available width, each with the
/// shared [size]. The row is wrapped in a bottom [SafeArea] so device
/// chrome (home indicator, gesture bar) never covers it.
///
/// Pure presentation. The row does not know which destination is
/// current or which buttons overflowed; the parent passes the single
/// button to draw as [highlighted] (the current destination, or the
/// `more` member when the current destination lives in overflow). Every
/// tap, including `more`, is reported unchanged through [onTap]; the
/// parent branches on `slot`.
///
/// Background, elevation, and selection state belong to the parent.
/// {@endtemplate}
class DockRow<T extends NavButtonProperties> extends StatelessWidget {
  /// {@macro dock_row}
  const DockRow({
    required this.buttons,
    required this.size,
    required this.onTap,
    this.highlighted,
    super.key,
  });

  /// Buttons to draw, in display order.
  final List<T> buttons;

  /// Footprint shared by every button in the row.
  final Size size;

  /// Invoked with the tapped item. `null` disables every button.
  final ValueChanged<T>? onTap;

  /// The one button drawn as selected, or `null` for none.
  final T? highlighted;

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
              NavButton<T>(
                key: ValueKey<T>(item),
                item: item,
                size: size,
                selected: item == highlighted,
                onTap: onTap,
              ),
          ],
        ),
      ),
    );
  }
}
