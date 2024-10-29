// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Entry",
    platforms: [.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TreeListView",
            targets: ["TreeListView"]),
        .library(
            name: "MenuView",
            targets: ["MenuView"]),
        .library(
            name: "GroupTableView",
            targets: ["GroupTableView"]),
    ],
    dependencies: [
        .package(name: "Domain", path: "../Domain"),
        .package(name: "Styleguide", path: "../Styleguide"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TreeListView",
            dependencies: [
                "MenuView",
                .product(name: "Entities", package: "Domain"),
                .product(name: "AppState", package: "Domain"),
                .product(name: "UseCaseProtocol", package: "Domain"),
                .product(name: "DomainTestHelpers", package: "Domain"),
            ]
        ),
        .target(
            name: "MenuView",
            dependencies: [
                .product(name: "Entities", package: "Domain"),
                .product(name: "AppState", package: "Domain"),
                .product(name: "Functions", package: "Domain"),
                .product(name: "UseCaseProtocol", package: "Domain"),
                .product(name: "DomainTestHelpers", package: "Domain"),
                .product(name: "Styleguide", package: "Styleguide"),
            ]
        ),
        .target(
            name: "GroupTableView",
            dependencies: [
                "MenuView",
                .product(name: "Entities", package: "Domain"),
                .product(name: "AppState", package: "Domain"),
                .product(name: "UseCaseProtocol", package: "Domain"),
                .product(name: "DomainTestHelpers", package: "Domain"),
            ]
        ),
        .testTarget(
            name: "EntryTests",
            dependencies: []),
    ]
)
