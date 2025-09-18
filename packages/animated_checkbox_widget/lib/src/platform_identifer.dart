// lib/src/platform_identifier.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

abstract class PlatformIdentifier {
  const PlatformIdentifier();
  bool get isWeb;
  bool get isIOS;
  bool get isAndroid;
  bool get isMacOS;
  bool get isWindows;
  bool get isLinux;
  String get platformName;
}

/// Testable implementation that allows dependency injection
class DefaultPlatformIdentifier extends PlatformIdentifier {
  final bool Function() webChecker;
  final bool Function() iosChecker;
  final bool Function() androidChecker;
  final bool Function() macosChecker;
  final bool Function() windowsChecker;
  final bool Function() linuxChecker;

  const DefaultPlatformIdentifier({
    this.webChecker = _defaultWebChecker,
    this.iosChecker = _defaultIosChecker,
    this.androidChecker = _defaultAndroidChecker,
    this.macosChecker = _defaultMacosChecker,
    this.windowsChecker = _defaultWindowsChecker,
    this.linuxChecker = _defaultLinuxChecker,
  });

  // Default implementations
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
