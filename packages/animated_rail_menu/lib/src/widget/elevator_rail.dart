// animated_rail_menu/lib/src/widget/elevator_rail.dart

part of 'animated_rail_menu_widget.dart';

/// Minimum top padding applied to the elevator rail to clear device corner
/// radius clipping. 32dp covers iPhone 17 Pro and comparable devices.
const double _kElevatorTopMinimum = 32;

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

  final List<AnimatedRailMenuEntry> visibleEntries;
  final List<AnimatedRailMenuEntry> overflowEntries;
  final RailIcon railIcon;
  final MenuIconSpacing spacing;
  final HapticIntensity haptic;
  final RailTransition transition;

  MainAxisAlignment get _alignment => spacing == MenuIconSpacing.expanded
      ? MainAxisAlignment.spaceEvenly
      : MainAxisAlignment.start;

  @override
  Widget build(BuildContext context) {
    final theme = AnimatedRailMenuTheme.of(context);
    return Material(
      color: theme.backgroundColor,
      elevation: theme.elevation,
      child: SafeArea(
        left: false,
        right: false,
        minimum: const EdgeInsets.only(top: _kElevatorTopMinimum),
        child: SizedBox(
          width: railIcon.barExtent,
          child: Column(
            mainAxisAlignment: _alignment,
            crossAxisAlignment: CrossAxisAlignment.center,
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
