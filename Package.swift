// swift-tools-version: 5.9

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Browser",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(name: "Tokenizer", targets: ["Tokenizer"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0-swift-DEVELOPMENT-SNAPSHOT-2023-09-05-a"),
    ],
    targets: [
        .target(
            name: "Tokenizer",
            dependencies: [
                "TokenizerMacros"
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-warn-long-function-bodies=100"], .when(configuration: .debug)),
                .unsafeFlags(["-Xfrontend", "-warn-long-expression-type-checking=100"], .when(configuration: .debug)),
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"]),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("ImplicitOpenExistentials"),
                .enableExperimentalFeature("CodeItemMacros"),
            ]
        ),
        .macro(
            name: "TokenizerMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "TokenizerTests",
            dependencies: [
                "TokenizerMacros",
                "Tokenizer",
            ]
        ),
    ]
)
