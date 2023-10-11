# Zyphy

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

- Swift nightly toolchain

On Linux, you can easily install the toolchain using [swiftly](https://swift-server.github.io/swiftly/).

```shell
curl -L https://swift-server.github.io/swiftly/swiftly-install.sh | bash
swiftly install main-snapshot
```

## Building

```shell
swift build
```

## Testing

```shell
swift test
```

## Benchmarking

You must install jemalloc beforehand. (`pacman -S jemalloc`, `apt install libjemalloc-dev`, or something)

```shell
swift package --package-path Benchmarks benchmark
```

For more details, please see https://github.com/ordo-one/package-benchmark.
