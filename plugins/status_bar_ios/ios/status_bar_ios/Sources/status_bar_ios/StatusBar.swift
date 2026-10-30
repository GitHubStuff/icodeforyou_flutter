// plugins/status_bar_ios/ios/status_bar_ios/Sources/status_bar_ios/StatusBar.swift
import UIKit

/// Shows or hides the status bar of a window without animation.
///
/// iOS derives status bar visibility from the window's root view controller,
/// so the root must be a `StatusBarFlutterViewController`; anything else is
/// reported as `StatusBar.Failure.noController`, the iOS counterpart of the
/// Android plugin's `no_activity`.
@MainActor
struct StatusBar {

  /// Why the status bar could not be changed.
  enum Failure: Error {
    /// The window's root view controller is not a
    /// `StatusBarFlutterViewController`.
    case noController
  }

  private let window: UIWindow

  init(window: UIWindow) {
    self.window = window
  }

  /// Hides the status bar when `isHidden` is `true`, shows it otherwise.
  /// Instant.
  func setHidden(_ isHidden: Bool) throws(Failure) {
    guard
      let controller = window.rootViewController
        as? StatusBarFlutterViewController
    else {
      throw .noController
    }
    controller.setStatusBarHidden(isHidden)
  }
}
