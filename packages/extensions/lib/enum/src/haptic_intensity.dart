// packages/extensions/lib/haptics/haptic_intensity.dart
import 'dart:async' show unawaited;

import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter/widgets.dart' show ValueChanged, VoidCallback;

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
  none;

  /// Triggers the haptic feedback for this intensity level.
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

  /// Wraps [callback] so this haptic fires immediately before it.
  ///
  /// Returns `null` when [callback] is `null`, preserving the
  /// disabled state of the button.
  VoidCallback? wrap(VoidCallback? callback) {
    if (callback == null) return null;

    return () {
      trigger();
      callback();
    };
  }

  /// Like [wrap] but for callbacks that take a value, e.g.
  /// `SegmentedButton.onSelectionChanged`.
  ValueChanged<T>? wrapValue<T>(ValueChanged<T>? callback) {
    if (callback == null) return null;

    return (value) {
      trigger();
      callback(value);
    };
  }
}
