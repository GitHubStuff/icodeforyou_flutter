// plugins/status_bar_android/lib/src/status_bar.dart
// Version: 0.0.1-a StatusBarAndroid

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:status_bar_android/src/status_bar_android_platform_interface.dart'
    show StatusBarAndroidPlatform;

/// Manages system status bar visibility on Android devices.
///
/// This utility delegates status bar manipulations to the underlying
/// platform implementation while guarding against execution on unsupported
/// environments.
abstract final class StatusBar {
  /// Sets the visibility of the Android system status bar.
  ///
  /// When [isHidden] is `true`, the status bar is hidden; when `false`,
  /// it is made visible.
  ///
  /// This operation is a no-op on the web or on platforms other than
  /// [TargetPlatform.android].
  ///
  /// Example:
  /// ```dart
  /// // Hide the status bar
  /// await StatusBar.setVisibility(isHidden: true);
  ///
  /// // Show the status bar
  /// await StatusBar.setVisibility(isHidden: false);
  /// ```
  static Future<void> setVisibility({bool isHidden = true}) async {
    if (kIsWeb) return; // coverage:ignore-line
    if (defaultTargetPlatform != TargetPlatform.android) return;

    return StatusBarAndroidPlatform.instance.setVisibility(isHidden: isHidden);
  }
}
