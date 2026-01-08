// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "basenana",
    platforms: [.macOS(.v14)],
    products: [
        // Core Layers
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Data", targets: ["Data"]),
        .library(name: "Feature", targets: ["Feature"]),
        .library(name: "Styleguide", targets: ["Styleguide"]),
        // App
        .library(name: "BasenanaApp", targets: ["BasenanaApp"]),
        .executable(name: "basenana", targets: ["basenana"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nmdias/FeedKit", from: "9.1.2"),
        .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.7.2"),
        .package(url: "https://github.com/cezheng/Fuzi", from: "3.1.2"),
        .package(url: "https://github.com/ciaranrobrien/SwiftUIMasonry", branch: "main"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "2.0.0"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.9.0"),
        .package(url: "https://github.com/hmlongco/Factory", from: "2.4.0"),
    ],
    targets: [
        // Domain Layer
        .target(
            name: "Domain",
            path: "Sources/Domain"
        ),

        // Data Layer
        .target(
            name: "Data",
            dependencies: ["Domain"],
            path: "Sources/Data"
        ),

        // Feature Layer (Entry + Document + Workflow)
        .target(
            name: "Feature",
            dependencies: [
                "Domain",
                "Data",
                "Styleguide",
                .product(name: "FeedKit", package: "FeedKit"),
                .product(name: "SwiftUIMasonry", package: "SwiftUIMasonry"),
                .product(name: "SwiftSoup", package: "SwiftSoup"),
                .product(name: "Fuzi", package: "Fuzi"),
            ],
            path: "Sources/Feature",
            resources: [
                .process("Entry/WebPage/Readability/Readability.js"),
                .process("Entry/WebPage/Readability/readability_images.js"),
                .process("Entry/WebPage/Readability/readability_initialization.js"),
            ]
        ),
        .testTarget(name: "FeatureTests", dependencies: ["Feature"], path: "Tests/FeatureTests"),

        // Styleguide
        .target(
            name: "Styleguide",
            path: "Sources/Styleguide/Styleguide"
        ),
        .testTarget(name: "StyleguideTests", dependencies: ["Styleguide"], path: "Tests/StyleguideTests"),

        // Domain Tests
        .testTarget(name: "DomainTests", dependencies: ["Domain"], path: "Tests/DomainTests"),

        // Data Tests
        .testTarget(name: "DataTests", dependencies: ["Data"], path: "Tests/DataTests"),

        // App Library
        .target(
            name: "BasenanaApp",
            dependencies: [
                "Domain",
                "Data",
                "Feature",
                "Styleguide",
                .product(name: "SwiftyBeaver", package: "SwiftyBeaver"),
                .product(name: "Swinject", package: "Swinject"),
                .product(name: "Factory", package: "Factory"),
            ],
            path: "basenana",
            exclude: ["Info.plist", "main.swift", "basenana-exec"],
            resources: [
                .process("Assets.xcassets"),
            ]
        ),

        // App Executable
        .executableTarget(
            name: "basenana",
            dependencies: ["BasenanaApp"],
            path: "basenana-exec",
            sources: ["main.swift"]
        ),
    ]
)
