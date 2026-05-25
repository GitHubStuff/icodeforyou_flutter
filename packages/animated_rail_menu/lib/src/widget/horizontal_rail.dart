// animated_rail_menu/lib/src/widget/horizontal_rail.dart

part of 'animated_rail_menu_widget.dart';

/// Renders the menu bar along the bottom edge.
class _HorizontalRail extends StatelessWidget {
  const _HorizontalRail({
    required this.visibleEntries,
    required this.overflowEntries,
    required this.railIcon,
    required this.spacing,
    required this.haptic,
    required this.transition,
  });

  final List<AnimatedRailMenuEntry> visibleEntries;
  final List<AnimatedRailMenuEntry> overflowEntries;
  final RailIcon railIcon;
  final MenuIconSpacing spacing;
  final HapticIntensity haptic;
  final RailTransition transition;

  MainAxisAlignment get _alignment => spacing == MenuIconSpacing.expanded
      ? MainAxisAlignment.spaceEvenly
      : MainAxisAlignment.start;

  void _showMore(BuildContext context) => const _MoreBottomSheet().show(
        context: context,
        overflowEntries: overflowEntries,
        visibleCount: visibleEntries.length,
        railIcon: railIcon,
        haptic: haptic,
        transition: transition,
        direction: RailDirection.horizontal,
      );

  @override
  Widget build(BuildContext context) {
    final theme = AnimatedRailMenuTheme.of(context);
    return Material(
      color: theme.backgroundColor,
      elevation: theme.elevation,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: railIcon.barExtent,
          child: Row(
            mainAxisAlignment: _alignment,
            children: [
              ...visibleEntries.indexed.map(
                (entry) => _RailItemTile(
                  entry: entry.$2,
                  index: entry.$1,
                  railIcon: railIcon,
                  haptic: haptic,
                  direction: RailDirection.horizontal,
                  transition: transition,
                ),
              ),
              if (overflowEntries.isNotEmpty)
                _MoreHorizontalButton(
                  railIcon: railIcon,
                  visibleCount: visibleEntries.length,
                  onTap: () => _showMore(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreHorizontalButton extends StatelessWidget {
  const _MoreHorizontalButton({
    required this.railIcon,
    required this.visibleCount,
    required this.onTap,
  });

  final RailIcon railIcon;
  final int visibleCount;
  final VoidCallback onTap;

  bool _isActive(int activeIndex) => activeIndex >= visibleCount;

  @override
  Widget build(BuildContext context) {
    final theme = AnimatedRailMenuTheme.of(context);
    final activeIndex = context.watch<AnimatedRailMenuCubit>().activeIndex;
    final isActive = _isActive(activeIndex);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: railIcon.itemExtent,
        height: railIcon.itemExtent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.more_horiz,
              size: railIcon.iconSize,
              color: isActive ? theme.activeColor : theme.inactiveColor,
            ),
            Text(
              'More',
              style: theme.labelStyle.copyWith(
                color: isActive ? theme.activeColor : theme.inactiveColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: railIcon.indicatorHeight),
            Container(
              height: railIcon.indicatorHeight,
              color: isActive ? theme.activeColor : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
