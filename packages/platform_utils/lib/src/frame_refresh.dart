// packages/platform_utils/lib/src/frame_refresh.dart

/// Common display refresh rates and their per-frame budgets.
///
/// Each value pairs a nominal frames-per-second rate with the corresponding
/// frame interval in microseconds, precomputed to avoid per-frame division.
///
/// Example:
/// ```dart
/// final tick = FrameRefreshRate.fps120.duration;
/// Timer.periodic(tick, (_) => advanceFrame());
/// ```
enum FrameRefreshRate {
  /// Cinematic 24 fps (~41.667 ms per frame).
  fps24(24, 41667),

  /// Standard 60 fps (~16.667 ms per frame).
  fps60(60, 16667),

  /// High-refresh 90 fps (~11.111 ms per frame).
  fps90(90, 11111),

  /// ProMotion-class 120 fps (~8.333 ms per frame).
  fps120(120, 8333),
  ;

  /// Creates a refresh rate with its [fps] and precomputed frame
  /// interval in [microseconds].
  const FrameRefreshRate(this.fps, this.microseconds);

  /// The default frame interval used when no explicit rate is chosen.
  ///
  /// Equivalent to [fps60]'s [duration].
  static Duration get preset => fps60.duration;

  /// Nominal frames per second for this refresh rate.
  final int fps;

  /// Frame interval in microseconds (`1e6 ~/ fps`, rounded).
  final int microseconds;

  /// The frame interval as a [Duration], built from [microseconds].
  Duration get duration => Duration(microseconds: microseconds);
}
