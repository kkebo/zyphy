# Zyphy

Zyphy is (or will be) a fast web browser engine written in Swift, and is partially inspired by Servo's [html5ever](https://github.com/servo/html5ever). **This project is in a very early stage.**

## Prerequisites

- Linux
  - Swift nightly toolchain (available from [development snapshots](https://www.swift.org/download/) or [nightly Docker images](https://hub.docker.com/r/swiftlang/swift))
- macOS
  - Xcode 15 or later
  - Swift nightly toolchain (available from [development snapshots](https://www.swift.org/download/))

## Building

```shell
swift build
```

## Testing

```shell
swift test
```

## Benchmarking

You need:

- jemalloc

```shell
swift package --package-path Benchmarks benchmark
```

For more details, please see https://github.com/ordo-one/package-benchmark.
