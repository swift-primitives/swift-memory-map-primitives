// swift-tools-version: 6.3.3

import PackageDescription

let package = Package(
    name: "swift-memory-map-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Memory Map Primitives",
            targets: ["Memory Map Primitives"]
        ),
        .library(
            name: "Memory Map Primitives Test Support",
            targets: ["Memory Map Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-memory-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-memory-lock-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-byte-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-error-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-span-primitives.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Memory Map Primitives",
            dependencies: [
                .product(name: "Memory Address Primitives", package: "swift-memory-primitives"),
                .product(name: "Memory Lock Primitives", package: "swift-memory-lock-primitives"),
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
                .product(name: "Error Primitives", package: "swift-error-primitives"),
                .product(name: "Span Protocol Primitives", package: "swift-span-primitives"),
            ]
        ),
        .target(
            name: "Memory Map Primitives Test Support",
            dependencies: [
                "Memory Map Primitives",
                .product(name: "Memory Primitives Test Support", package: "swift-memory-primitives"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Memory Map Primitives Tests",
            dependencies: [
                "Memory Map Primitives",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = [
        .enableExperimentalFeature("RawLayout"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
