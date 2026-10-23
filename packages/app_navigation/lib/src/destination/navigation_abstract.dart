// packages/app_navigation/lib/src/destination/navigation_abstract.dart
import 'package:flutter/material.dart';

/// Contract for navigation destinations carrying UI and view metadata.
abstract interface class NavigableDestinationAbstract implements Enum {
  /// The size of the button (used to calculate overflow)
  Size get size;

  /// Icon associated with the navigation option.
  IconData get iconData;

  /// Caption string that displays below the icon.
  String get caption;

  /// If specified to be in the overflow menu
  bool get inOverflow;

  /// Builder callback that constructs the destination's content view.
  Widget Function() get viewBuilder;
}
