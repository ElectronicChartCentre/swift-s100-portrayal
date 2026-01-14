// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftS100Portrayal",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "SwiftS100Portrayal",
            targets: ["SwiftS100Portrayal"]
        ),
    ],
    dependencies: [
        //.package(url: "https://github.com/ElectronicChartCentre/swift-s101", from: "1.0.0"),
        .package(path: "../swift-s101"),
        .package(path: "../swift-s100-feature-catalogue"),
        .package(url: "https://github.com/SwiftyLua/SwiftyLua", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "SwiftS100Portrayal",
            dependencies: [
                .product(name: "SwiftS101", package: "swift-s101"),
                .product(name: "SwiftS100FeatureCatalogue", package: "swift-s100-feature-catalogue"),
                .product(name: "SwiftyLua", package: "SwiftyLua")
            ],
            resources: [
                .copy("Resources/")
            ]
        ),
        .testTarget(
            name: "SwiftS100PortrayalTests",
            dependencies: ["SwiftS100Portrayal"],
            resources: [.copy("TestResources")]
        ),
    ]
)
