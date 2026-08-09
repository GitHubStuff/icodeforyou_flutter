// programs/{{name.snakeCase()}}/ios/Runner/StatusBarFlutterViewController.swift
import Flutter
import UIKit

/// icodeforyou.com
/// A FlutterViewController that reports the status bar as hidden until the
/// first Flutter frame has rendered.
///
/// Why this exists: the Info.plist `UIStatusBarHidden` key only governs the
/// native launch screen. The moment this view controller appears, UIKit asks
/// it `prefersStatusBarHidden`, and FlutterViewController's internal flag
/// starts as *visible* — it only flips when the Dart-side
/// `setStatusBarHidden(hidden: true)` message from `main()` is processed.
/// The status bar flashing in during that gap is the symptom this class
/// removes.
///
/// Once `isDisplayingFlutterUI` is true (first frame rendered), this defers
/// to `super`, i.e. to whatever Dart last requested via SystemChrome /
/// StatusBarChameleon — so normal runtime control is unaffected.
final class StatusBarFlutterViewController: FlutterViewController {
  override var prefersStatusBarHidden: Bool {
    isDisplayingFlutterUI ? super.prefersStatusBarHidden : true
  }
}