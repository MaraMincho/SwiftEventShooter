// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftEventShooter",
  platforms: [.iOS(.v15), .macOS(.v13), .visionOS(.v1), .tvOS(.v13)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "SwiftEventShooter",
      targets: ["SwiftEventShooter"]
    ),
  ], targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "SwiftEventShooter"),
    .testTarget(
      name: "SwiftEventShooterTests",
      dependencies: ["SwiftEventShooter"]
    ),
  ],
  swiftLanguageModes: [.v6, .v5]
)
