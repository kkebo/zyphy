# Zyphy

[![codecov](https://codecov.io/gh/kkk669/zyphy/graph/badge.svg?token=AGD0MP5FCP)](https://codecov.io/gh/kkk669/zyphy)

Zyphy is (or will be) a fast web browser engine written in Swift.

> [!IMPORTANT]
> This package is under development.

## Package Contents

- ✅ Ready to Use
  - (Nothing)
- 🚧 Work in Progress
  - `Tokenizer` - An HTML tokenizer ([specs](https://html.spec.whatwg.org/multipage/parsing.html#tokenization))
- 🥚 To Do
  - `Zyphy` - The main module
  - `TreeConstructor` - An HTML tree constructor ([specs](https://html.spec.whatwg.org/multipage/parsing.html#tree-construction))

## Prerequisites

- Swift trunk development (main) toolchain (because Zyphy is using experimental [code item macros](https://github.com/apple/swift-evolution/blob/main/visions/macros.md#macro-roles))

On Linux, you can easily install the toolchain using [swiftly](https://swift-server.github.io/swiftly/).

```shell
curl -L https://swift-server.github.io/swiftly/swiftly-install.sh | bash
swiftly install main-snapshot
```

## Building

```shell
swift build
```

> [!WARNING]
> If you used swiftly to install Swift, you have to use `swift-legacy-driver` instead of `swift` until https://github.com/swift-server/swiftly/issues/92 is resolved.
>
> ```shell
> swift-legacy-driver build
> ```

## Testing

```shell
git submodule update --init --recursive
swift test --disable-xctest
```

> [!WARNING]
> If you used swiftly to install Swift, you have to use `swift-legacy-driver` instead of `swift` until https://github.com/swift-server/swiftly/issues/92 is resolved.
>
> ```shell
> git submodule update --init --recursive
> swift-legacy-driver test --disable-xctest
> ```

## Benchmarking

```shell
BENCHMARK_DISABLE_JEMALLOC=true swift package --package-path Benchmarks benchmark
```

> [!WARNING]
> If you used swiftly to install Swift, you have to use `swift-legacy-driver` instead of `swift` until https://github.com/swift-server/swiftly/issues/92 is resolved.
>
> ```shell
> BENCHMARK_DISABLE_JEMALLOC=true swift-legacy-driver package --package-path Benchmarks benchmark
> ```

For more details, please see https://github.com/ordo-one/package-benchmark.
