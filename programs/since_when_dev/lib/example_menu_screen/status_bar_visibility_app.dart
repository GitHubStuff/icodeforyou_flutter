import 'dart:async';

import 'package:custom_errors/custom_errors.dart' show PluginError;
import 'package:flutter/foundation.dart';
import 'package:platform_tools/platform_tools.dart' show OSPlatform;
import 'package:status_bar_android/status_bar_android.dart'
    as android
    show StatusBar;
import 'package:status_bar_ios/status_bar_ios.dart' as ios show StatusBar;
import 'package:status_bar_visibility_abstract/status_bar_visibility_abstract.dart'
    show StatusBarVisibilityAbstract;

/// Default implementation of [StatusBarVisibilityAbstract] that delegates
/// visibility changes to the host platform.
class StatusBarVisibility implements StatusBarVisibilityAbstract {
  /// Creates a new [StatusBarVisibility] instance.
  StatusBarVisibility();

  static final StatusBarVisibility _instance = StatusBarVisibility();

  /// Default singleton instance.
  static StatusBarVisibility get instance => _instance;

  bool _isInitialized = false;
  bool? _isHidden;

  /// Whether the host platform supports status bar visibility changes.
  static bool get isSupported {
    final platform = OSPlatform.current;
    return platform == OSPlatform.android || platform == OSPlatform.iOS;
  }

  /// Convenience getter matching static access in app code.
  static bool? get isHidden => _instance._isHidden;

  /// Initializes status bar visibility state.
  static Future<bool> init() async {
    _instance._isInitialized = true;
    return isSupported;
  }

  /// Sets visibility statically via the default instance.
  static Future<bool> setVisibility({required bool isHidden}) =>
      _instance.setStatusBarVisibility(isHidden: isHidden);

  /// Whether the status bar visibility state has been successfully set at
  /// least once.
  @override
  bool isInitialized() => _isInitialized;

  /// Whether the status bar is currently hidden.
  ///
  /// Returns `false` if the visibility has not yet been initialized.
  @override
  bool isBarHidden() => _isHidden ?? false;

  /// Sets the visibility of the status bar.
  ///
  /// Updates internal tracking and returns `true` if the platform successfully
  /// applied the change; otherwise, returns `false`.
  ///
  /// Throws a [PluginError] if the underlying platform call fails.
  @override
  Future<bool> setStatusBarVisibility({required bool isHidden}) async {
    final success = await _dispatchPlatformSetVisibility(isHidden: isHidden);
    if (success) {
      _isHidden = isHidden;
      _isInitialized = true;
    }
    return success;
  }

  /// Dispatches the visibility update to the active platform's status bar
  /// implementation.
  ///
  /// Returns `true` if the platform is supported and executed the call,
  /// or `false` if the platform does not support status bar manipulation.
  ///
  /// Throws a [PluginError] if the platform invocation throws an [Exception].
  Future<bool> _dispatchPlatformSetVisibility({required bool isHidden}) async {
    try {
      final platform = OSPlatform.current;
      switch (platform) {
        case OSPlatform.android:
          await android.StatusBar.setVisibility(isHidden: isHidden);
          return true;
        case OSPlatform.iOS:
          await ios.StatusBar.setVisibility(isHidden: isHidden);
          return true;
        case OSPlatform.fuchsia:
        case OSPlatform.linux:
        case OSPlatform.macOS:
        case OSPlatform.web:
        case OSPlatform.windows:
          return false;
      }
    } on Exception catch (_) {
      throw PluginError('StatusBar Visibility');
    }
  }

  /// Resets the internal state of [StatusBarVisibility] to uninitialized.
  ///
  /// Intended strictly for unit and integration testing.
  @visibleForTesting
  void reset() {
    _isInitialized = false;
    _isHidden = null;
  }
}
