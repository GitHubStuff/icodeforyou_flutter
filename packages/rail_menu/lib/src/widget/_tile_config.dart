// packages/rail_menu/lib/src/widget/_tile_config.dart

part of '_internal.dart';

/// Value object carrying all configuration for a single [_MenuItemTile].
class _TileConfig {
  const _TileConfig({
    required this.item,
    required this.index,
    required this.itemExtent,
    required this.barExtent,
    required this.activeColor,
  });

  final RailMenuItem item;
  final int index;
  final double itemExtent;
  final double barExtent;
  final Color activeColor;
}
