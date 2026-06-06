// plugins/status_bar_chameleon/ios/status_bar_chameleon/Sources/status_bar_chameleon/StatusBarChameleonPlugin.swift
import Flutter
import UIKit

private final class ChameleonFlutterViewController: FlutterViewController {
  static var hidden = false

  override var prefersStatusBarHidden: Bool {
    ChameleonFlutterViewController.hidden
  }

  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    .fade
  }
}

@objc public class StatusBarChameleonPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "status_bar_chameleon/status_bar",
      binaryMessenger: registrar.messenger()
    )
    let instance = StatusBarChameleonPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard call.method == "setStatusBarHidden" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard
      let args = call.arguments as? [String: Any],
      let hidden = args["hidden"] as? Bool
    else {
      result(
        FlutterError(
          code: "BAD_ARGS",
          message: "Expected { hidden: Bool }",
          details: nil
        )
      )
      return
    }

    ChameleonFlutterViewController.hidden = hidden

    DispatchQueue.main.async {
      guard
        let scene = UIApplication.shared.connectedScenes
          .compactMap({ $0 as? UIWindowScene })
          .first,
        let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first
      else {
        result(nil)
        return
      }

      if let existing = window.rootViewController as? ChameleonFlutterViewController {
        existing.setNeedsStatusBarAppearanceUpdate()
      } else if let existing = window.rootViewController as? FlutterViewController {
        let replacement = ChameleonFlutterViewController(
          engine: existing.engine,
          nibName: nil,
          bundle: nil
        )
        window.rootViewController = replacement
        replacement.setNeedsStatusBarAppearanceUpdate()
      }

      result(nil)
    }
  }
}
