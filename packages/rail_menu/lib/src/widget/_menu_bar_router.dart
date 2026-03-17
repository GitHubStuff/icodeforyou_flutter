// packages/rail_menu/lib/src/widget/_menu_bar_router.dart

part of '_internal.dart';

/// Routes to the correct bar widget based on [direction].
class _MenuBarRouter extends StatelessWidget {
  const _MenuBarRouter({
    required this.direction,
    required this.visibleItems,
    required this.overflowItems,
    required this.dimensions,
    required this.activeColor,
    required this.cancelWidget,
  });

  final RailMenuDirection direction;
  final List<RailMenuItem> visibleItems;
  final List<RailMenuItem> overflowItems;
  final RailMenuDimensions dimensions;
  final Color activeColor;
  final Widget cancelWidget;

  @override
  Widget build(BuildContext context) {
    switch (direction) {
      case RailMenuDirection.top:
      case RailMenuDirection.bottom:
        return _HorizontalMenuBar(
          visibleItems: visibleItems,
          overflowItems: overflowItems,
          dimensions: dimensions,
          activeColor: activeColor,
          cancelWidget: cancelWidget,
        );
      case RailMenuDirection.left:
      case RailMenuDirection.right:
        return _VerticalMenuBar(
          visibleItems: visibleItems,
          overflowItems: overflowItems,
          dimensions: dimensions,
          activeColor: activeColor,
          cancelWidget: cancelWidget,
        );
    }
  }
}
