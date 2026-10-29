// plugins/template_ios/lib/template_ios.dart
import 'template_ios_platform_interface.dart';

class TemplateIos {
  Future<String?> getPlatformVersion() {
    return TemplateIosPlatform.instance.getPlatformVersion();
  }
}
