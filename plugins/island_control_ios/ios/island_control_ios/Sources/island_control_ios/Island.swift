// plugins/island_control_ios/ios/island_control_ios/Sources/island_control_ios/Island.swift
import UIKit

/// Shows or hides the status bar ("island") of a window without animation.
///
/// iOS derives status bar visibility from the window's root view controller,
/// so the root must be an `IslandFlutterViewController`; anything else is
/// reported as `Island.Failure.noController`, the iOS counterpart of the
/// Android plugin's `no_activity`.
@MainActor
struct Island {

  /// Why the island could not be changed.
  enum Failure: Error {
    /// The window's root view controller is not an `IslandFlutterViewController`.
    case noController
  }

  private let window: UIWindow

  init(window: UIWindow) {
    self.window = window
  }

  /// Hides the island when `isHidden` is `true`, shows it otherwise. Instant.
  func setHidden(_ isHidden: Bool) throws(Failure) {
    guard let controller = window.rootViewController as? IslandFlutterViewController else {
      throw .noController
    }
    controller.setIslandHidden(isHidden)
  }
}
