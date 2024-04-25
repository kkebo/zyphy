// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [.macOS(.v13), .iOS(.v16)],
    dependencies: [
        .package(name: "zyphy", path: ".."),
        .package(url: "https://github.com/ordo-one/package-benchmark", from: "1.23.1"),
    ],
    targets: [
        .executableTarget(
            name: "MyBenchmark",
            dependencies: [
                .product(name: "Benchmark", package: "package-benchmark"),
                .product(name: "Tokenizer", package: "zyphy"),
            ],
            path: "Benchmarks/MyBenchmark",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-warn-long-function-bodies=100"], .when(configuration: .debug)),
                .unsafeFlags(["-Xfrontend", "-warn-long-expression-type-checking=100"], .when(configuration: .debug)),
                .enableUpcomingFeature("InternalImportsByDefault"),
            ],
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
            ]
        )
    ],
    swiftLanguageVersions: [.version("6")]
)
