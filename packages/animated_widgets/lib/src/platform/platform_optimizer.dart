// animated_widgets/lib/src/platform/_platform_optimizer.dart
import 'package:animated_widgets/src/platform/platform_identifier.dart';

/// Computes platform-specific rendering parameters for animations.
class PlatformOptimizer {
  /// Creates a [PlatformOptimizer] with an optional [platformDetector].
  ///
  /// Defaults to [DefaultPlatformIdentifier] when no detector is provided.
  const PlatformOptimizer({PlatformIdentifier? platformDetector})
    : _platformDetector = platformDetector ?? const DefaultPlatformIdentifier();

  final PlatformIdentifier _platformDetector;

  static const PlatformOptimizer _defaultInstance = PlatformOptimizer();

  /// Returns the optimal particle count for the given [widgetWidth],
  /// scaled to the current platform's rendering capability.
  int calculateOptimalParticleCount(double widgetWidth) {
    if (_platformDetector.isWeb) return (widgetWidth * 0.8).round();
    if (_platformDetector.isIOS || _platformDetector.isAndroid) {
      return (widgetWidth * 0.6).round();
    }
    if (_platformDetector.isMacOS ||
        _platformDetector.isWindows ||
        _platformDetector.isLinux) {
      return (widgetWidth * 1.2).round();
    }
    return widgetWidth.round();
  }

  /// Returns the optimal frame duration for the current platform.
  ///
  /// Desktop platforms target ~120 fps; all others target ~60 fps.
  Duration calculateOptimalFrameRate() {
    if (_platformDetector.isMacOS ||
        _platformDetector.isWindows ||
        _platformDetector.isLinux) {
      return const Duration(microseconds: 8333);
    }
    return const Duration(milliseconds: 16);
  }

  /// Returns the particle step size appropriate for the current platform.
  double calculateParticleStep() {
    if (_platformDetector.isWeb) return 2.5;
    if (_platformDetector.isIOS || _platformDetector.isAndroid) return 2;
    if (_platformDetector.isMacOS ||
        _platformDetector.isWindows ||
        _platformDetector.isLinux) {
      return 1.5;
    }
    return 2;
  }

  /// Returns whether high-performance rendering mode is enabled.
  ///
  /// Always `false` on web; `true` on desktop platforms.
  bool isHighPerformanceModeEnabled() {
    if (_platformDetector.isWeb) return false;
    return _platformDetector.isMacOS ||
        _platformDetector.isWindows ||
        _platformDetector.isLinux;
  }

  /// Returns the human-readable name of the current platform.
  String getCurrentPlatformName() => _platformDetector.platformName;

  /// Returns the optimal particle count for [widgetWidth] on the current
  /// platform.
  static int getOptimalParticleCount(double widgetWidth) =>
      _defaultInstance.calculateOptimalParticleCount(widgetWidth);

  /// Returns the optimal frame duration for the current platform.
  static Duration getOptimalFrameRate() =>
      _defaultInstance.calculateOptimalFrameRate();

  /// Returns the particle step size for the current platform.
  static double getParticleStep() => _defaultInstance.calculateParticleStep();

  /// Returns whether high-performance mode is enabled on the current platform.
  static bool shouldUseHighPerformanceMode() =>
      _defaultInstance.isHighPerformanceModeEnabled();

  /// Returns the human-readable name of the current platform.
  static String getPlatformName() => _defaultInstance.getCurrentPlatformName();
}
