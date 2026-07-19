import 'package:flutter/widgets.dart' show BuildContext, View;
import 'package:platform_utils/platform_utils.dart' show AppPlatform;
import 'package:platform_utils/src/frame_refresh.dart' show FrameRefreshRate;

/// Provides platform-aware tuning values for animation-heavy widgets.
///
/// [PlatformOptimizer] centralizes the per-platform decisions that affect
/// rendering cost: frame pacing, particle density, and particle step size.
/// Instance methods operate against an injectable [AppPlatform], enabling
/// deterministic unit tests; the static convenience methods delegate to a
/// shared default instance that resolves the platform at runtime.
///
/// Frame-rate resolution is a two-phase operation. Call [resolveFrameRate]
/// from a widget with access to a [BuildContext] (typically in
/// `didChangeDependencies`) to cache the display's actual refresh rate.
/// Until that happens, [calculateOptimalFrameRate] falls back to
/// [FrameRefreshRate.fps60].
class PlatformOptimizer {
  /// Creates a [PlatformOptimizer].
  ///
  /// [_platform] overrides runtime platform detection and exists primarily
  /// for testing. When omitted, every calculation resolves the platform
  /// lazily via [AppPlatform.current].
  PlatformOptimizer({this._platform});

  /// Injected platform override, or `null` to detect at call time.
  final AppPlatform? _platform;

  /// Frame duration cached by [resolveFrameRate], or `null` if the display
  /// refresh rate has not yet been resolved.
  Duration? _cachedFrameRate;

  /// The effective platform: the injected override when present, otherwise
  /// the platform detected at call time.
  AppPlatform get _current => _platform ?? AppPlatform.current();

  /// Shared instance backing the static convenience methods.
  static final _default = PlatformOptimizer();

  /// Resolves and caches the frame duration from the display hosting
  /// [context].
  ///
  /// Reads the refresh rate of the [View] associated with [context] and
  /// stores the corresponding per-frame [Duration]. Call this once the
  /// widget tree is attached to a view — `didChangeDependencies` is the
  /// canonical site — and before relying on [calculateOptimalFrameRate]
  /// for anything other than the 60fps fallback.
  void resolveFrameRate(BuildContext context) {
    final refreshRate = View.of(context).display.refreshRate;
    _cachedFrameRate = Duration(
      microseconds: (1000000 / refreshRate).round(),
    );
  }

  /// Returns the optimal per-frame [Duration] for animation ticking.
  ///
  /// Returns the duration cached by [resolveFrameRate] when available,
  /// otherwise falls back to [FrameRefreshRate.fps60].
  Duration calculateOptimalFrameRate() =>
      _cachedFrameRate ?? FrameRefreshRate.fps60.duration;

  /// Returns the particle count budget for a widget of [widgetWidth]
  /// logical pixels.
  ///
  /// Density scales with platform rendering headroom: desktop renders the
  /// most particles (1.2× width), web renders fewer (0.8× width), and
  /// mobile renders the fewest (0.6× width). Unrecognized platforms
  /// default to a 1:1 ratio.
  int calculateOptimalParticleCount(double widgetWidth) => switch (_current) {
    AppPlatform.web => (widgetWidth * 0.8).round(),
    _ when _current.isMobile => (widgetWidth * 0.6).round(),
    _ when _current.isDesktop => (widgetWidth * 1.2).round(),
    _ => widgetWidth.round(),
  };

  /// Returns the per-frame movement step, in logical pixels, for particle
  /// animation.
  ///
  /// Larger steps trade smoothness for lower cost: web uses the coarsest
  /// step (2.5), mobile a moderate step (2.0), and desktop the finest
  /// step (1.5). Unrecognized platforms default to 2.0.
  double calculateParticleStep() => switch (_current) {
    AppPlatform.web => 2.5,
    _ when _current.isMobile => 2.0,
    _ when _current.isDesktop => 1.5,
    _ => 2.0,
  };

  /// Whether the current platform qualifies for high-performance rendering.
  ///
  /// Returns `true` only for native desktop platforms; web is excluded
  /// even when [AppPlatform.isDesktop] reports a desktop browser.
  bool isHighPerformanceModeEnabled() =>
      _current != AppPlatform.web && _current.isDesktop;

  /// Returns the display name of the effective platform.
  String getCurrentPlatformName() => _current.name;

  /// Static counterpart of [calculateOptimalFrameRate] using the shared
  /// default instance.
  static Duration getOptimalFrameRate() => _default.calculateOptimalFrameRate();

  /// Static counterpart of [calculateOptimalParticleCount] for a widget
  /// of width [w], using the shared default instance.
  static int getOptimalParticleCount(double w) =>
      _default.calculateOptimalParticleCount(w);

  /// Static counterpart of [calculateParticleStep] using the shared
  /// default instance.
  static double getParticleStep() => _default.calculateParticleStep();

  /// Static counterpart of [isHighPerformanceModeEnabled] using the shared
  /// default instance.
  static bool shouldUseHighPerformanceMode() =>
      _default.isHighPerformanceModeEnabled();

  /// Static counterpart of [getCurrentPlatformName] using the shared
  /// default instance.
  static String getPlatformName() => _default.getCurrentPlatformName();
}
