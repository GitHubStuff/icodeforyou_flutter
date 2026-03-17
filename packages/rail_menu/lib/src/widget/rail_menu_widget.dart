// packages/rail_menu/lib/src/widget/rail_menu_widget.dart

part of '_internal.dart';

/// A directional menu bar that adapts to available space.
///
/// Requires a [RailMenuCubit] provided above this widget in the tree.
///
/// ```dart
/// BlocProvider(
///   create: (_) => RailMenuCubit(defaultIndex: 0),
///   child: Scaffold(
///     bottomNavigationBar: RailMenu(
///       direction: RailMenuDirection.bottom,
///       items: [...],
///     ),
///   ),
/// )
/// ```
class RailMenu extends StatelessWidget {
  /// Creates a [RailMenu].
  const RailMenu({
    required this.direction,
    required this.items,
    super.key,
    this.dimensions = const RailMenuDimensions.defaults(),
    this.activeColor = Colors.transparent,
    this.cancelWidget = const Icon(Icons.cancel),
    this.limit,
  })  : assert(items.length > 0, 'items must not be empty'),
        assert(limit == null || limit >= 2, 'limit must be >= 2');

  /// The edge along which the menu bar is rendered.
  final RailMenuDirection direction;

  /// The items to render in the menu bar.
  final List<RailMenuItem> items;

  /// Controls item slot size, icon size, and bar thickness.
  final RailMenuDimensions dimensions;

  /// The color of the 3dp indicator bar below the active item.
  ///
  /// Defaults to [Colors.transparent].
  final Color activeColor;

  /// The widget shown in the top-right corner of the More modal.
  final Widget cancelWidget;

  /// Maximum number of items visible in the bar, including the More button.
  ///
  /// When set, shows [limit - 1] items and a More button regardless of
  /// available space. Must be >= 2. Defaults to null (pixel-based layout).
  final int? limit;

  @override
  Widget build(BuildContext context) => _MenuLayout(
        direction: direction,
        items: items,
        dimensions: dimensions,
        activeColor: activeColor,
        cancelWidget: cancelWidget,
        limit: limit,
      );
}
