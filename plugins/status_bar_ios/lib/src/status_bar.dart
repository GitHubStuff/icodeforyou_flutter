// plugins/status_bar_ios/lib/src/status_bar.dart

import 'package:status_bar_ios/src/status_bar_ios_platform_interface.dart'
    show StatusBarIosPlatform;

/// Shows or hides the iOS system status bar.
///
/// Delegates to [StatusBarIosPlatform.instance]. This class does not
/// check which platform it is running on: that is the caller's job. On a
/// platform where the iOS plugin is not registered, the call completes
/// with a `MissingPluginException`.
abstract final class StatusBar {
  /// Sets the visibility of the iOS system status bar.
  ///
  /// Set [isHidden] to `true` to hide the status bar, or `false` to display it.
  /// Defaults to `true`.
  ///
  /// Throws an [UnsupportedError] if invoked on a non-iOS platform.
  static Future<void> setVisibility({bool isHidden = true}) async {
    return StatusBarIosPlatform.instance.setVisibility(isHidden: isHidden);
  }
}
