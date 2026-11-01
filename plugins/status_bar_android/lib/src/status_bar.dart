// plugins/status_bar_android/lib/src/status_bar.dart
// Version: 0.0.1-a StatusBarAndroid

import 'package:status_bar_android/src/status_bar_android_platform_interface.dart'
    show StatusBarAndroidPlatform;

/// Shows or hides the Android system status bar.
///
/// Delegates to [StatusBarAndroidPlatform.instance]. This class does not
/// check which platform it is running on: that is the caller's job. On a
/// platform where the Android plugin is not registered, the call completes
/// with a `MissingPluginException`.
abstract final class StatusBar {
  /// Sets the visibility of the Android system status bar.
  ///
  /// Set [isHidden] to `true` to hide the status bar, or `false` to display it.
  /// Defaults to `true`.
  ///
  /// Throws an [UnsupportedError] if invoked on a non-Android platform.
  static Future<void> setVisibility({required bool isHidden}) {
    return StatusBarAndroidPlatform.instance.setVisibility(isHidden: isHidden);
  }
}
