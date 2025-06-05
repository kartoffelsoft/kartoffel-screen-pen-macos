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
            name: "AppKitUtils",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        
        .target(
            name: "Common",
        ),
        
        .target(
            name: "AppRootFeature",
            dependencies: [
                "AppKitUtils",
                "Common",
                "EventTapFeature",
                "GlassBoardFeature",
                "MenuFeature",
                "StyleGuide",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "./Sources/Features/AppRootFeature"
        ),
        .target(
            name: "EventTapFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "./Sources/Features/EventTapFeature"
        ),
        .target(
            name: "GlassBoardFeature",
            dependencies: [
                "Common",
                "MTLRenderer",
                "StyleGuide",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "./Sources/Features/GlassBoardFeature"
        ),
        .target(
            name: "HotKeyFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "./Sources/Features/HotKeyFeature"
        ),
        .target(
            name: "MenuFeature",
            dependencies: [
                "Common",
                "HotKeyFeature",
                "StyleGuide",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "./Sources/Features/MenuFeature"
        ),
        
        .target(
            name: "MTLRenderer",
            dependencies: [
            ],
            path: "./Sources/Graphics/MTLRenderer",
            publicHeadersPath: "Public",
            cxxSettings: [
                .unsafeFlags(["-std=c++20"]),
                .unsafeFlags([
                    "-I../deps/metal-cpp"
                ])
            ],
        ),
        
        .target(
            name: "StyleGuide",
            resources: [.process("Resources")]
        ),
    ]
)
