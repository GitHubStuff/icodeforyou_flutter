// plugins/template_ios/lib/template_ios_method_channel.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'template_ios_platform_interface.dart';

/// An implementation of [TemplateIosPlatform] that uses method channels.
class MethodChannelTemplateIos extends TemplateIosPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('template_ios');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
