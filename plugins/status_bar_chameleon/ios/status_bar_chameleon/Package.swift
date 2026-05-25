// swift-tools-version: 5.9
// plugins/status_bar_chameleon/ios/status_bar_chameleon/Package.swift

import PackageDescription

let package = Package(
  name: "status_bar_chameleon",
  platforms: [
    .iOS("13.0")
  ],
  products: [
    .library(name: "status-bar-chameleon", targets: ["status_bar_chameleon"])
  ],
  dependencies: [
    .package(name: "FlutterFramework", path: "../FlutterFramework")
  ],
  targets: [
    .target(
      name: "status_bar_chameleon",
      dependencies: [
        .product(name: "FlutterFramework", package: "FlutterFramework")
      ],
      resources: [
        .process("Resources")
      ]
    )
  ]
)