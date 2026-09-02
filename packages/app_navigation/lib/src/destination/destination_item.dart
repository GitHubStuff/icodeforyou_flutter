// packages/app_navigation/lib/src/destination/destination_item.dart
import 'package:app_navigation/src/destination/navigation_abstract.dart';
import 'package:flutter/material.dart';

/// A configuration model representing a distinct navigation destination typed
/// to a [NavigableDestinationAbstract] enum identifier [T].
///
/// Encapsulates destination metadata alongside a builder callback responsible
/// for rendering the destination's content view.
class DestinationItem<T extends NavigableDestinationAbstract> {
  /// Creates a [DestinationItem] configuration.
  ///
  /// The [iconData] and [caption] parameters default to the values defined on
  /// [tag] unless explicitly overridden.
  DestinationItem({
    required this.tag,
    required this.viewBuilder,
    IconData? iconData,
    String? caption,
  }) : iconData = iconData ?? tag.iconData,
       caption = caption ?? tag.caption;

  /// The enum identifier instance associated with this destination.
  final T tag;

  /// The icon representing this destination in navigation components.
  final IconData iconData;

  /// The descriptive label or title displayed for this destination.
  final String caption;

  /// A builder callback that constructs the widget tree for this
  /// destination's content view.
  final Widget Function() viewBuilder;
}
