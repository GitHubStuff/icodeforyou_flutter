// lib/src/widget/_more_inline.dart

part of '_internal.dart';

/// Toggles an inline expansion of overflow [RailMenuEntry]s.
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
  bool _expanded = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final theme = RailMenuTheme.of(context);
    final activeIndex = context.watch<RailMenuCubit>().activeIndex;
    final isActive = activeIndex >= widget.visibleCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _toggle,
          child: SizedBox(
            width: widget.railIcon.itemExtent,
            height: widget.railIcon.itemExtent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _expanded ? Icons.expand_less : Icons.more_vert,
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
        ),
        if (_expanded)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.overflowEntries.indexed
                .map(
                  (entry) => _RailItemTile(
                    entry: entry.$2,
                    index: widget.visibleCount + entry.$1,
                    railIcon: widget.railIcon,
                    haptic: widget.haptic,
                    direction: widget.direction,
                    transition: widget.transition,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
