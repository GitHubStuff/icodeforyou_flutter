// lib/src/core/constants/timing_constants.dart

/// Timing constants for animations and debouncing
class TimingConstants {
  
  /// Debounce duration after scrolling stops before callback fires
  /// Prevents jank and excessive callback calls
  static const Duration callbackDebounce = Duration(milliseconds: 400);

  /// Animation duration for scroll physics
  static const Duration scrollAnimationDuration = Duration(milliseconds: 300);

  /// Duration for haptic feedback delay
  static const Duration hapticDelay = Duration(milliseconds: 10);

  /// Maximum duration to wait for scroll to settle
  static const Duration scrollSettleTimeout = Duration(seconds: 2);

  /// Duration between infinite scroll recentering checks
  static const Duration recenterCheckInterval = Duration(seconds: 5);

  /// Animation duration for 3D transform transitions
  static const Duration transformAnimationDuration =
      Duration(milliseconds: 150);

  /// Fade animation duration for top/bottom gradient
  static const Duration fadeAnimationDuration = Duration(milliseconds: 200);
}
