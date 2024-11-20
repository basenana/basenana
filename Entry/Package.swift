// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Entry",
    platforms: [.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GroupTable",
            targets: ["GroupTable"]),
    ],
    dependencies: [
        .package(name: "Domain", path: "../Domain"),
        .package(name: "Styleguide", path: "../Styleguide"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GroupTable",
            dependencies: [
                .product(name: "Entities", package: "Domain"),
                .product(name: "AppState", package: "Domain"),
                .product(name: "UseCaseProtocol", package: "Domain"),
                .product(name: "DomainTestHelpers", package: "Domain"),
                .product(name: "Styleguide", package: "Styleguide"),
            ]
        ),
        .testTarget(
            name: "EntryTests",
            dependencies: []),
    ]
)
