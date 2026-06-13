// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart' show Axis, BuildContext, View;
import 'package:platform_utils/platform_utils.dart' show AppPlatform;
import 'package:platform_utils/src/frame_refresh.dart' show FrameRefreshRate;

class PlatformOptimizer {
  PlatformOptimizer({this._platform});
  
  final AppPlatform? _platform;
  Duration? _cachedFrameRate;

  AppPlatform get _current => _platform ?? AppPlatform.current();

  static final _default = PlatformOptimizer();

  void resolveFrameRate(BuildContext context) {
    final refreshRate = View.of(context).display.refreshRate;
    _cachedFrameRate = Duration(microseconds: (1000000 / refreshRate).round());
  }

  Duration calculateOptimalFrameRate() =>
      _cachedFrameRate ?? FrameRefreshRate.fps60.duration;

  int calculateOptimalParticleCount(double widgetWidth) => switch (_current) {
    AppPlatform.web => (widgetWidth * 0.8).round(),
    _ when _current.isMobile => (widgetWidth * 0.6).round(),
    _ when _current.isDesktop => (widgetWidth * 1.2).round(),
    _ => widgetWidth.round(),
  };

  double calculateParticleStep() => switch (_current) {
    AppPlatform.web => 2.5,
    _ when _current.isMobile => 2.0,
    _ when _current.isDesktop => 1.5,
    _ => 2.0,
  };

  bool isHighPerformanceModeEnabled() =>
      _current != AppPlatform.web && _current.isDesktop;

  String getCurrentPlatformName() => _current.name;

  static Duration getOptimalFrameRate() => _default.calculateOptimalFrameRate();

  static int getOptimalParticleCount(double w) =>
      _default.calculateOptimalParticleCount(w);

  static double getParticleStep() => _default.calculateParticleStep();

  static bool shouldUseHighPerformanceMode() =>
      _default.isHighPerformanceModeEnabled();

  static String getPlatformName() => _default.getCurrentPlatformName();
}
