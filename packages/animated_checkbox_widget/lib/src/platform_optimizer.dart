// lib/src/platform_optimizer.dart
import 'platform_identifer.dart';

class PlatformOptimizer {
  static const DefaultPlatformIdentifier _defaultDetector =
      DefaultPlatformIdentifier();

  final PlatformIdentifier _platformDetector;

  const PlatformOptimizer({PlatformIdentifier? platformDetector})
    : _platformDetector = platformDetector ?? _defaultDetector;

  // Instance methods with different names to avoid conflicts
  int calculateOptimalParticleCount(double widgetWidth) {
    if (_platformDetector.isWeb) {
      return (widgetWidth * 0.8).round();
    }
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
    if (_platformDetector.isWeb) {
      return const Duration(milliseconds: 16);
    }
    if (_platformDetector.isIOS || _platformDetector.isAndroid) {
      return const Duration(milliseconds: 16);
    }
    if (_platformDetector.isMacOS ||
        _platformDetector.isWindows ||
        _platformDetector.isLinux) {
      return const Duration(microseconds: 8333);
    }
    return const Duration(milliseconds: 16);
  }

  double calculateParticleStep() {
    if (_platformDetector.isWeb) {
      return 2.5;
    }
    if (_platformDetector.isIOS || _platformDetector.isAndroid) {
      return 2.0;
    }
    if (_platformDetector.isMacOS ||
        _platformDetector.isWindows ||
        _platformDetector.isLinux) {
      return 1.5;
    }
    return 2.0;
  }

  bool isHighPerformanceModeEnabled() {
    if (_platformDetector.isWeb) return false;
    return _platformDetector.isMacOS ||
        _platformDetector.isWindows ||
        _platformDetector.isLinux;
  }

  String getCurrentPlatformName() => _platformDetector.platformName;

  // Static methods for backward compatibility
  static const PlatformOptimizer _defaultInstance = PlatformOptimizer();

  static int getOptimalParticleCount(double widgetWidth) =>
      _defaultInstance.calculateOptimalParticleCount(widgetWidth);

  static Duration getOptimalFrameRate() =>
      _defaultInstance.calculateOptimalFrameRate();

  static double getParticleStep() => _defaultInstance.calculateParticleStep();

  static bool shouldUseHighPerformanceMode() =>
      _defaultInstance.isHighPerformanceModeEnabled();

  static String getPlatformName() => _defaultInstance.getCurrentPlatformName();
}
