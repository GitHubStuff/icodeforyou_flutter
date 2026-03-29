// platform_utils/lib/src/platform/platform_identifier.dart
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Defines the contract for platform detection.
abstract class PlatformIdentifier {
  /// const constructor for subclasses.
  const PlatformIdentifier();

  /// Whether the app is running on the web.
  bool get isWeb;

  /// Whether the app is running on iOS.
  bool get isIOS;

  /// Whether the app is running on Android.
  bool get isAndroid;

  /// Whether the app is running on macOS.
  bool get isMacOS;

  /// Whether the app is running on Windows.
  bool get isWindows;

  /// Whether the app is running on Linux.
  bool get isLinux;

  /// A human-readable name for the current platform.
  String get platformName;
}

/// Default implementation of [PlatformIdentifier] with injectable
/// checkers for testability.
class DefaultPlatformIdentifier extends PlatformIdentifier {
  /// Creates a [DefaultPlatformIdentifier], optionally overriding
  /// any platform checker for testing purposes.
  const DefaultPlatformIdentifier({
    this.webChecker = _defaultWebChecker,
    this.iosChecker = _defaultIosChecker,
    this.androidChecker = _defaultAndroidChecker,
    this.macosChecker = _defaultMacosChecker,
    this.windowsChecker = _defaultWindowsChecker,
    this.linuxChecker = _defaultLinuxChecker,
  });

  /// Override for web detection; defaults to [kIsWeb].
  final bool Function() webChecker;

  /// Override for iOS detection.
  final bool Function() iosChecker;

  /// Override for Android detection.
  final bool Function() androidChecker;

  /// Override for macOS detection.
  final bool Function() macosChecker;

  /// Override for Windows detection.
  final bool Function() windowsChecker;

  /// Override for Linux detection.
  final bool Function() linuxChecker;

  static bool _defaultWebChecker() => kIsWeb;
  static bool _defaultIosChecker() => !kIsWeb && Platform.isIOS;
  static bool _defaultAndroidChecker() => !kIsWeb && Platform.isAndroid;
  static bool _defaultMacosChecker() => !kIsWeb && Platform.isMacOS;
  static bool _defaultWindowsChecker() => !kIsWeb && Platform.isWindows;
  static bool _defaultLinuxChecker() => !kIsWeb && Platform.isLinux;

  @override
  bool get isWeb => webChecker();

  @override
  bool get isIOS => iosChecker();

  @override
  bool get isAndroid => androidChecker();

  @override
  bool get isMacOS => macosChecker();

  @override
  bool get isWindows => windowsChecker();

  @override
  bool get isLinux => linuxChecker();

  @override
  String get platformName {
    if (isWeb) return 'Web';
    if (isIOS) return 'iOS';
    if (isAndroid) return 'Android';
    if (isMacOS) return 'macOS';
    if (isWindows) return 'Windows';
    if (isLinux) return 'Linux';
    return 'Unknown';
  }
}
