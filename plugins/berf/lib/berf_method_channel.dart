import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'berf_platform_interface.dart';

/// An implementation of [BerfPlatform] that uses method channels.
class MethodChannelBerf extends BerfPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('berf');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
