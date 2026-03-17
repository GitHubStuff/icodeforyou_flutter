// packages/rail_menu/lib/src/widget/_menu_item_tile.dart

part of '_internal.dart';

/// Renders a single [RailMenuItem] in the bar.
///
/// Owns: active indicator bar, opacity, no-op guard, haptic, tap forwarding.
/// Delegates animation to [_PulseAnimator].
class _MenuItemTile extends StatefulWidget {
  const _MenuItemTile({required this.config});

  final _TileConfig config;

  @override
  State<_MenuItemTile> createState() => _MenuItemTileState();
}

class _MenuItemTileState extends State<_MenuItemTile> {
  bool _pulse = false;

  bool _isActive(int activeIndex) => widget.config.index == activeIndex;

  void _handleTap(BuildContext context, int activeIndex) {
    if (_isActive(activeIndex)) return;
    if (widget.config.item.enableHaptic) {
      unawaited(HapticFeedback.lightImpact());
    }
    setState(() => _pulse = true);
    unawaited(
      Future.microtask(() {
        if (mounted) setState(() => _pulse = false);
      }),
    );
    widget.config.item.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = context.watch<RailMenuCubit>().activeIndex;
    final isActive = _isActive(activeIndex);

    return GestureDetector(
      onTap: () => _handleTap(context, activeIndex),
      child: SizedBox(
        width: widget.config.itemExtent,
        height: widget.config.barExtent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: isActive ? 1 : 0.75,
              child: PulseWidget(
                trigger: _pulse,
                child: widget.config.item.child,
              ),
            ),
            Container(
              height: 3,
              width: widget.config.itemExtent,
              color: isActive ? widget.config.activeColor : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
