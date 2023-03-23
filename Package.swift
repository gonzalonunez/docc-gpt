// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "DoccGPT",
  platforms: [.macOS(.v12)],
  products: [
    .executable(
      name: "docc-gpt",
      targets: ["DoccGPT"]),

    .library(
      name: "Example",
      targets: ["Example"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.2")
  ],
  targets: [
    .target(
      name: "Example",
      dependencies: []),

    .executableTarget(
      name: "DoccGPT",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ],
      resources: [
        .process("Resources/prompt.txt")
      ]),
  ]
)
