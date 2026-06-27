# Zyphy

Zyphy is (or will be) a fast web browser engine written in Swift.

> [!IMPORTANT]
> This package is under development.

## Package Contents

- 🚧 `Tokenizer` - An HTML tokenizer that takes an HTML string and produces HTML tokens. ([specs](https://html.spec.whatwg.org/multipage/parsing.html#tokenization))
- 🚧 `TreeBuilder` - An HTML tree constructor that constructs a DOM tree from HTML tokens. ([specs](https://html.spec.whatwg.org/multipage/parsing.html#tree-construction))
- 🥚 `Layout` - A layout engine that translates a DOM tree into a layout tree.
- 🥚 `Paint` - A rendering abstraction layer that translates a layout tree into a platform-independent display list of drawing commands.
- 🥚 `SVGBackend` - An SVG backend of the renderer.
- 🥚 `SVGExample` - An example application using `SVGBackend`.

Icons:

- ✅ Ready to Use
- 🚧 Work in Progress
- 🥚 To Do

## Prerequisites

- [Swiftly](https://www.swift.org/install/)
- Swift toolchain: Just run `swiftly install` after installing Swiftly
  - We can't use a stable toolchain yet because Zyphy is using experimental [code item macros](https://github.com/swiftlang/swift-evolution/blob/main/visions/macros.md#macro-roles).

## Building

```shell
swift build
```

## Testing

```shell
git submodule update --init --recursive
swift test --disable-xctest
```

## Benchmarking

```shell
swift package --package-path Benchmarks --build-system native benchmark
```

For more details, please see https://github.com/ordo-one/package-benchmark.

The benchmark data are from [html5ever](https://github.com/servo/html5ever/tree/1ae2de3a1796a9b52a804a02039c6c1499e2f461/html5ever/data/bench), which is dual-licensed under [the MIT license](https://github.com/servo/html5ever/blob/1ae2de3a1796a9b52a804a02039c6c1499e2f461/LICENSE-MIT) and [the Apache 2.0 license](https://github.com/servo/html5ever/blob/1ae2de3a1796a9b52a804a02039c6c1499e2f461/LICENSE-APACHE).
