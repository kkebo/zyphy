// swift-tools-version: 5.9

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "zyphy",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(name: "Tokenizer", targets: ["Tokenizer"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0"),
        .package(url: "https://github.com/apple/swift-testing", branch: "main"),
    ],
    targets: [
        .target(
            name: "Tokenizer",
            dependencies: [
                "TokenizerMacros",
                .product(name: "Testing", package: "swift-testing"),
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-warn-long-function-bodies=100"], .when(configuration: .debug)),
                .unsafeFlags(["-Xfrontend", "-warn-long-expression-type-checking=100"], .when(configuration: .debug)),
                .unsafeFlags(["-swift-version", "6"]),
                .enableExperimentalFeature("CodeItemMacros"),
            ]
        ),
        .macro(
            name: "TokenizerMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-warn-long-function-bodies=100"], .when(configuration: .debug)),
                .unsafeFlags(["-Xfrontend", "-warn-long-expression-type-checking=100"], .when(configuration: .debug)),
                .unsafeFlags(["-swift-version", "6"]),
            ]
        ),
        .testTarget(
            name: "TokenizerTests",
            dependencies: [
                "TokenizerMacros",
                "Tokenizer",
                .product(name: "Testing", package: "swift-testing"),
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-warn-long-function-bodies=100"], .when(configuration: .debug)),
                .unsafeFlags(["-Xfrontend", "-warn-long-expression-type-checking=100"], .when(configuration: .debug)),
                .unsafeFlags(["-swift-version", "6"]),
            ]
        ),
    ]
)
