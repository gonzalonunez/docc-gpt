// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "Example",
  products: [
    .library(
      name: "Example",
      targets: ["Example"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "Example",
      dependencies: []),

    .testTarget(
      name: "ExampleTests",
      dependencies: ["Example"]),
  ]
)
