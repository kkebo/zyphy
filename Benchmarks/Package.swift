// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [.macOS(.v13), .iOS(.v16)],
    dependencies: [
        .package(name: "zyphy", path: ".."),
        .package(url: "https://github.com/ordo-one/package-benchmark", from: "1.15.0"),
        // dev
        .package(url: "https://github.com/apple/swift-format", from: "509.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "MyBenchmark",
            dependencies: [
                .product(name: "Benchmark", package: "package-benchmark"),
                .product(name: "Tokenizer", package: "zyphy"),
            ],
            path: "Benchmarks/MyBenchmark",
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-warn-long-function-bodies=100"], .when(configuration: .debug)),
                .unsafeFlags(["-Xfrontend", "-warn-long-expression-type-checking=100"], .when(configuration: .debug)),
                .unsafeFlags(["-swift-version", "6"]),
            ],
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
            ]
        )
    ]
)
