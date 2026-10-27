// plugins/island_control_ios/ios/island_control_ios/Sources/island_control_ios/IslandFlutterViewController.swift
import Flutter
import UIKit

/// A `FlutterViewController` whose island is set before the first frame is
/// drawn, so there is no visible change between the launch screen and Flutter.
///
/// Apps use this as the root view controller instead of `FlutterViewController`
/// (set it as the custom class of the view controller in `Main.storyboard`,
/// module `island_control_ios`).
///
/// Island content is always light (white time, battery, signal), matching the
/// Android plugin's launch theme. Override `isIslandHiddenAtLaunch` to start
/// with the island shown.
open class IslandFlutterViewController: FlutterViewController {

  /// Whether the island is hidden when the controller is created.
  open var isIslandHiddenAtLaunch: Bool { true }

  private lazy var isIslandHidden: Bool = isIslandHiddenAtLaunch

  override open var prefersStatusBarHidden: Bool { isIslandHidden }

  override open var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

  override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .none }

  /// Hides the island when `isHidden` is `true`, shows it otherwise. Instant.
  func setIslandHidden(_ isHidden: Bool) {
    isIslandHidden = isHidden
    setNeedsStatusBarAppearanceUpdate()
  }
}