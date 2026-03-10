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
        unawaited(HapticFeedback.lightImpact());
      case HapticFeedbackType.medium:
        unawaited(HapticFeedback.mediumImpact());
      case HapticFeedbackType.heavy:
        unawaited(HapticFeedback.heavyImpact());
      case HapticFeedbackType.selection:
        unawaited(HapticFeedback.selectionClick());
      case HapticFeedbackType.vibrate:
        unawaited(HapticFeedback.vibrate());
    }
  }
}
