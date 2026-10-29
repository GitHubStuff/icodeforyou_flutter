// packages/island_control/lib/src/island_control.dart

import 'dart:async' show unawaited;

import 'package:island_control_android/island_control_android.dart'
    show IslandControlAndroid;
import 'package:island_control_ios/island_control_ios.dart'
    show IslandControlIos;
import 'package:platform_tools/platform_tools.dart' show OSPlatform;
import 'package:status_bar_android/status_bar_android.dart';

/// Platform-agnostic facade for showing or hiding the device's "island".
///
/// On Android the island is the status-bar notch region; on iOS it is the
/// Dynamic Island / sensor housing. [IslandControl] dispatches to the
/// platform-specific implementation ([IslandControlAndroid] or
/// [IslandControlIos]) based on [OSPlatform.current], and is a no-op on
/// every other platform.
///
/// The last requested visibility is cached in [isHidden] so callers can
/// query the intended state without a platform round-trip.
///
/// Example:
///
/// ```dart
/// IslandControl.setIsland();
/// assert(IslandControl.isHidden);
/// ```
class IslandControl {
  /// Cached visibility state. Defaults to `false` (visible).
  static bool _isHidden = false;

  /// Whether the island is currently hidden.
  ///
  /// Reflects the most recent value passed to [setIsland], not a live
  /// reading from the platform. Defaults to `false` (visible) until
  /// [setIsland] is called.
  static bool get isHidden => _isHidden;

  /// Shows or hides the island.
  ///
  /// Updates [isHidden] synchronously, then forwards the request to the
  /// platform implementation as a fire-and-forget call ([unawaited]). This
  /// method returns as soon as the request has been dispatched; the platform
  /// may apply the change slightly later.
  ///
  /// Supported platforms:
  /// * **Android** — delegates to [IslandControlAndroid.setIsland].
  /// * **iOS** — delegates to [IslandControlIos.setIsland].
  ///
  /// On Fuchsia, Linux, macOS, web, and Windows this method only updates
  /// [isHidden] and performs no platform work.
  ///
  /// [isHidden] defaults to `true`, so calling `setIsland()` with no
  /// arguments hides the island.
  static void setIsland({bool isHidden = true}) {
    _isHidden = isHidden;
    switch (OSPlatform.current) {
      case .android:
        return unawaited(StatusBar.setVisibility(isHidden: isHidden));
      case .fuchsia:
        return;
      case .iOS:
        return unawaited(IslandControlIos.setIsland(isHidden: isHidden));
      case .linux:
      case .macOS:
      case .web:
      case .windows:
        return;
    }
  }
}
