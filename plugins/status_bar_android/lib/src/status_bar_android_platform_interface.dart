// plugins/status_bar_android/lib/src/status_bar_android_platform_interface.dart
// Version: 0.0.1-a StatusBarAndroid

import 'package:plugin_platform_interface/plugin_platform_interface.dart'
    show PlatformInterface;
import 'package:status_bar_android/src/status_bar_android_method_channel.dart'
    show MethodChannelStatusBarAndroid;

/// The contract every platform implementation of `status_bar_android`
/// fulfils.
///
/// The public [StatusBar] facade talks only to [instance]; tests replace
/// [instance] with a mock to exercise the facade without a method
/// channel.
abstract class StatusBarAndroidPlatform extends PlatformInterface {
  /// Constructs a [StatusBarAndroidPlatform].
  StatusBarAndroidPlatform() : super(token: _token);

  static final Object _token = Object();

  static StatusBarAndroidPlatform _instance = MethodChannelStatusBarAndroid();

  /// The active implementation.
  ///
  /// Defaults to [MethodChannelStatusBarAndroid].
  static StatusBarAndroidPlatform get instance => _instance;

  /// Replaces the active implementation.
  ///
  /// The replacement must extend this class (not merely implement it) or
  /// mix in `MockPlatformInterfaceMixin`; [PlatformInterface.verifyToken]
  /// enforces that.
  static set instance(StatusBarAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Hides the status bar when [isHidden] is `true`, shows it otherwise.
  Future<void> setVisibility({required bool isHidden});
}
