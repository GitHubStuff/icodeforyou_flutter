// lib/src/widget/_more_inline.dart

part of '_internal.dart';

/// Fraction of screen width used by the overflow flyout menu.
const double _kFlyoutWidthFraction = 0.15;

/// Shows a flyout popup anchored to the right of the More button.
///
/// Used by [_ElevatorRail] when entries exceed available height.
class _MoreInlineButton extends StatefulWidget {
  const _MoreInlineButton({
    required this.overflowEntries,
    required this.visibleCount,
    required this.railIcon,
    required this.haptic,
    required this.transition,
    required this.direction,
  });

  final List<RailMenuEntry> overflowEntries;
  final int visibleCount;
  final RailIcon railIcon;
  final HapticIntensity haptic;
  final RailTransition transition;
  final RailDirection direction;

  @override
  State<_MoreInlineButton> createState() => _MoreInlineButtonState();
}

class _MoreInlineButtonState extends State<_MoreInlineButton> {
  final GlobalKey<State<StatefulWidget>> _key = GlobalKey();

  void _showFlyout(BuildContext context) {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final position = box.localToGlobal(Offset.zero);
    final size = box.size;
    final cubit = context.read<RailMenuCubit>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final menuWidth = screenWidth * _kFlyoutWidthFraction;
    final left = position.dx + size.width;

    unawaited(
      showMenu<void>(
        context: context,
        constraints: BoxConstraints(minWidth: menuWidth, maxWidth: menuWidth),
        position: RelativeRect.fromLTRB(
          left,
          position.dy,
          screenWidth - left,
          0,
        ),
        items: widget.overflowEntries.indexed.map((entry) {
          final resolvedIndex = widget.visibleCount + entry.$1;
          return PopupMenuItem<void>(
            padding: EdgeInsets.zero,
            child: BlocProvider.value(
              value: cubit,
              child: BlocBuilder<RailMenuCubit, RailMenuState>(
                builder: (context, state) {
                  final isActive = state.activeIndex == resolvedIndex;
                  final theme = RailMenuTheme.of(context);
                  return ListTile(
                    leading: Icon(
                      isActive ? entry.$2.activeIcon : entry.$2.icon,
                      size: widget.railIcon.iconSize,
                      color: isActive ? theme.activeColor : theme.inactiveColor,
                    ),
                    title: Text(
                      entry.$2.label,
                      style: TextStyle(
                        color: isActive
                            ? theme.activeColor
                            : theme.inactiveColor,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      final resolvedTransition =
                          widget.transition == RailTransition.slideDirectional
                          ? cubit.resolveDirectional(
                              tappedIndex: resolvedIndex,
                              direction: widget.direction,
                            )
                          : widget.transition;
                      cubit.setActive(resolvedIndex, resolvedTransition);
                    },
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = RailMenuTheme.of(context);
    final activeIndex = context.watch<RailMenuCubit>().activeIndex;
    final isActive = activeIndex >= widget.visibleCount;

    return GestureDetector(
      key: _key,
      onTap: () => _showFlyout(context),
      child: SizedBox(
        width: widget.railIcon.itemExtent,
        height: widget.railIcon.itemExtent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.more_vert,
              size: widget.railIcon.iconSize,
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
            SizedBox(height: widget.railIcon.indicatorHeight),
            Container(
              height: widget.railIcon.indicatorHeight,
              color: isActive ? theme.activeColor : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
