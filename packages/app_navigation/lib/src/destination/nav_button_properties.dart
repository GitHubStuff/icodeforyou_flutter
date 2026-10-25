// packages/app_navigation/lib/src/destination/navigation_abstract.dart
import 'package:app_navigation/app_navigation.dart' show NavSlot;
import 'package:flutter/material.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;

/// Contract for navigation destinations carrying UI and view metadata.
abstract interface class NavButtonProperties implements Enum {
  /// Which slot it resides
  NavSlot get slot;

  /// Icon associated with the navigation option.
  IconData? get iconData;

  /// Caption string that displays below the icon.
  String? get caption;

  /// The haptic associated with the button
  HapticIntensity get haptic;

  /// Builder callback that constructs the destination's content view.
  Widget Function() get viewBuilder;
}
