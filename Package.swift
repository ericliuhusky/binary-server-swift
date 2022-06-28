// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "binary-server-swift",
    platforms: [.macOS(.v12)],
    products: [
        .executable(
            name: "binary-server-swift",
            targets: ["binary-server-swift"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "binary-server-swift",
            dependencies: [.product(name: "Vapor", package: "vapor")]),
        .testTarget(
            name: "binary-server-swiftTests",
            dependencies: ["binary-server-swift"]),
    ]
)
