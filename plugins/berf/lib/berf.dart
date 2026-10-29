
import 'berf_platform_interface.dart';

class Berf {
  Future<String?> getPlatformVersion() {
    return BerfPlatform.instance.getPlatformVersion();
  }
}
