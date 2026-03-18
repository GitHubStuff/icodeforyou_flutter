// lib/src/widget/_more_bottom_sheet.dart

part of '_internal.dart';

/// Presents overflow [RailMenuEntry]s in a modal bottom sheet.
///
/// Used by [_HorizontalRail] when entries exceed available width.
class _MoreBottomSheet {
  const _MoreBottomSheet();

  void show({
    required BuildContext context,
    required List<RailMenuEntry> overflowEntries,
    required int visibleCount,
    required RailIcon railIcon,
    required HapticIntensity haptic,
    required RailTransition transition,
    required RailDirection direction,
  }) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<RailMenuCubit>(),
        child: BlocBuilder<RailMenuCubit, RailMenuState>(
          builder: (context, state) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: overflowEntries.indexed
                  .map((entry) {
                    final resolvedIndex = visibleCount + entry.$1;
                    final isActive = state.activeIndex == resolvedIndex;
                    final theme = RailMenuTheme.of(context);
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
                        final cubit = context.read<RailMenuCubit>();
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
    );
  }
}
