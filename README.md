# Browser

This is a web browser engine written in Swift, and is partially inspired by Servo's [html5ever](https://github.com/servo/html5ever). **This project is in a very early stage.**

## Building

### Linux

TODO ([The main blocker is the lack of macros support in Linux.](https://forums.swift.org/t/65427))

### macOS

You need:

- Xcode 15 or later

And then, run the following command to build the source code.

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
