// plugins/status_bar_ios/lib/status_bar_ios_platform_interface.dart
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:status_bar_ios/src/status_bar_ios_method_channel.dart';

/// The interface that implementations of `status_bar_ios` must
/// implement.
abstract class StatusBarIosPlatform extends PlatformInterface {
  /// Constructs an [StatusBarIosPlatform].
  StatusBarIosPlatform() : super(token: _token);

  static final Object _token = Object();

  static StatusBarIosPlatform _instance = MethodChannelStatusBarIos();

  /// The default instance of [StatusBarIosPlatform] to use.
  ///
  /// Defaults to [MethodChannelStatusBarIos].
  static StatusBarIosPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [StatusBarIosPlatform]
  /// when they register themselves.
  static set instance(StatusBarIosPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Hides the status bar when [isHidden] is `true`, shows it otherwise.
  Future<void> setVisibility({required bool isHidden}) {
    throw UnimplementedError('setStatusBar() has not been implemented.');
  }
}
