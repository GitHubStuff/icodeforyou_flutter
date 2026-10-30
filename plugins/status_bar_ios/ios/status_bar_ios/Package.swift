// swift-tools-version: 6.4
// plugins/status_bar_ios/ios/status_bar_ios/Package.swift

import PackageDescription

let package = Package(
  name: "status_bar_ios",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(name: "status-bar-ios", targets: ["status_bar_ios"])
  ],
  dependencies: [
    .package(name: "FlutterFramework", path: "../FlutterFramework")
  ],
  targets: [
    .target(
      name: "status_bar_ios",
      dependencies: [
        .product(name: "FlutterFramework", package: "FlutterFramework")
      ],
      resources: [
        .process("PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    )
  ]
)