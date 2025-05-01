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
                "GlassBoardFeature",
                "StyleGuide",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "./Sources/Features/AppRootFeature"
        ),
        .target(
            name: "GlassBoardFeature",
            dependencies: [
                "MTLRenderer",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "./Sources/Features/GlassBoardFeature"
        ),
        
        .target(
            name: "MTLRenderer",
            dependencies: [
            ],
            path: "./Sources/Services/MTLRenderer",
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
