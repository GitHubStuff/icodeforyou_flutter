// plugins/status_bar_ios/ios/status_bar_ios/Sources/status_bar_ios/StatusBarFlutterViewController.swift
import Flutter
import UIKit

/// A `FlutterViewController` whose status bar is set before the first frame is
/// drawn, so there is no visible change between the launch screen and Flutter.
///
/// Apps use this as the root view controller instead of `FlutterViewController`
/// (set it as the custom class of the view controller in `Main.storyboard`,
/// module `status_bar_ios`).
///
/// Status bar content is always light (white time, battery, signal),
/// matching the Android plugin's launch theme. Override
/// `isStatusBarHiddenAtLaunch` to start with the status bar shown.
open class StatusBarFlutterViewController: FlutterViewController {

  /// Whether the status bar is hidden when the controller is created.
  open var isStatusBarHiddenAtLaunch: Bool { true }

  private lazy var isStatusBarHidden: Bool = isStatusBarHiddenAtLaunch

  override open var prefersStatusBarHidden: Bool { isStatusBarHidden }

  override open var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

  override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    .none
  }

  /// Hides the status bar when `isHidden` is `true`, shows it otherwise.
  /// Instant.
  func setStatusBarHidden(_ isHidden: Bool) {
    isStatusBarHidden = isHidden
    setNeedsStatusBarAppearanceUpdate()
  }
}