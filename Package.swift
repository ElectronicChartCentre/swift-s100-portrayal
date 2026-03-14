// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-s100-portrayal",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "SwiftS100Portrayal",
            targets: ["SwiftS100Portrayal"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ElectronicChartCentre/swift-s101", from: "0.0.1"),
        //.package(path: "../swift-s101"),
        .package(url: "https://github.com/ElectronicChartCentre/swift-s100-feature-catalogue", from: "0.0.1"),
        //.package(path: "../swift-s100-feature-catalogue"),
        //.package(url: "https://github.com/SwiftyLua/SwiftyLua", from: "0.1.0"),
        .package(url: "https://github.com/halset/SwiftyLua", branch: "toretemp"),
        //.package(path: "../ext/SwiftyLua"),
        //.package(url: "https://github.com/PureSwift/Silica", branch: "master"),
        .package(url: "https://github.com/halset/Silica", branch: "work"),
        //.package(path: "../ext/Silica"),
        .package(url: "https://github.com/ElectronicChartCentre/swift-vector-tile", from: "0.0.1"),
        //.package(path: "../swift-vector-tile"),
    ],
    targets: [
        .target(
            name: "SwiftS100Portrayal",
            dependencies: [
                .product(name: "SwiftS101", package: "swift-s101"),
                .product(name: "SwiftS100FeatureCatalogue", package: "swift-s100-feature-catalogue"),
                .product(name: "SwiftyLua", package: "SwiftyLua"),
                .product(name: "Silica", package: "Silica", condition: .when(platforms: [.linux])),
                .product(name: "SwiftVectorTile", package: "swift-vector-tile"),
            ],
        ),
        .testTarget(
            name: "SwiftS100PortrayalTests",
            dependencies: ["SwiftS100Portrayal"],
            resources: [.copy("TestResources")]
        ),
    ]
)
