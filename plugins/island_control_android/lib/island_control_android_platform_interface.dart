// plugins/island_control_android/lib/island_control_android_platform_interface.dart
import 'package:island_control_android/island_control_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of `island_control_android` must
/// implement.
abstract class IslandControlAndroidPlatform extends PlatformInterface {
  /// Constructs an [IslandControlAndroidPlatform].
  IslandControlAndroidPlatform() : super(token: _token);

  static final Object _token = Object();

  static IslandControlAndroidPlatform _instance =
      MethodChannelIslandControlAndroid();

  /// The default instance of [IslandControlAndroidPlatform] to use.
  ///
  /// Defaults to [MethodChannelIslandControlAndroid].
  static IslandControlAndroidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IslandControlAndroidPlatform]
  /// when they register themselves.
  static set instance(IslandControlAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Hides the island when [isHidden] is `true`, shows it otherwise.
  Future<void> setIsland({required bool isHidden}) {
    throw UnimplementedError('setIsland() has not been implemented.');
  }
}
