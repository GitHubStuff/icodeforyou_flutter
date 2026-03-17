// packages/rail_menu/lib/src/model/rail_menu_dimensions.dart

/// Defines the visual sizing contract for a [RailMenu].
///
/// Use [RailMenuDimensions.defaults] for standard phone sizing,
/// or [RailMenuDimensions.large] for tablet and desktop sizing.
class RailMenuDimensions {
  /// Creates a [RailMenuDimensions].
  const RailMenuDimensions({
    required this.itemExtent,
    required this.iconSize,
    required this.barExtent,
  });

  /// Standard sizing for phone-sized screens.
  ///
  /// [itemExtent]: 56dp — [iconSize]: 24dp — [barExtent]: 64dp
  const RailMenuDimensions.defaults()
      : itemExtent = 56,
        iconSize = 24,
        barExtent = 64;

  /// Standard sizing for tablet and desktop screens.
  ///
  /// [itemExtent]: 64dp — [iconSize]: 28dp — [barExtent]: 72dp
  const RailMenuDimensions.large()
      : itemExtent = 64,
        iconSize = 28,
        barExtent = 72;

  /// The width (vertical bar) or height (horizontal bar) of each item slot.
  final double itemExtent;

  /// The rendered size of icons within each item slot.
  final double iconSize;

  /// The height (horizontal bar) or width (vertical bar) of the bar itself.
  final double barExtent;
}
