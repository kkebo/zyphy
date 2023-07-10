# Browser

This is a web browser written in Swift, and is partially inspired by Servo's [html5ever](https://github.com/servo/html5ever). **This project is in very early stage.**

## Building

### Linux

TODO (The main blocker is the lack of macros support in Linux.)

### macOS

Install Xcode 15 or later, and run the following command to build the source code.

```shell
swift build
```

## Testing

```shell
swift test
```

## Benchmarking

```shell
swift package benchmark
```

For more details, plaese see https://github.com/ordo-one/package-benchmark.
