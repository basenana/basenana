// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Inbox",
    platforms: [.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "InboxView",
            targets: ["InboxView"]),
        .library(
            name: "WebPage",
            targets: ["WebPage"]),
    ],
    dependencies: [
        .package(name: "Domain", path: "../Domain"),
        .package(name: "Styleguide", path: "../Styleguide"),
        .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.7.2"),
        .package(url: "https://github.com/hyponet/WebArchiver", branch: "master"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "InboxView",
            dependencies: [
                .product(name: "Entities", package: "Domain"),
                .product(name: "AppState", package: "Domain"),
                .product(name: "UseCaseProtocol", package: "Domain"),
                .product(name: "DomainTestHelpers", package: "Domain"),
                "WebPage",
            ]
        ),
        .target(
            name: "WebPage",
            dependencies: [
                .product(name: "WebArchiver", package: "WebArchiver"),
                .product(name: "SwiftSoup", package: "SwiftSoup"),
            ]
        ),
        .testTarget(
            name: "InboxTests",
            dependencies: []),
    ]
)
