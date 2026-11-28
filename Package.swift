// swift-tools-version: 6.5

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "zyphy",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .watchOS(.v26),
        .tvOS(.v26),
        .macCatalyst(.v26),
        .visionOS(.v26),
    ],
    defaultSwiftSettings: [
        .treatAllWarnings(as: .error),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("ImmutableWeakCaptures"),
        .strictMemorySafety(),
    ],
    products: [
        .library(name: "Tokenizer", targets: ["Tokenizer"]),
        .library(name: "TreeBuilder", targets: ["TreeBuilder"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0"..<"606.0.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "Tokenizer",
            dependencies: [
                .target(name: "TokenizerMacros"),
                .target(name: "HTMLEntities"),
                .product(name: "DequeModule", package: "swift-collections"),
            ],
            swiftSettings: [
                .defaults,
                .treatWarning("EmbeddedRestrictions", as: .error),
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)),
                .enableExperimentalFeature("CodeItemMacros"),
            ],
        ),
        .target(
            name: "TreeBuilder",
            dependencies: [
                .target(name: "Tokenizer")
            ],
            swiftSettings: [
                .defaults,
                .treatWarning("EmbeddedRestrictions", as: .error),
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)),
            ],
        ),
        .macro(
            name: "TokenizerMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
        ),
        .target(
            name: "HTMLEntities",
            dependencies: [
                .target(name: "Str")
            ],
            swiftSettings: [
                .defaults,
                .treatWarning("EmbeddedRestrictions", as: .error),
            ],
        ),
        .target(
            name: "Str",
            swiftSettings: [
                .defaults,
                .treatWarning("EmbeddedRestrictions", as: .error),
            ],
        ),
        .testTarget(
            name: "TokenizerTests",
            dependencies: [
                .target(name: "TokenizerMacros"),
                .target(name: "Tokenizer"),
            ],
            exclude: [
                "Resources/html5lib-tests/encoding",
                "Resources/html5lib-tests/lint_lib",
                "Resources/html5lib-tests/serializer",
                "Resources/html5lib-tests/tokenizer/README.md",
                "Resources/html5lib-tests/tokenizer/unicodeCharsProblematic.test",
                "Resources/html5lib-tests/tokenizer/xmlViolation.test",
                "Resources/html5lib-tests/AUTHORS.rst",
                "Resources/html5lib-tests/LICENSE",
                "Resources/html5lib-tests/lint",
                "Resources/html5lib-tests/pyproject.toml",
                "Resources/html5lib-tests/README.md",
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
        ),
        .testTarget(
            name: "HTMLEntitiesTests",
            dependencies: [
                .target(name: "HTMLEntities")
            ],
            resources: [
                .process("Resources")
            ],
        ),
        .testTarget(
            name: "TreeBuilderTests",
            dependencies: [
                .target(name: "TreeBuilder")
            ],
        ),
    ],
)
