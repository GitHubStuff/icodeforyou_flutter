// plugins/island_control_android/lib/island_control_android.dart
import 'package:island_control_android/island_control_android_platform_interface.dart';

/// Shows or hides the Android status bar ("island") instantly.
class IslandControlAndroid {
  /// Creates an [IslandControlAndroid] backed by [platform], defaulting to
  /// [IslandControlAndroidPlatform.instance].
  IslandControlAndroid({IslandControlAndroidPlatform? platform})
    : _platform = platform ?? IslandControlAndroidPlatform.instance;

  final IslandControlAndroidPlatform _platform;

  /// Hides the island when [isHidden] is `true`, shows it otherwise.
  Future<void> setIsland({required bool isHidden}) =>
      _platform.setIsland(isHidden: isHidden);
}
