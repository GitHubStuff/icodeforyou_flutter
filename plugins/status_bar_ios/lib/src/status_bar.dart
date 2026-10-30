// plugins/status_bar_android/lib/src/status_bar.dart

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:status_bar_ios/src/status_bar_ios_platform_interface.dart'
    show StatusBarIosPlatform;

/// Manages system status bar visibility on iOS devices.
///
/// Delegates status bar operations to [StatusBarIosPlatform.instance] while
/// guarding against execution on web and non-iOS platforms.
abstract final class StatusBar {
  /// Sets the visibility of the iOS system status bar.
  ///
  /// Set [isHidden] to `true` to hide the status bar, or `false` to display it.
  /// Defaults to `true`.
  ///
  /// This operation is a no-op on the web ([kIsWeb]) and any platform other
  /// than [TargetPlatform.iOS].
  ///
  /// Example:
  /// ```dart
  /// // Hide the status bar
  /// await StatusBar.setVisibility(isHidden: true);
  ///
  /// // Restore the status bar
  /// await StatusBar.setVisibility(isHidden: false);
  /// ```
  static Future<void> setVisibility({bool isHidden = true}) async {
    if (kIsWeb) return; // coverage:ignore-line
    if (defaultTargetPlatform != TargetPlatform.iOS) return;

    return StatusBarIosPlatform.instance.setVisibility(isHidden: isHidden);
  }
}
