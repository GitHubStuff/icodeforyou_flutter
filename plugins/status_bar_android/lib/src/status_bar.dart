// plugins/status_bar_android/lib/src/status_bar.dart
// Version: 0.0.1-a StatusBarAndroid

import 'package:status_bar_android/src/status_bar_android_platform_interface.dart';

/// Controls the visibility of the Android status bar.
///
/// The public API of `status_bar_android`. Every call is forwarded to
/// [StatusBarAndroidPlatform.instance], which in production is the
/// method-channel implementation backed by `StatusBarAndroidPlugin.kt`.
///
/// The native side toggles the bar with no transition (see
/// `StatusBarController.kt`); while hidden, a swipe from the top edge
/// reveals it transiently.
///
/// Android only. Calling this on any other platform throws a
/// [MissingPluginException] from the method channel.
///
/// `abstract final`: a static-only namespace that cannot be
/// instantiated, extended or implemented.
abstract final class StatusBar {
  /// Hides the status bar when [isHidden] is `true`, shows it otherwise.
  ///
  /// Defaults to hiding.
  ///
  /// Completes with a [PlatformException] (`NO_ACTIVITY`) if no activity
  /// is attached, e.g. when called from a background isolate.
  static Future<void> setVisibility({bool isHidden = true}) {
    return StatusBarAndroidPlatform.instance.setVisibility(isHidden: isHidden);
  }
}
