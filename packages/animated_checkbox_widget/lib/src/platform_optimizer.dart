import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Platform-specific optimizations for animation performance
///
/// Follows Single Responsibility Principle - only handles platform detection and optimization
class PlatformOptimizer {
  /// Gets optimal particle count based on platform capabilities
  static int getOptimalParticleCount(double widgetWidth) {
    if (kIsWeb) {
      // Web browsers - moderate particle count for performance
      return (widgetWidth * 0.8).round();
    }

    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      // Mobile devices - optimize for battery and performance
      return (widgetWidth * 0.6).round();
    }

    if (!kIsWeb &&
        (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
      // Desktop platforms - can handle more particles
      return (widgetWidth * 1.2).round();
    }

    // Default fallback
    return widgetWidth.round();
  }

  /// Gets optimal frame rate based on platform
  static Duration getOptimalFrameRate() {
    if (kIsWeb) {
      // Web - standard 60fps
      return const Duration(milliseconds: 16);
    }

    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      // Mobile - optimize for battery
      return const Duration(milliseconds: 16);
    }

    if (!kIsWeb &&
        (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
      // Desktop - can handle higher refresh rates
      return const Duration(microseconds: 8333); // ~120fps capable
    }

    return const Duration(milliseconds: 16);
  }

  /// Gets platform-specific particle step size
  static double getParticleStep() {
    if (kIsWeb) {
      return 2.5; // Slightly larger steps for web performance
    }

    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      return 2.0; // Standard mobile performance
    }

    if (!kIsWeb &&
        (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
      return 1.5; // More detailed particles on desktop
    }

    return 2.0;
  }

  /// Determines if high-performance mode should be used
  static bool shouldUseHighPerformanceMode() {
    if (kIsWeb) return false;

    return !kIsWeb &&
        (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
  }

  /// Gets platform name for debugging
  static String getPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}
