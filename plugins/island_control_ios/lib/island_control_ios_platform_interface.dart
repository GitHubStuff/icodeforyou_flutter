// plugins/island_control_ios/lib/island_control_ios_platform_interface.dart
import 'package:island_control_ios/island_control_ios_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of `island_control_ios` must
/// implement.
abstract class IslandControlIosPlatform extends PlatformInterface {
  /// Constructs an [IslandControlIosPlatform].
  IslandControlIosPlatform() : super(token: _token);

  static final Object _token = Object();

  static IslandControlIosPlatform _instance = MethodChannelIslandControlIos();

  /// The default instance of [IslandControlIosPlatform] to use.
  ///
  /// Defaults to [MethodChannelIslandControlIos].
  static IslandControlIosPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IslandControlIosPlatform]
  /// when they register themselves.
  static set instance(IslandControlIosPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Hides the island when [isHidden] is `true`, shows it otherwise.
  Future<void> setIsland({required bool isHidden}) {
    throw UnimplementedError('setIsland() has not been implemented.');
  }
}
