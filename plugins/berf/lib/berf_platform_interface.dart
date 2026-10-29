import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'berf_method_channel.dart';

abstract class BerfPlatform extends PlatformInterface {
  /// Constructs a BerfPlatform.
  BerfPlatform() : super(token: _token);

  static final Object _token = Object();

  static BerfPlatform _instance = MethodChannelBerf();

  /// The default instance of [BerfPlatform] to use.
  ///
  /// Defaults to [MethodChannelBerf].
  static BerfPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BerfPlatform] when
  /// they register themselves.
  static set instance(BerfPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
