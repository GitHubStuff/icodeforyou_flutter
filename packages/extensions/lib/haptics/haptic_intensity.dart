// ignore_for_file: public_member_api_docs

import 'dart:async' show unawaited;

import 'package:flutter/services.dart' show HapticFeedback;

/// The type of haptic feedback to trigger on button press.
enum HapticIntensity {
  /// A light impact vibration.
  light,

  /// A medium impact vibration.
  medium,

  /// A heavy impact vibration.
  heavy,

  /// A selection click vibration.
  selection,

  /// A standard vibration.
  vibrate,

  /// No vibration
  none
  ;

  void trigger() {
    switch (this) {
      case .light:
        unawaited(HapticFeedback.lightImpact());
      case .medium:
        unawaited(HapticFeedback.mediumImpact());
      case .heavy:
        unawaited(HapticFeedback.heavyImpact());
      case .selection:
        unawaited(HapticFeedback.selectionClick());
      case .vibrate:
        unawaited(HapticFeedback.vibrate());
      case .none:
        return;
    }
  }
}
