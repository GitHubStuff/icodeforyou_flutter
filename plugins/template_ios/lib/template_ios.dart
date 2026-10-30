// plugins/template_ios/lib/template_ios.dart

import 'package:template_ios/template_ios_platform_interface.dart'
    show TemplateIosPlatform;

/// Provides access to the iOS platform-specific features for `template_ios`.
class TemplateIos {
  /// Retrieves the host operating system platform version string.
  ///
  /// Forwards the call to the default implementation registered on
  /// [TemplateIosPlatform.instance].
  ///
  /// Returns a [Future] completing with the platform version string, or `null`
  /// if the underlying platform call fails or does not report a value.
  Future<String?> getPlatformVersion() {
    return TemplateIosPlatform.instance.getPlatformVersion();
  }
}
