// packages/status_bar_visibility/lib/src/status_bar_visibility.dart

import 'dart:async' show unawaited;

import 'package:custom_errors/custom_errors.dart'
    show AlreadyInitializedError, NotInitializedError;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:platform_tools/platform_tools.dart' show OSPlatform;
import 'package:status_bar_android/status_bar_android.dart'
    as android
    show StatusBar;
import 'package:status_bar_ios/status_bar_ios.dart' as ios show StatusBar;

/// A utility class for managing the visibility of the system status bar across
/// supported mobile platforms (Android and iOS).
///
/// Must be initialized via [init] before updating or checking visibility state.
class StatusBarVisibility {
  static bool? _isHidden;

  /// Whether the status bar is currently hidden.
  ///
  /// Returns `null` if [init] has not yet been called.
  static bool? get isHidden => _isHidden;

  // Whether the current platform supports status bar visibility toggling.
  ///
  /// `true` on Android and iOS; `false` on Fuchsia, Linux, macOS, Web and
  /// Windows. A pure query: safe to call before [init].
  static bool get isSupported => switch (OSPlatform.current) {
    .android || .iOS => true,
    .fuchsia || .linux || .macOS || .web || .windows => false,
  };

  /// Initializes the status bar configuration and sets the initial visibility.
  ///
  /// Configures the system UI overlay to [SystemUiMode.edgeToEdge] and applies
  /// the desired visibility using [setHidden] (defaults to `true`).
  ///
  /// Returns a [Future] that resolves to `true` if the platform supports status
  /// bar visibility toggling (Android/iOS), or `false` otherwise.
  static Future<bool> init({bool setHidden = true}) async {
    if (_isHidden != null) throw AlreadyInitializedError('StatusBarVisibility');
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _isHidden = setHidden;
    return setVisibility(isHidden: setHidden);
  }

  /// Sets whether the status bar should be hidden or visible.
  ///
  /// If [isHidden] is `true`, the status bar will be hidden; if `false`, it
  /// will be displayed.
  ///
  /// Returns `true` if the current platform supports status bar visibility
  /// modifications (Android and iOS), or `false` for unsupported platforms
  /// (Fuchsia, Linux, macOS, Web, Windows).
  ///
  /// Throws a [NotInitializedError] if called before [init].
  static bool setVisibility({bool isHidden = true}) {
    if (_isHidden == null) throw NotInitializedError('StatusBarVisibility');
    _isHidden = isHidden;
    switch (OSPlatform.current) {
      case .android:
        unawaited(android.StatusBar.setVisibility(isHidden: isHidden));
        return true;
      case .iOS:
        unawaited(ios.StatusBar.setVisibility(isHidden: isHidden));
        return true;
      case .fuchsia:
      case .linux:
      case .macOS:
      case .web:
      case .windows:
        return false;
    }
  }

  /// Resets the internal state of [StatusBarVisibility] to uninitialized.
  ///
  /// Intended strictly for unit and integration testing.
  @visibleForTesting
  static void reset() => _isHidden = null;
}
