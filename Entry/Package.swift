// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Entry",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GroupTable",
            targets: ["GroupTable"]),
    ],
    dependencies: [
        .package(name: "Domain", path: "../Domain"),
        .package(name: "Styleguide", path: "../Styleguide"),
        .package(url: "https://github.com/nmdias/FeedKit", from: "9.1.2"),
        .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.7.2"),
        .package( url: "https://github.com/cezheng/Fuzi", from: "3.1.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GroupTable",
            dependencies: [
                "WebPage",
                .product(name: "Entities", package: "Domain"),
                .product(name: "AppState", package: "Domain"),
                .product(name: "UseCases", package: "Domain"),
                .product(name: "Styleguide", package: "Styleguide"),
                .product(name: "FeedKit", package: "FeedKit"),
            ]
        ),
        .target(
            name: "WebPage",
            dependencies: [
                .product(name: "Fuzi", package: "Fuzi"),
                .product(name: "SwiftSoup", package: "SwiftSoup"),
            ],
            resources: [
                .process("Readability/Readability.js"),
                .process("Readability/readability_images.js"),
                .process("Readability/readability_initialization.js"),
            ]
        ),
        .testTarget(
            name: "EntryTests",
            dependencies: []),
    ]
)
