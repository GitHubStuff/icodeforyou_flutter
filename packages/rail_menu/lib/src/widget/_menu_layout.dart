// packages/rail_menu/lib/src/widget/_menu_layout.dart

part of '_internal.dart';

/// Measures available extent, splits items, delegates to [_MenuBarRouter].
class _MenuLayout extends StatelessWidget {
  const _MenuLayout({
    required this.direction,
    required this.items,
    required this.dimensions,
    required this.activeColor,
    required this.cancelWidget,
    this.limit,
  });

  final RailMenuDirection direction;
  final List<RailMenuItem> items;
  final RailMenuDimensions dimensions;
  final Color activeColor;
  final Widget cancelWidget;
  final int? limit;

  bool get _isHorizontal =>
      direction == RailMenuDirection.top ||
      direction == RailMenuDirection.bottom;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableExtent =
            _isHorizontal ? constraints.maxWidth : constraints.maxHeight;

        final result = const _OverflowCalculator().calculate(
          itemCount: items.length,
          itemExtent: dimensions.itemExtent,
          availableExtent: availableExtent,
          limit: limit,
        );

        final visibleItems = items.sublist(0, result.visibleCount);
        final overflowItems = result.hasOverflow
            ? items.sublist(result.visibleCount)
            : <RailMenuItem>[];

        return _MenuBarRouter(
          direction: direction,
          visibleItems: visibleItems,
          overflowItems: overflowItems,
          dimensions: dimensions,
          activeColor: activeColor,
          cancelWidget: cancelWidget,
        );
      },
    );
  }
}
