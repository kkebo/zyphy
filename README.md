# Zyphy

Zyphy is (or will be) a fast web browser engine written in Swift.

> [!IMPORTANT]
> This package is under development.

## Package Contents

- ✅ Ready to Use
  - (Nothing)
- 🚧 Work in Progress
  - `Tokenizer` - An HTML tokenizer ([specs](https://html.spec.whatwg.org/multipage/parsing.html#tokenization))
  - `TreeConstructor` - An HTML tree constructor ([specs](https://html.spec.whatwg.org/multipage/parsing.html#tree-construction))
- 🥚 To Do
  - `Zyphy` - The main module

## Prerequisites

- Swift 6.1 development snapshot (because Zyphy is using experimental [code item macros](https://github.com/swiftlang/swift-evolution/blob/main/visions/macros.md#macro-roles))

You can easily install the toolchain using [Swiftly](https://www.swift.org/install/).

```shell
swiftly install 6.1-snapshot
swiftly use 6.1-snapshot
```

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
BENCHMARK_DISABLE_JEMALLOC=true swift package --package-path Benchmarks benchmark
```

For more details, please see https://github.com/ordo-one/package-benchmark.

The benchmark data are from [html5ever](https://github.com/servo/html5ever/tree/1ae2de3a1796a9b52a804a02039c6c1499e2f461/html5ever/data/bench), which is dual-licensed under [the MIT license](https://github.com/servo/html5ever/blob/1ae2de3a1796a9b52a804a02039c6c1499e2f461/LICENSE-MIT) and [the Apache 2.0 license](https://github.com/servo/html5ever/blob/1ae2de3a1796a9b52a804a02039c6c1499e2f461/LICENSE-APACHE).
