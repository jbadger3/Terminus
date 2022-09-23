// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Terminus",
    platforms: [.macOS(.v12)],
    products: [
        .library(
            name: "Terminus",
            targets: ["Terminus"]),
        .executable(name: "TerminusTest", targets: ["TerminusTestApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Terminus",
            dependencies: []),
        .executableTarget(name: "TerminusTestApp", dependencies: ["Terminus", .product(name: "ArgumentParser", package: "swift-argument-parser")]),
        .testTarget(
           name: "TerminusTests",
           dependencies: ["Terminus"]),
    ]
)
