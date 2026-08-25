// packages/app_navigation/lib/src/destination_item.dart
import 'package:flutter/material.dart';

/// A unique identifier representing a navigation destination.
typedef DestinationTag = String;

/// A model representing a distinct navigation destination.
///
/// Encapsulates destination metadata along with a builder function
/// responsible for rendering the destination's view.
class DestinationItem {
  /// Creates a [DestinationItem] configuration.
  const DestinationItem({
    required this.tag,
    required this.iconData,
    required this.caption,
    required this.viewBuilder,
  });

  /// The unique key used to identify and route to this destination.
  final DestinationTag tag;

  /// The icon representing this destination in navigation components.
  final IconData iconData;

  /// The descriptive label or title displayed for this destination.
  final String caption;

  /// A builder callback that constructs the widget tree for this
  /// destination's content view.
  final Widget Function() viewBuilder;
}
