// lib/src/widget/rail_navigation_widget.dart

part of '_internal.dart';

/// A directional animated navigation rail that owns its [Scaffold].
///
/// Renders either a bottom [_HorizontalRail] or a left [_ElevatorRail]
/// based on [direction]. Owns the [RailMenuCubit] lifecycle, safe area,
/// overflow handling, and page transition animation.
///
/// Pass [RailDirection.adaptive] to resolve direction automatically from
/// screen width and orientation — vertical on tablets (>= 600dp) and
/// landscape phones, horizontal on portrait phones.
///
/// ```dart
/// RailNavigationWidget(
///   entries: const [
///     RailMenuEntry(
///       icon: Icons.home_outlined,
///       activeIcon: Icons.home,
///       label: 'Home',
///       page: HomePage(),
///     ),
///   ],
///   direction: RailDirection.adaptive,
/// )
/// ```
class RailNavigationWidget extends StatelessWidget {
  /// Creates a [RailNavigationWidget].
  const RailNavigationWidget({
    required this.entries,
    required this.direction,
    super.key,
    this.defaultIndex = 0,
    this.icon = RailIcon.phone,
    this.transition = RailTransition.crossFade,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.iconSpacing = MenuIconSpacing.expanded,
    this.haptic = HapticIntensity.light,
    this.limit,
  }) : assert(limit == null || limit >= 2, 'limit must be >= 2');

  /// Key applied to the [Scaffold] when horizontal layout is active.
  @visibleForTesting
  static const horizontalScaffoldKey = Key('rail_horizontal_scaffold');

  /// Key applied to the [Scaffold] when vertical layout is active.
  @visibleForTesting
  static const verticalScaffoldKey = Key('rail_vertical_scaffold');

  /// The entries to display — each carries its icon, label, and page.
  final List<RailMenuEntry> entries;

  /// The axis along which the menu bar is rendered.
  ///
  /// Use [RailDirection.adaptive] to resolve automatically from screen
  /// width and orientation at build time.
  final RailDirection direction;

  /// The index of the entry selected on first render. Defaults to 0.
  final int defaultIndex;

  /// Controls icon size, item slot size, bar thickness, and indicator height.
  final RailIcon icon;

  /// The transition animation applied to the page on entry change.
  final RailTransition transition;

  /// The duration of the page transition animation.
  final Duration transitionDuration;

  /// Controls item spacing within the rail.
  final MenuIconSpacing iconSpacing;

  /// The haptic feedback intensity on item tap.
  final HapticIntensity haptic;

  /// Maximum number of items visible, including the More button.
  ///
  /// When set, shows [limit - 1] items and a More button regardless of
  /// available space. Must be >= 2.
  final int? limit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RailMenuCubit(defaultIndex: defaultIndex),
      child: _RailNavigationView(
        entries: entries,
        direction: direction,
        defaultIndex: defaultIndex,
        icon: icon,
        transition: transition,
        transitionDuration: transitionDuration,
        iconSpacing: iconSpacing,
        haptic: haptic,
        limit: limit,
      ),
    );
  }
}

class _RailNavigationView extends StatelessWidget {
  const _RailNavigationView({
    required this.entries,
    required this.direction,
    required this.defaultIndex,
    required this.icon,
    required this.transition,
    required this.transitionDuration,
    required this.iconSpacing,
    required this.haptic,
    this.limit,
  });

  final List<RailMenuEntry> entries;
  final RailDirection direction;
  final int defaultIndex;
  final RailIcon icon;
  final RailTransition transition;
  final Duration transitionDuration;
  final MenuIconSpacing iconSpacing;
  final HapticIntensity haptic;
  final int? limit;

  RailDirection _resolvedDirection(BuildContext context) {
    if (direction != RailDirection.adaptive) return direction;
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 600) return RailDirection.vertical;
    return MediaQuery.orientationOf(context) == Orientation.landscape
        ? RailDirection.vertical
        : RailDirection.horizontal;
  }

  @override
  Widget build(BuildContext context) {
    assert(entries.isNotEmpty, 'entries must not be empty');
    assert(
      defaultIndex >= 0 && defaultIndex < entries.length,
      'defaultIndex must be a valid entries index',
    );
    final resolved = _resolvedDirection(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final safePadding = MediaQuery.paddingOf(context);
        final availableExtent = resolved == RailDirection.horizontal
            ? constraints.maxWidth - safePadding.left - safePadding.right
            : constraints.maxHeight - safePadding.top - safePadding.bottom;

        final result = const _OverflowCalculator().calculate(
          itemCount: entries.length,
          itemExtent: icon.itemExtent,
          availableExtent: availableExtent,
          limit: limit,
        );

        final visibleEntries = entries.sublist(0, result.visibleCount);
        final overflowEntries = result.hasOverflow
            ? entries.sublist(result.visibleCount)
            : <RailMenuEntry>[];

        return resolved == RailDirection.horizontal
            ? _buildHorizontal(visibleEntries, overflowEntries)
            : _buildVertical(visibleEntries, overflowEntries);
      },
    );
  }

  Widget _buildHorizontal(
    List<RailMenuEntry> visibleEntries,
    List<RailMenuEntry> overflowEntries,
  ) {
    return Scaffold(
      key: RailNavigationWidget.horizontalScaffoldKey,
      body: _BodySwitcher(
        entries: entries,
        transitionDuration: transitionDuration,
      ),
      bottomNavigationBar: _HorizontalRail(
        visibleEntries: visibleEntries,
        overflowEntries: overflowEntries,
        railIcon: icon,
        spacing: iconSpacing,
        haptic: haptic,
        transition: transition,
      ),
    );
  }

  Widget _buildVertical(
    List<RailMenuEntry> visibleEntries,
    List<RailMenuEntry> overflowEntries,
  ) {
    return Scaffold(
      key: RailNavigationWidget.verticalScaffoldKey,
      body: Row(
        children: [
          _ElevatorRail(
            visibleEntries: visibleEntries,
            overflowEntries: overflowEntries,
            railIcon: icon,
            spacing: iconSpacing,
            haptic: haptic,
            transition: transition,
          ),
          Expanded(
            child: _BodySwitcher(
              entries: entries,
              transitionDuration: transitionDuration,
            ),
          ),
        ],
      ),
    );
  }
}
