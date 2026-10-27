import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:island_control_android/island_control_android_platform_interface.dart';

/// An implementation of [IslandControlAndroidPlatform] that uses method
/// channels.
class MethodChannelIslandControlAndroid extends IslandControlAndroidPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('island_control_android');

  @override
  Future<void> setIsland({required bool isHidden}) {
    return methodChannel.invokeMethod<void>('setIsland', <String, Object>{
      'isHidden': isHidden,
    });
  }
}
