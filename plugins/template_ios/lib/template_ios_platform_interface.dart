// plugins/template_ios/lib/template_ios_platform_interface.dart

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:template_ios/template_ios_method_channel.dart'
    show MethodChannelTemplateIos;

/// The common platform interface contract for the `template_ios` plugin.
///
/// Platform implementations must extend this class rather than implement it
/// directly to allow new non-breaking members to be added in future versions.
abstract class TemplateIosPlatform extends PlatformInterface {
  /// Constructs a [TemplateIosPlatform].
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

  /// Retrieves the host operating system platform version string.
  ///
  /// Subclasses must override this method to communicate with their
  /// respective platform-side implementations.
  ///
  /// Throws an [UnimplementedError] if the platform-specific subclass does not
  /// override this method.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
