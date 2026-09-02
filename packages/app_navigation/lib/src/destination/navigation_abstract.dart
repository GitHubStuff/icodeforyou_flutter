// packages/app_navigation/lib/src/destination/navigation_abstract.dart
import 'package:flutter/material.dart';

/// Contract for navigation destinations carrying UI and view metadata.
abstract interface class NavigableDestinationAbstract implements Enum {
  /// Icon associated with the navigation option.
  IconData get iconData;

  /// Caption string that displays below the icon.
  String get caption;

  /// Builder callback that constructs the destination's content view.
  Widget Function() get viewBuilder;
}
