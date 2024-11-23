// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Document",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DocumentRead",
            targets: ["DocumentRead"]),
    ],
    dependencies: [
        .package(name: "Domain", path: "../Domain"),
        .package(name: "Styleguide", path: "../Styleguide"),
        .package(url: "https://github.com/ciaranrobrien/SwiftUIMasonry", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DocumentRead",
            dependencies: [
                .product(name: "Entities", package: "Domain"),
                .product(name: "AppState", package: "Domain"),
                .product(name: "UseCaseProtocol", package: "Domain"),
                .product(name: "DomainTestHelpers", package: "Domain"),
                "SwiftUIMasonry",
            ]
        ),
        .testTarget(
            name: "DocumentTests",
            dependencies: []),
    ]
)
