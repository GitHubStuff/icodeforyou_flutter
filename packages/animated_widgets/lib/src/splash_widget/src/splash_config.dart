// packages/animated_widgets/lib/src/splash_widget/src/splash_config.dart

/// Timing and copy for the splash flow.
///
/// Supplied to the splash cubit to gate phase transitions and consumed by
/// the splash screen for the crossfade duration and the default timeout and
/// task-failure messages. Every field has a default, so `const
/// SplashConfig()` is a usable baseline.
final class SplashConfig {
  /// Creates a [SplashConfig].
  ///
  /// Every field defaults to a sensible value, so callers override only the
  /// ones they need.
  const SplashConfig({
    this.splashDuration = const Duration(seconds: 4),
    this.timeoutDuration = const Duration(seconds: 30),
    this.crossfadeDuration = const Duration(milliseconds: 200),
    this.timeoutText = 'Time Out',
    this.backgroundTaskFailedText = 'Background task failed',
  });

  /// How long the splash artwork stays on screen before the flow advances.
  ///
  /// When it elapses the flow moves straight to the landing page if the
  /// background tasks have already finished, or to the indeterminate phase
  /// if they have not. Defaults to 4 seconds.
  final Duration splashDuration;

  /// The longest the indeterminate phase may run before the flow gives up
  /// and shows the timeout widget.
  ///
  /// The clock starts when the indeterminate phase begins, not when the flow
  /// starts. Defaults to 30 seconds.
  final Duration timeoutDuration;

  /// The crossfade duration used when swapping between phases. Defaults to
  /// 200 milliseconds.
  final Duration crossfadeDuration;

  /// The message shown by the default timeout widget when the caller does
  /// not supply its own. Defaults to `'Time Out'`.
  final String timeoutText;

  /// The message shown by the default failure widget when the caller does
  /// not supply its own builder. Defaults to `'Background task failed'`.
  final String backgroundTaskFailedText;
}
