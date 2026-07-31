// plugins/status_bar_chameleon/lib/src/status_bar_chameleon.dart

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart';

/// Hides or shows the platform status bar on iOS and Android.
///
/// A thin wrapper over a [MethodChannel]. Calls are no-ops on web and on any
/// platform other than iOS or Android, so it is safe to invoke unconditionally
/// at startup.
final class StatusBarChameleon {
  static const MethodChannel _channel = MethodChannel(
    'status_bar_chameleon/status_bar',
  );

  static bool _isHidden = false;

  /// Whether the status bar is currently hidden.
  ///
  /// Reflects the last value passed to [setStatusBarHidden]; `false` before
  /// any call has been made.
  static bool get isHidden => _isHidden;

  /// Hides or shows the status bar, optionally animating over [duration].
  ///
  /// Pass `true` for [hidden] to hide the bar, `false` to show it. The change
  /// animates over [duration] where the platform supports it, and is applied
  /// immediately when [duration] is [Duration.zero] (the default).
  ///
  /// Does nothing on web or on platforms other than iOS and Android. Updates
  /// [isHidden] before dispatching the change to the platform.
  static Future<void> setStatusBarHidden({
    required bool hidden,
    Duration duration = Duration.zero,
  }) async {
    if (kIsWeb) return; // coverage:ignore-line
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    _isHidden = hidden;
    await _channel.invokeMethod<void>('setStatusBarHidden', <String, Object?>{
      'hidden': hidden,
      'durationMs': duration.inMilliseconds,
    });
  }
}
