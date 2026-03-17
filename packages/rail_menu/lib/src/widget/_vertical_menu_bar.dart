// packages/rail_menu/lib/src/widget/_vertical_menu_bar.dart

part of '_internal.dart';

/// Pure renderer for a left or right [RailMenu] bar.
class _VerticalMenuBar extends StatelessWidget {
  const _VerticalMenuBar({
    required this.visibleItems,
    required this.overflowItems,
    required this.dimensions,
    required this.activeColor,
    required this.cancelWidget,
  });

  final List<RailMenuItem> visibleItems;
  final List<RailMenuItem> overflowItems;
  final RailMenuDimensions dimensions;
  final Color activeColor;
  final Widget cancelWidget;

  bool _overflowIsActive(int activeIndex) =>
      activeIndex >= visibleItems.length;

  void _showMore(BuildContext context) => const _MoreModal().show(
        context: context,
        allItems: [...visibleItems, ...overflowItems],
        cancelWidget: cancelWidget,
      );

  @override
  Widget build(BuildContext context) {
    final activeIndex = context.watch<RailMenuCubit>().activeIndex;
    final overflowActive = _overflowIsActive(activeIndex);

    return SizedBox(
      width: dimensions.barExtent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...visibleItems.indexed.map(
            (entry) => _MenuItemTile(
              config: _TileConfig(
                item: entry.$2,
                index: entry.$1,
                itemExtent: dimensions.barExtent,
                barExtent: dimensions.itemExtent,
                activeColor: activeColor,
              ),
            ),
          ),
          if (overflowItems.isNotEmpty)
            _MoreButton(
              dimensions: dimensions,
              isActive: overflowActive,
              activeColor: activeColor,
              onTap: () => _showMore(context),
            ),
        ],
      ),
    );
  }
}
