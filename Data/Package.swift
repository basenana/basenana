// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Data",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library( name: "Repositories", targets: ["Repositories"]),
        .library( name: "NetworkCore", targets: ["NetworkCore"]),
        .library( name: "NetworkExtension", targets: ["NetworkExtension"]),
    ],
    dependencies: [
        .package(name: "Domain", path: "../Domain"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Repositories",
            dependencies: [
                "NetworkCore",
                "NetworkExtension",
                .product(name: "Entities", package: "Domain"),
                .product(name: "RepositoryProtocol", package: "Domain"),
            ]
        ),
        .target(
            name: "NetworkCore",
            dependencies: [
            ]
        ),
        .target(
            name: "NetworkExtension",
            dependencies: [
                "NetworkCore",
                .product(name: "AppState", package: "Domain"),
                .product(name: "Entities", package: "Domain"),
            ]
        ),
        .testTarget(
            name: "DataTests",
            dependencies: ["Repositories", "NetworkCore", "NetworkExtension"]),
    ]
)
