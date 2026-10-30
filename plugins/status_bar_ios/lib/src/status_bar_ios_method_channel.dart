// plugins/status_bar_ios/lib/status_bar_ios_method_channel.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:status_bar_ios/src/status_bar_ios_platform_interface.dart';

/// An implementation of [StatusBarIosPlatform] that uses method
/// channels.
class MethodChannelStatusBarIos extends StatusBarIosPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('status_bar_ios');

  @override
  Future<void> setVisibility({required bool isHidden}) {
    return methodChannel.invokeMethod<void>('setStatusBar', <String, Object>{
      'isHidden': isHidden,
    });
  }
}
