// plugins/status_bar_android/lib/src/status_bar_android_method_channel.dart
// Version: 0.0.1-a StatusBarAndroid

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:status_bar_android/src/status_bar_android_platform_interface.dart';

/// [StatusBarAndroidPlatform] implementation backed by a [MethodChannel].
///
/// Channel name, method name and argument key must match
/// `StatusBarAndroidPlugin.kt`.
class MethodChannelStatusBarAndroid extends StatusBarAndroidPlatform {
  /// Creates the implementation over the default channel.
  MethodChannelStatusBarAndroid()
    : this.withChannel(const MethodChannel(channelName));

  /// Creates the implementation over a caller-supplied [channel].
  ///
  /// Exists so tests can observe the exact method and arguments sent.
  @visibleForTesting
  MethodChannelStatusBarAndroid.withChannel(this.channel);

  /// The channel name; must match the Kotlin side.
  static const String channelName = 'status_bar_android';

  /// The method name; must match the Kotlin side.
  static const String methodSetVisibility = 'setVisibility';

  /// The argument key; must match the Kotlin side.
  static const String argIsHidden = 'isHidden';

  /// The channel used to reach the native plugin.
  @visibleForTesting
  final MethodChannel channel;

  @override
  Future<void> setVisibility({required bool isHidden}) {
    return channel.invokeMethod<void>(methodSetVisibility, <String, Object>{
      argIsHidden: isHidden,
    });
  }
}
