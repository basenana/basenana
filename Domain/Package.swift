// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Domain",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Entities",
            targets: ["Entities"]),
        .library(
            name: "RepositoryProtocol",
            targets: ["RepositoryProtocol"]),
        .library(
            name: "UseCaseProtocol",
            targets: ["UseCaseProtocol"]),
        .library(
            name: "UseCase",
            targets: ["UseCase"]),
        .library(
            name: "DomainTestHelpers",
            targets: ["DomainTestHelpers"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Entities",
            dependencies: []
        ),
        .target(
            name: "RepositoryProtocol",
            dependencies: ["Entities"]
        ),
        .target(
            name: "UseCaseProtocol",
            dependencies: ["Entities"]
        ),
        .target(
            name: "UseCase",
            dependencies: ["RepositoryProtocol", "UseCaseProtocol"]
        ),
        .target(
            name: "DomainTestHelpers",
            dependencies: ["Entities", "RepositoryProtocol", "UseCaseProtocol"]
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Entities", "RepositoryProtocol", "UseCase"]),
    ]
)
