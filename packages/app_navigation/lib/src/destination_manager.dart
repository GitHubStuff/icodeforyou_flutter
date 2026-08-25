// packages/app_navigation/lib/src/destination_manager.dart
import 'package:app_navigation/src/destination_item.dart'
    show DestinationItem, DestinationTag;
import 'package:collection/collection.dart';

/// Manages a collection of navigation destination items partitioned into
/// visible and overflow menus.
///
/// Ensures destination tags remain unique within each group and across both
/// collections.
class DestinationManager {
  /// Creates a [DestinationManager] instance.
  ///
  /// Enforces that all items in [visibleMenuItems] and [overflowMenuItems]
  /// contain unique tags with no overlapping identifiers between the two.
  DestinationManager({
    required this.visibleMenuItems,
    this.overflowMenuItems = const [],
  }) : assert(
         visibleMenuItems.map((e) => e.tag).toSet().length ==
             visibleMenuItems.length,
         'visibleMenuItems contains duplicate tags.',
       ),
       assert(
         overflowMenuItems.map((e) => e.tag).toSet().length ==
             overflowMenuItems.length,
         'overflowMenuItems contains duplicate tags.',
       ),
       assert(
         visibleMenuItems
             .map((e) => e.tag)
             .toSet()
             .intersection(overflowMenuItems.map((e) => e.tag).toSet())
             .isEmpty,
         'visibleMenuItems and overflowMenuItems cannot share common tags.',
       );

  /// Primary navigation destination items rendered directly in the main UI.
  final List<DestinationItem> visibleMenuItems;

  /// Secondary navigation destination items placed in an overflow menu.
  final List<DestinationItem> overflowMenuItems;

  /// Finds and returns the [DestinationItem] associated with [tag].
  ///
  /// Searches [visibleMenuItems] first, then falls back to [overflowMenuItems].
  /// Throws a [StateError] if no item matches the specified [tag].
  DestinationItem getItem(DestinationTag tag) {
    final item =
        visibleMenuItems.firstWhereOrNull((i) => i.tag == tag) ??
        overflowMenuItems.firstWhereOrNull((i) => i.tag == tag);

    if (item == null) {
      throw StateError('No DestinationItem found for tag: "$tag".');
    }

    return item;
  }

  /// Finds and returns the [DestinationItem] matching [tag] from
  /// [overflowMenuItems].
  ///
  /// Throws a [StateError] if no matching item is found in overflow items.
  DestinationItem overflowItem(DestinationTag tag) =>
      overflowMenuItems.firstWhere(
        (item) => item.tag == tag,
        orElse: () => throw StateError(
          'No OverflowItem found for tag: "$tag".',
        ),
      );

  /// Finds and returns the [DestinationItem] matching [tag] from
  /// [visibleMenuItems].
  ///
  /// Throws a [StateError] if no matching item is found in visible items.
  DestinationItem visibleItem(DestinationTag tag) =>
      visibleMenuItems.firstWhere(
        (item) => item.tag == tag,
        orElse: () => throw StateError(
          'No DestinationItem found for tag: "$tag".',
        ),
      );
}
