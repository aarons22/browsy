// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "BrowsyShared",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "BrowsyShared",
            targets: ["BrowsyShared"]
        )
    ],
    targets: [
        .target(
            name: "BrowsyShared",
            dependencies: []
        ),
        .testTarget(
            name: "BrowsySharedTests",
            dependencies: ["BrowsyShared"]
        )
    ]
)
