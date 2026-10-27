// plugins/island_control_ios/lib/island_control_ios_method_channel.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:island_control_ios/island_control_ios_platform_interface.dart';

/// An implementation of [IslandControlIosPlatform] that uses method
/// channels.
class MethodChannelIslandControlIos extends IslandControlIosPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('island_control_ios');

  @override
  Future<void> setIsland({required bool isHidden}) {
    return methodChannel.invokeMethod<void>('setIsland', <String, Object>{
      'isHidden': isHidden,
    });
  }
}
