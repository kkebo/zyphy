// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [.macOS(.v13), .iOS(.v16)],
    dependencies: [
        .package(name: "Browser", path: ".."),
        .package(url: "https://github.com/ordo-one/package-benchmark", from: "1.11.2"),
    ],
    targets: [
        .executableTarget(
            name: "MyBenchmark",
            dependencies: [
                .product(name: "Benchmark", package: "package-benchmark"),
                .product(name: "Tokenizer", package: "Browser"),
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
