// plugins/island_control_ios/ios/island_control_ios/Sources/island_control_ios/IslandControlIosPlugin.swift
@preconcurrency import Flutter
import UIKit

/// Bridges the `island_control_ios` method channel to `Island`.
///
/// Method channel callbacks arrive on the platform (main) thread, so the
/// whole plugin is main-actor isolated; `@preconcurrency` on the conformance
/// lets it satisfy Flutter's un-annotated protocol.
@MainActor
public final class IslandControlIosPlugin: NSObject, @preconcurrency FlutterPlugin {

  private enum Channel {
    static let name = "island_control_ios"
    static let methodSetIsland = "setIsland"
    static let argIsHidden = "isHidden"
    static let errorArgument = "argument"
    static let errorNoWindow = "no_window"
    static let errorNoController = "no_controller"
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: Channel.name,
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(IslandControlIosPlugin(), channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case Channel.methodSetIsland:
      setIsland(call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func setIsland(_ call: FlutterMethodCall, result: FlutterResult) {
    guard
      let args = call.arguments as? [String: Any],
      let isHidden = args[Channel.argIsHidden] as? Bool
    else {
      result(
        FlutterError(
          code: Channel.errorArgument,
          message: "'\(Channel.argIsHidden)' must be a Bool",
          details: nil
        )
      )
      return
    }

    guard let window = Self.keyWindow else {
      result(
        FlutterError(code: Channel.errorNoWindow, message: "No key window", details: nil)
      )
      return
    }

    do {
      try Island(window: window).setHidden(isHidden)
      result(nil)
    } catch {
      result(
        FlutterError(
          code: Channel.errorNoController,
          message: "Root view controller is not an IslandFlutterViewController",
          details: nil
        )
      )
    }
  }

  private static var keyWindow: UIWindow? {
    let windows = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
    return windows.first(where: \.isKeyWindow) ?? windows.first
  }
}