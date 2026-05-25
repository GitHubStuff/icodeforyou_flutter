import Flutter
import ObjectiveC.runtime
import UIKit

final class StatusBarChameleonSwizzler {
  private static var installed = false

  static func install() {
    guard !installed else { return }
    installed = true

    let selector = #selector(getter: UIViewController.prefersStatusBarHidden)

    let block: @convention(block) (AnyObject) -> Bool = { _ in
      StatusBarChameleonController.isHidden()
    }

    let implementation = imp_implementationWithBlock(block)

    class_replaceMethod(
      FlutterViewController.self,
      selector,
      implementation,
      "c@:"
    )
  }
}