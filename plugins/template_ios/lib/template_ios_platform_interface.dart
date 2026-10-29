// plugins/template_ios/lib/template_ios_platform_interface.dart
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'template_ios_method_channel.dart';

abstract class TemplateIosPlatform extends PlatformInterface {
  /// Constructs a TemplateIosPlatform.
  TemplateIosPlatform() : super(token: _token);

  static final Object _token = Object();

  static TemplateIosPlatform _instance = MethodChannelTemplateIos();

  /// The default instance of [TemplateIosPlatform] to use.
  ///
  /// Defaults to [MethodChannelTemplateIos].
  static TemplateIosPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TemplateIosPlatform] when
  /// they register themselves.
  static set instance(TemplateIosPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
