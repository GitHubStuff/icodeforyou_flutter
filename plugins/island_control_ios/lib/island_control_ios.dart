// plugins/island_control_ios/lib/island_control_ios.dart
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:island_control_ios/island_control_ios_platform_interface.dart';

/// Shows or hides the iOS status bar ("island") instantly.
///
/// Calls are no-ops on web and on every platform other than iOS, so it is
/// safe to invoke unconditionally at startup.
final class IslandControlIos {
  /// Hides the island when [isHidden] is `true`, shows it otherwise.
  ///
  /// Does nothing on web or on platforms other than iOS.
  static Future<void> setIsland({required bool isHidden}) async {
    if (kIsWeb) return; // coverage:ignore-line
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    await IslandControlIosPlatform.instance.setIsland(isHidden: isHidden);
  }
}
