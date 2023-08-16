// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [.macOS(.v13), .iOS(.v16)],
    dependencies: [
        .package(name: "Browser", path: ".."),
        .package(url: "https://github.com/ordo-one/package-benchmark", "1.8.1"..<"1.9.0"),
    ],
    targets: [
        .executableTarget(
            name: "MyBenchmark",
            dependencies: [
                .product(name: "Benchmark", package: "package-benchmark"),
                .product(name: "Tokenizer", package: "Browser"),
            ],
            path: "Benchmarks/MyBenchmark",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
            ]
        )
    ]
)
