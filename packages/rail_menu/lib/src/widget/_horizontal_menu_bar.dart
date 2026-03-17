// packages/rail_menu/lib/src/widget/_horizontal_menu_bar.dart

part of '_internal.dart';

/// Pure renderer for a top or bottom [RailMenu] bar.
class _HorizontalMenuBar extends StatelessWidget {
  const _HorizontalMenuBar({
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
      height: dimensions.barExtent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...visibleItems.indexed.map(
            (entry) => _MenuItemTile(
              config: _TileConfig(
                item: entry.$2,
                index: entry.$1,
                itemExtent: dimensions.itemExtent,
                barExtent: dimensions.barExtent,
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

class _MoreButton extends StatelessWidget {
  const _MoreButton({
    required this.dimensions,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  final RailMenuDimensions dimensions;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isActive ? 1 : 0.75,
        child: SizedBox(
          width: dimensions.itemExtent,
          height: dimensions.barExtent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.more_horiz, size: dimensions.iconSize),
              Text('More', style: Theme.of(context).textTheme.labelSmall),
              Container(
                height: 3,
                width: dimensions.itemExtent,
                color: isActive ? activeColor : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
