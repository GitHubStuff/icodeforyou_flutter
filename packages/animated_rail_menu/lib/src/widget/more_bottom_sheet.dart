// animated_rail_menu/lib/src/widget/more_bottom_sheet.dart

part of 'animated_rail_menu_widget.dart';

/// Presents overflow [AnimatedRailMenuEntry]s in a modal bottom sheet.
///
/// Used by [_HorizontalRail] when entries exceed available width.
class _MoreBottomSheet {
  const _MoreBottomSheet();

  void show({
    required BuildContext context,
    required List<AnimatedRailMenuEntry> overflowEntries,
    required int visibleCount,
    required RailIcon railIcon,
    required HapticIntensity haptic,
    required RailTransition transition,
    required RailDirection direction,
  }) {
    unawaited(showModalBottomSheet<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AnimatedRailMenuCubit>(),
        child: BlocBuilder<AnimatedRailMenuCubit, AnimatedRailMenuState>(
          builder: (context, state) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: overflowEntries.indexed
                  .map((entry) {
                    final resolvedIndex = visibleCount + entry.$1;
                    final isActive = state.activeIndex == resolvedIndex;
                    final theme = AnimatedRailMenuTheme.of(context);
                    return ListTile(
                      leading: Icon(
                        isActive ? entry.$2.activeIcon : entry.$2.icon,
                        size: railIcon.iconSize,
                        color:
                            isActive ? theme.activeColor : theme.inactiveColor,
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
                        final cubit = context.read<AnimatedRailMenuCubit>();
                        final resolvedTransition =
                            transition == RailTransition.slideDirectional
                                ? cubit.resolveDirectional(
                                    tappedIndex: resolvedIndex,
                                    direction: direction,
                                  )
                                : transition;
                        cubit.setActive(resolvedIndex, resolvedTransition);
                      },
                    );
                  })
                  .toList(),
            ),
          ),
        ),
      ),
    ));
  }
}
