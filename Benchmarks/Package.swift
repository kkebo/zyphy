// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [.macOS(.v26), .iOS(.v26)],
    dependencies: [
        .package(name: "zyphy", path: ".."),
        .package(url: "https://github.com/ordo-one/benchmark", from: "1.35.0"),
    ],
    targets: [
        .executableTarget(
            name: "MyBenchmark",
            dependencies: [
                .product(name: "Benchmark", package: "benchmark"),
                .product(name: "Tokenizer", package: "zyphy"),
            ],
            path: "Benchmarks/MyBenchmark",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .treatAllWarnings(as: .error),
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault"),
                .enableUpcomingFeature("MemberImportVisibility"),
                .strictMemorySafety(),
            ],
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "benchmark")
            ],
        )
    ],
)
