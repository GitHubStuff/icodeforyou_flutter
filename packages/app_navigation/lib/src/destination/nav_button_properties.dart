// packages/app_navigation/lib/src/destination/nav_button_properties.dart
import 'package:app_navigation/app_navigation.dart' show NavSlot;
import 'package:flutter/material.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;

/// Contract for navigation destinations carrying UI and view metadata.
/// A List<> of these compose/hold the meta-data for buttons that appear
/// in the Dock and Rail Buttons at the bottom/side of the screen
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
