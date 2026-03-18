// lib/src/widget/_elevator_rail.dart

part of '_internal.dart';

/// Renders the menu bar along the left edge.
class _ElevatorRail extends StatelessWidget {
  const _ElevatorRail({
    required this.visibleEntries,
    required this.overflowEntries,
    required this.railIcon,
    required this.spacing,
    required this.haptic,
    required this.transition,
  });

  final List<RailMenuEntry> visibleEntries;
  final List<RailMenuEntry> overflowEntries;
  final RailIcon railIcon;
  final MenuIconSpacing spacing;
  final HapticIntensity haptic;
  final RailTransition transition;

  MainAxisAlignment get _alignment => spacing == MenuIconSpacing.expanded
      ? MainAxisAlignment.spaceEvenly
      : MainAxisAlignment.start;

  @override
  Widget build(BuildContext context) {
    final theme = RailMenuTheme.of(context);
    return Material(
      color: theme.backgroundColor,
      elevation: theme.elevation,
      child: SafeArea(
        right: false,
        child: SizedBox(
          width: railIcon.barExtent,
          child: Column(
            mainAxisAlignment: _alignment,
            children: [
              ...visibleEntries.indexed.map(
                (entry) => _RailItemTile(
                  entry: entry.$2,
                  index: entry.$1,
                  railIcon: railIcon,
                  haptic: haptic,
                  direction: RailDirection.vertical,
                  transition: transition,
                ),
              ),
              if (overflowEntries.isNotEmpty)
                _MoreInlineButton(
                  overflowEntries: overflowEntries,
                  visibleCount: visibleEntries.length,
                  railIcon: railIcon,
                  haptic: haptic,
                  transition: transition,
                  direction: RailDirection.vertical,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
