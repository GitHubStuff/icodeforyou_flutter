// packages/status_bar_visibility/lib/src/status_bar_visibility.dart

import 'dart:async';

import 'package:custom_errors/custom_errors.dart'
    show AlreadyInitializedError, NotInitializedError, PluginError;
import 'package:flutter/cupertino.dart';
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

  static bool _isInitialized = false;
  static bool? _isHidden;

  /// Whether the status bar visibility state has been successfully set at
  /// least once.
  @override
  bool isInitialized() => _isInitialized;

  /// Whether the status bar is currently hidden.
  ///
  /// Returns `false` if the visibility has not yet been initialized.
  @override
  bool isBarHidden() {
    if (_isHidden != null) return _isHidden!;
    throw NotInitializedError('StatusBarVisibility');
  }

  @override
  Future<bool> initialize({required bool isHidden}) async {
    if (_isInitialized) throw AlreadyInitializedError('StatusBarVisibility');
    _isInitialized = await _dispatchPlatformSetVisibility(isHidden: isHidden);
    if (_isInitialized) _isHidden = isHidden;
    return _isInitialized;
  }

  /// Sets the visibility of the status bar.
  ///
  /// Updates internal tracking and returns `true` if the platform successfully
  /// applied the change; otherwise, returns `false`.
  ///
  /// Throws a [PluginError] if the underlying platform call fails.
  @override
  Future<bool> setStatusBarVisibility({required bool isHidden}) async {
    if (_isHidden == null) throw NotInitializedError('StatusBarVisiblity');
    _isInitialized = await _dispatchPlatformSetVisibility(isHidden: isHidden);
    if (_isInitialized) _isHidden = isHidden;
    return _isInitialized;
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
      switch (OSPlatform.current) {
        case .android:
          await android.StatusBar.setVisibility(isHidden: isHidden);
          return true;
        case .iOS:
          await ios.StatusBar.setVisibility(isHidden: isHidden);
          return true;
        case .fuchsia:
        case .linux:
        case .macOS:
        case .web:
        case .windows:
          return false;
      }
    } on Exception catch (_) {
      throw PluginError('StatusBar Visiblity');
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
