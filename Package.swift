// swift-tools-version: 6.2

import CompilerPluginSupport
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .treatAllWarnings(as: .error),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
    name: "zyphy",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
        .macCatalyst(.v13),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "Tokenizer", targets: ["Tokenizer"]),
        .library(name: "TreeBuilder", targets: ["TreeBuilder"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0"..<"603.0.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "Tokenizer",
            dependencies: [
                "TokenizerMacros",
                "HTMLEntities",
                .product(name: "DequeModule", package: "swift-collections"),
            ],
            swiftSettings: swiftSettings + [
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)),
                .enableExperimentalFeature("CodeItemMacros"),
            ],
        ),
        .target(
            name: "TreeBuilder",
            dependencies: [
                "Tokenizer"
            ],
            swiftSettings: swiftSettings + [
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ],
        ),
        .macro(
            name: "TokenizerMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            swiftSettings: swiftSettings,
        ),
        .target(
            name: "HTMLEntities",
            dependencies: [
                "Str"
            ],
            swiftSettings: swiftSettings,
        ),
        .target(
            name: "Str",
            swiftSettings: swiftSettings,
        ),
        .testTarget(
            name: "TokenizerTests",
            dependencies: [
                "TokenizerMacros",
                "Tokenizer",
            ],
            exclude: [
                "Resources/html5lib-tests/encoding",
                "Resources/html5lib-tests/lint_lib",
                "Resources/html5lib-tests/serializer",
                "Resources/html5lib-tests/tokenizer/README.md",
                "Resources/html5lib-tests/tokenizer/unicodeCharsProblematic.test",
                "Resources/html5lib-tests/tokenizer/xmlViolation.test",
                "Resources/html5lib-tests/tree-construction",
                "Resources/html5lib-tests/AUTHORS.rst",
                "Resources/html5lib-tests/LICENSE",
                "Resources/html5lib-tests/lint",
                "Resources/html5lib-tests/pyproject.toml",
            ],
            resources: [
                .process("Resources/html5lib-tests/tokenizer/test1.test"),
                .process("Resources/html5lib-tests/tokenizer/test2.test"),
                .process("Resources/html5lib-tests/tokenizer/test3.test"),
                .process("Resources/html5lib-tests/tokenizer/test4.test"),
                .process("Resources/html5lib-tests/tokenizer/unicodeChars.test"),
                .process("Resources/html5lib-tests/tokenizer/entities.test"),
                .process("Resources/html5lib-tests/tokenizer/namedEntities.test"),
                .process("Resources/html5lib-tests/tokenizer/numericEntities.test"),
                .process("Resources/html5lib-tests/tokenizer/pendingSpecChanges.test"),
                .process("Resources/html5lib-tests/tokenizer/contentModelFlags.test"),
                .process("Resources/html5lib-tests/tokenizer/escapeFlag.test"),
                .process("Resources/html5lib-tests/tokenizer/domjs.test"),
            ],
            swiftSettings: swiftSettings,
        ),
        .testTarget(
            name: "HTMLEntitiesTests",
            dependencies: [
                "HTMLEntities"
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: swiftSettings,
        ),
        .testTarget(
            name: "TreeBuilderTests",
            dependencies: [
                "TreeBuilder"
            ],
            swiftSettings: swiftSettings,
        ),
    ],
)
