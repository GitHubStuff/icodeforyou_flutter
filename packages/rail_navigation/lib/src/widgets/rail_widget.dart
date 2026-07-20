// packages/rail_navigation/lib/src/widgets/rail_widget.dart

import 'package:flutter/material.dart';

/// The default cross-axis extent of a [RailWidget].
///
/// Matches the Material 3 convention of an 80dp-tall bottom navigation
/// bar and an 80dp-wide side navigation rail.
const double _kDefaultExtent = 80;

/// The default gap between adjacent children along the main axis.
const double _kDefaultSpacing = 8;

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
/// Set [direction] to [Axis.horizontal] for a bottom bar or
/// [Axis.vertical] for a side rail. Which of the two to use at a given
/// screen size is an adaptive-layout decision that belongs one layer up;
/// this widget simply obeys the axis it is given.
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
    this.direction = Axis.horizontal,
    this.alignment,
    this.spacing = _kDefaultSpacing,
    this.backgroundColor,
    this.extent = _kDefaultExtent,
  });

  /// The buttons (and any interleaved widgets such as dividers or
  /// spacers) to arrange along the main axis.
  final List<Widget> children;

  /// The main axis of the rail.
  ///
  /// [Axis.horizontal] lays children out as a bottom bar;
  /// [Axis.vertical] lays them out as a side rail. Defaults to
  /// [Axis.horizontal].
  final Axis direction;

  /// How children are distributed along the main axis.
  ///
  /// When `null`, defaults by [direction]:
  /// [MainAxisAlignment.spaceEvenly] for a horizontal bottom bar and
  /// [MainAxisAlignment.start] for a vertical side rail.
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

  /// The fixed cross-axis extent: the height of a horizontal bar or the
  /// width of a vertical rail.
  ///
  /// Defaults to [_kDefaultExtent] (80), the Material 3 convention.
  final double extent;

  @override
  Widget build(BuildContext context) {
    final resolvedColor =
        backgroundColor ?? Theme.of(context).colorScheme.surfaceContainer;
    final resolvedAlignment =
        alignment ??
        (direction == Axis.horizontal
            ? MainAxisAlignment.spaceEvenly
            : MainAxisAlignment.start);

    return Semantics(
      container: true,
      child: FocusTraversalGroup(
        child: Material(
          color: resolvedColor,
          child: SafeArea(
            top: direction == Axis.vertical,
            child: SizedBox(
              height: direction == Axis.horizontal ? extent : null,
              width: direction == Axis.vertical ? extent : null,
              child: Flex(
                direction: direction,
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