// lib/src/_haptic_feedback_type.dart
part of 'step_slider.dart';

/// The type of haptic feedback to trigger on button press.
enum HapticFeedbackType {
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
}

extension _HapticFeedbackTypeExtension on HapticFeedbackType {
  void trigger() {
    switch (this) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
    }
  }
}
