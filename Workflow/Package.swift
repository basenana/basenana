// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Workflow",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Workflow",
            targets: ["Workflow"]),
    ],
    dependencies: [
        .package(name: "Domain", path: "../Domain"),
        .package(name: "Styleguide", path: "../Styleguide"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Workflow",
            dependencies: [
                .product(name: "Entities", package: "Domain"),
                .product(name: "AppState", package: "Domain"),
                .product(name: "UseCases", package: "Domain"),
            ]
        ),
        .testTarget(
            name: "WorkflowTests",
            dependencies: ["Workflow"]),
    ]
)
