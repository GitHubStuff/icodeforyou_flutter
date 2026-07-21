// packages/rail_navigation/lib/src/widgets/rail_widget.dart

import 'package:flutter/material.dart';

/// The default cross-axis extent of a [RailWidget].
///
/// Matches the Material 3 convention of an 80dp-tall bottom navigation
/// bar and an 80dp-wide side navigation rail.
const double _kDefaultExtent = 80;

/// The default gap between adjacent children along the main axis.
const double _kDefaultSpacing = 8;

/// Where a [RailWidget] is anchored on the screen.
///
/// Placement determines both the layout axis and which safe-area
/// insets the rail consumes. A rail only respects the insets of the
/// screen edges it actually touches; in particular, a [left] rail
/// ignores the right-hand inset (and vice versa), so a notch in
/// landscape pads only the anchored side.
enum RailPlacement {
  /// Anchored along the bottom edge; children are laid out
  /// horizontally. Respects the bottom, left, and right insets.
  bottom,

  /// Anchored along the left edge; children are laid out vertically.
  /// Respects the top, bottom, and left insets.
  left,

  /// Anchored along the right edge; children are laid out vertically.
  /// Respects the top, bottom, and right insets.
  right;

  /// The main axis children are laid out along for this placement.
  Axis get axis => this == bottom ? Axis.horizontal : Axis.vertical;
}

/// A layout container that arranges navigation buttons along the bottom
/// or side of a screen.
///
/// A [RailWidget] is layout only: it owns its surface, safe-area
/// insets, fixed cross-axis [extent], child arrangement, and semantics
/// grouping — and nothing else. It does not manage selection. Radio-group
/// behavior (exactly one selected button) is the parent's responsibility:
/// the parent tracks the selected index and rebuilds each child with the
/// appropriate `isSelected` and `onPressed` values.
///
/// [placement] positions the rail: [RailPlacement.bottom] for a bottom
/// bar, [RailPlacement.left] or [RailPlacement.right] for a side rail.
/// Which placement to use at a given screen size is an adaptive-layout
/// decision that belongs one layer up; this widget simply obeys the
/// placement it is given, consuming only the safe-area insets of the
/// edges it touches.
///
/// [children] is deliberately typed as `List<Widget>` rather than a list
/// of `RailButton`s so callers can interleave dividers, spacers, or
/// badge-wrapped buttons. Overflow is handled explicitly by convention:
/// the caller decides which destinations are visible and gathers the
/// rest behind a `MoreRailButton`.
class RailWidget extends StatelessWidget {
  /// Creates a [RailWidget].
  const RailWidget({
    required this.children,
    super.key,
    this.placement = RailPlacement.bottom,
    this.alignment,
    this.spacing = _kDefaultSpacing,
    this.backgroundColor,
    this.extent = _kDefaultExtent,
  });

  /// The buttons (and any interleaved widgets such as dividers or
  /// spacers) to arrange along the main axis.
  final List<Widget> children;

  /// Where the rail is anchored on the screen.
  ///
  /// Determines the layout axis and which safe-area insets are
  /// consumed. Defaults to [RailPlacement.bottom].
  final RailPlacement placement;

  /// How children are distributed along the main axis.
  ///
  /// When `null`, defaults by [placement]:
  /// [MainAxisAlignment.spaceEvenly] for a bottom bar and
  /// [MainAxisAlignment.start] for a side rail.
  final MainAxisAlignment? alignment;

  /// The gap between adjacent children along the main axis.
  ///
  /// Only visually significant when [alignment] packs children
  /// together (for example [MainAxisAlignment.start]). Defaults to
  /// [_kDefaultSpacing].
  final double spacing;

  /// The surface color behind the buttons.
  ///
  /// When `null`, falls back to
  /// `Theme.of(context).colorScheme.surfaceContainer`, the Material 3
  /// navigation surface color.
  final Color? backgroundColor;

  /// The fixed cross-axis extent: the height of a bottom bar or the
  /// width of a side rail.
  ///
  /// Defaults to [_kDefaultExtent] (80), the Material 3 convention.
  /// Safe-area insets on the anchored side are added outside this
  /// extent, so content keeps its full [extent] clear of notches and
  /// the home indicator.
  final double extent;

  @override
  Widget build(BuildContext context) {
    final resolvedColor =
        backgroundColor ?? Theme.of(context).colorScheme.surfaceContainer;
    final resolvedAlignment =
        alignment ??
        (placement == RailPlacement.bottom
            ? MainAxisAlignment.spaceEvenly
            : MainAxisAlignment.start);

    return Semantics(
      container: true,
      child: FocusTraversalGroup(
        child: Material(
          color: resolvedColor,
          child: SafeArea(
            top: placement != RailPlacement.bottom,
            left: placement != RailPlacement.right,
            right: placement != RailPlacement.left,
            child: SizedBox(
              height: placement.axis == Axis.horizontal ? extent : null,
              width: placement.axis == Axis.vertical ? extent : null,
              child: Flex(
                direction: placement.axis,
                mainAxisAlignment: resolvedAlignment,
                spacing: spacing,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
