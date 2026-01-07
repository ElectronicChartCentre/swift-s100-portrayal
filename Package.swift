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
        .package(path: "../swift-s101")
    ],
    targets: [
        .target(
            name: "SwiftS100Portrayal",
            dependencies: [
                .product(name: "SwiftS101", package: "swift-s101")
            ],
            resources: [
                .copy("Resources/")
            ]
        ),
        .testTarget(
            name: "SwiftS100PortrayalTests",
            dependencies: ["SwiftS100Portrayal"]
        ),
    ]
)
