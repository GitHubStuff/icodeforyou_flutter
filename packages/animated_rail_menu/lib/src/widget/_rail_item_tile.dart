// lib/src/widget/_rail_item_tile.dart

part of '_internal.dart';

/// Renders a single [RailMenuEntry] — icon, label, and active indicator bar.
class _RailItemTile extends StatelessWidget {
  const _RailItemTile({
    required this.entry,
    required this.index,
    required this.railIcon,
    required this.haptic,
    required this.direction,
    required this.transition,
  });

  final RailMenuEntry entry;
  final int index;
  final RailIcon railIcon;
  final HapticIntensity haptic;
  final RailDirection direction;
  final RailTransition transition;

  bool _isActive(int activeIndex) => index == activeIndex;

  RailTransition _resolvedTransition(BuildContext context) {
    if (transition != RailTransition.slideDirectional) return transition;
    return context.read<RailMenuCubit>().resolveDirectional(
          tappedIndex: index,
          direction: direction,
        );
  }

  void _handleTap(BuildContext context, int activeIndex) {
    if (_isActive(activeIndex)) return;
    _triggerHaptic();
    context
        .read<RailMenuCubit>()
        .setActive(index, _resolvedTransition(context));
  }

  void _triggerHaptic() {
    switch (haptic) {
      case HapticIntensity.none:
        break;
      case HapticIntensity.light:
        unawaited(HapticFeedback.lightImpact());
      case HapticIntensity.medium:
        unawaited(HapticFeedback.mediumImpact());
      case HapticIntensity.heavy:
        unawaited(HapticFeedback.heavyImpact());
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = context.watch<RailMenuCubit>().activeIndex;
    final isActive = _isActive(activeIndex);
    final theme = RailMenuTheme.of(context);

    return GestureDetector(
      onTap: () => _handleTap(context, activeIndex),
      child: SizedBox(
        width: railIcon.itemExtent,
        height: railIcon.itemExtent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? entry.activeIcon : entry.icon,
              size: railIcon.iconSize,
              color: isActive ? theme.activeColor : theme.inactiveColor,
            ),
            Text(
              entry.label,
              style: theme.labelStyle.copyWith(
                color: isActive ? theme.activeColor : theme.inactiveColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: railIcon.indicatorHeight),
            Container(
              height: railIcon.indicatorHeight,
              width: railIcon.itemExtent,
              color: isActive ? theme.activeColor : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
