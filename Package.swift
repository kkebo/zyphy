// swift-tools-version: 5.10

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "zyphy",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(name: "Tokenizer", targets: ["Tokenizer"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0"),
        .package(url: "https://github.com/apple/swift-testing", branch: "main"),
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
                .unsafeFlags(["-swift-version", "6"]),
                .enableExperimentalFeature("CodeItemMacros"),
            ]
        ),
        .macro(
            name: "TokenizerMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-warn-long-function-bodies=100"], .when(configuration: .debug)),
                .unsafeFlags(["-Xfrontend", "-warn-long-expression-type-checking=100"], .when(configuration: .debug)),
                .unsafeFlags(["-swift-version", "6"]),
            ]
        ),
        .testTarget(
            name: "TokenizerTests",
            dependencies: [
                "TokenizerMacros",
                "Tokenizer",
                .product(name: "Testing", package: "swift-testing"),
            ],
            exclude: [
                "Resources/html5lib-tests/encoding",
                "Resources/html5lib-tests/lint_lib",
                "Resources/html5lib-tests/serializer",
                "Resources/html5lib-tests/tokenizer/README.md",
                "Resources/html5lib-tests/tokenizer/contentModelFlags.test",
                "Resources/html5lib-tests/tokenizer/domjs.test",
                "Resources/html5lib-tests/tokenizer/escapeFlag.test",
                "Resources/html5lib-tests/tokenizer/entities.test",
                "Resources/html5lib-tests/tokenizer/namedEntities.test",
                "Resources/html5lib-tests/tokenizer/numericEntities.test",
                "Resources/html5lib-tests/tokenizer/pendingSpecChanges.test",
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
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-warn-long-function-bodies=100"], .when(configuration: .debug)),
                .unsafeFlags(["-Xfrontend", "-warn-long-expression-type-checking=100"], .when(configuration: .debug)),
                .unsafeFlags(["-swift-version", "6"]),
            ]
        ),
    ]
)
