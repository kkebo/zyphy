// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [.macOS(.v13), .iOS(.v16)],
    dependencies: [
        .package(name: "zyphy", path: ".."),
        .package(url: "https://github.com/ordo-one/package-benchmark", from: "1.29.2"),
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
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)),
                .enableUpcomingFeature("InternalImportsByDefault"),
                .enableUpcomingFeature("MemberImportVisibility"),
            ],
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
