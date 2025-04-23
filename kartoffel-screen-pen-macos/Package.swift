// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "kartoffel-screen-pen-macos",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "AppRootFeature",
            targets: ["AppRootFeature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.19.1"),
    ],
    targets: [
        .target(
            name: "AppRootFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "./Sources/Features/AppRootFeature"
        ),
    ]
)
