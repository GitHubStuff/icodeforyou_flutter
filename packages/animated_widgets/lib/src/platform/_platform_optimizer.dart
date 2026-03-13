// lib/src/platform/_platform_optimizer.dart

import 'package:animated_widgets/src/platform/platform_identifier.dart';

/// Computes platform-specific rendering parameters for animations.
class PlatformOptimizer {
  const PlatformOptimizer({PlatformIdentifier? platformDetector})
      : _platformDetector =
            platformDetector ?? const DefaultPlatformIdentifier();


  final PlatformIdentifier _platformDetector;

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

  Duration calculateOptimalFrameRate() {
    if (_platformDetector.isMacOS ||
        _platformDetector.isWindows ||
        _platformDetector.isLinux) {
      return const Duration(microseconds: 8333);
    }
    return const Duration(milliseconds: 16);
  }

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

  bool isHighPerformanceModeEnabled() {
    if (_platformDetector.isWeb) return false;
    return _platformDetector.isMacOS ||
        _platformDetector.isWindows ||
        _platformDetector.isLinux;
  }

  String getCurrentPlatformName() => _platformDetector.platformName;

  // Static convenience API
  static const PlatformOptimizer _defaultInstance = PlatformOptimizer();

  static int getOptimalParticleCount(double widgetWidth) =>
      _defaultInstance.calculateOptimalParticleCount(widgetWidth);

  static Duration getOptimalFrameRate() =>
      _defaultInstance.calculateOptimalFrameRate();

  static double getParticleStep() => _defaultInstance.calculateParticleStep();

  static bool shouldUseHighPerformanceMode() =>
      _defaultInstance.isHighPerformanceModeEnabled();

  static String getPlatformName() =>
      _defaultInstance.getCurrentPlatformName();
}
