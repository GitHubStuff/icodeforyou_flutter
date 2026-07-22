// packages/rail_navigation/lib/src/widgets/rail_popover_tile.dart

import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';

/// The fixed height of a tile.
///
/// Matches the popover's scroll-tick extent so one haptic tick fires
/// per tile scrolled past, and meets the Material minimum touch target.
const double _kTileHeight = 48;

/// Horizontal padding at the tile's edges.
const double _kTilePadding = 16;

/// The gap between the icon and the label.
const double _kIconLabelGap = 12;

/// A full-width row for use inside a `showRailPopover` list.
///
/// Displays an optional leading [icon] and a [label], laid out
/// horizontally — the list-row shape, as opposed to a `RailButton`'s
/// compact vertical stack. Tapping the tile triggers [hapticIntensity]
/// and then pops the popover with [value], completing the future
/// returned by `showRailPopover<T>` with that value.
///
/// When [isSelected] is `true`, the row is highlighted in [tint] —
/// the same selection language `RailButton` uses, so the currently
/// active overflow destination reads the same way as an active rail
/// button. The child widgets themselves are never recolored.
///
/// The type parameter [T] must match the type parameter of the
/// enclosing `showRailPopover<T>` call.
class RailPopoverTile<T> extends StatelessWidget {
  /// Creates a [RailPopoverTile].
  const RailPopoverTile({
    required this.value,
    required this.label,
    super.key,
    this.icon,
    this.isSelected = false,
    this.tint,
    this.hapticIntensity = HapticIntensity.light,
  });

  /// The value the popover's future completes with when this tile is
  /// tapped.
  final T value;

  /// The tile's text, displayed after [icon].
  ///
  /// Rendered as provided; this widget never restyles it.
  final Widget label;

  /// An optional leading icon.
  ///
  /// Rendered as provided; this widget never recolors it.
  final Widget? icon;

  /// Whether this tile's destination is the currently active one.
  ///
  /// Defaults to `false`. When `true`, the row is highlighted in
  /// [tint]. Selection is owned by the parent, exactly as with
  /// `RailButton`.
  final bool isSelected;

  /// The highlight color shown when [isSelected] is `true`.
  ///
  /// When `null`, falls back to
  /// `Theme.of(context).colorScheme.secondaryContainer`, matching
  /// `RailButton.tint`.
  final Color? tint;

  /// The haptic feedback triggered on tap, immediately before the
  /// popover pops with [value].
  ///
  /// Defaults to [HapticIntensity.light]. Use [HapticIntensity.none]
  /// to disable haptics for this tile.
  final HapticIntensity hapticIntensity;

  @override
  Widget build(BuildContext context) {
    final resolvedTint =
        tint ?? Theme.of(context).colorScheme.secondaryContainer;

    return Semantics(
      button: true,
      selected: isSelected,
      child: Ink(
        color: isSelected ? resolvedTint : null,
        child: InkWell(
          onTap: hapticIntensity.wrap(() {
            Navigator.pop<T>(context, value);
          }),
          child: SizedBox(
            height: _kTileHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _kTilePadding),
              child: Row(
                spacing: _kIconLabelGap,
                children: [
                  if (icon != null) icon!,
                  Expanded(child: label),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
