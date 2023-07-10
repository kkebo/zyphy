// swift-tools-version: 5.9

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Browser",
    platforms: [.macOS(.v13), .iOS(.v16)],
    dependencies: [
        .package(url: "https://github.com/ordo-one/package-benchmark", "1.6.5"..<"1.7.0"),
        .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0-swift-DEVELOPMENT-SNAPSHOT-2023-06-17-a"),
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
        .executableTarget(
            name: "MyBenchmark",
            dependencies: [
                .product(name: "Benchmark", package: "package-benchmark"),
                "Tokenizer",
            ],
            path: "Benchmarks/MyBenchmark",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
            ]
        ),
        .testTarget(
            name: "TokenizerTests",
            dependencies: [
                "Tokenizer"
            ]
        ),
    ]
)
