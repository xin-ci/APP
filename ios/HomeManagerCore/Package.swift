// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HomeManagerCore",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "HomeManagerCore",
            targets: ["HomeManagerCore"]
        )
    ],
    targets: [
        .target(
            name: "HomeManagerCore"
        ),
        .testTarget(
            name: "HomeManagerCoreTests",
            dependencies: ["HomeManagerCore"]
        )
    ]
)
