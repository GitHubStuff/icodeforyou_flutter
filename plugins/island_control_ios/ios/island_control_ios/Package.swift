// swift-tools-version: 6.4
// plugins/island_control_ios/ios/island_control_ios/Package.swift

import PackageDescription

let package = Package(
  name: "island_control_ios",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(name: "island-control-ios", targets: ["island_control_ios"])
  ],
  dependencies: [
    .package(name: "FlutterFramework", path: "../FlutterFramework")
  ],
  targets: [
    .target(
      name: "island_control_ios",
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