// lib/src/model/haptic_intensity.dart

import 'package:animated_rail_menu/animated_rail_menu.dart' show RailMenuEntry;

/// Controls the haptic feedback intensity when a [RailMenuEntry] is tapped.
enum HapticIntensity {
  /// No haptic feedback.
  none,

  /// Light impact feedback.
  light,

  /// Medium impact feedback.
  medium,

  /// Heavy impact feedback.
  heavy,
}
