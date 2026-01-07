// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Entities",
            targets: ["Entities"]),
        .library(
            name: "AppState",
            targets: ["AppState"]),
        .library(
            name: "RepositoryProtocol",
            targets: ["RepositoryProtocol"]),
        .library(
            name: "UseCases",
            targets: ["UseCases"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Entities",
            dependencies: []
        ),
        .target(
            name: "AppState",
            dependencies: ["Entities"]
        ),
        .target(
            name: "RepositoryProtocol",
            dependencies: ["Entities"]
        ),
        .target(
            name: "UseCases",
            dependencies: ["RepositoryProtocol"]
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Entities", "RepositoryProtocol", "UseCases"]),
    ]
)
