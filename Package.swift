// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "DoccGPT",
  platforms: [.macOS(.v12)],
  products: [
    .executable(
      name: "docc-gpt",
      targets: ["docc-gpt"]),

    .library(
      name: "Example",
      targets: ["Example"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.2"),
    .package(url: "https://github.com/apple/swift-log", from: "1.5.2"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "0.5.0"),
  ],
  targets: [
    .target(
      name: "Example",
      dependencies: []),

    .executableTarget(
      name: "docc-gpt",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "Logging", package: "swift-log"),
      ],
      resources: [
        .process("Resources")
      ]),
  ]
)
