private import Benchmark
private import Foundation
private import Tokenizer

@_optimize(none)
func blackHole<T: ~Copyable>(_: consuming T) {}

private struct TestSink: ~Copyable {}

extension TestSink: TokenSink {
    func process(_ token: consuming Token) {
        blackHole(token)
    }
}

private func runBench(_ name: String, configuration conf: Benchmark.Configuration) {
    // swift-format-ignore: NeverUseForceTry, NeverForceUnwrap
    let html = try! String(
        contentsOf: Bundle.module.url(forResource: name, withExtension: "html")!,
        encoding: .utf8,
    )
    .unicodeScalars
    let input = ArraySlice(consume html)
    Benchmark(name, configuration: conf) { benchmark in
        for _ in benchmark.scaledIterations {
            var tokenizer = Tokenizer(sink: TestSink())
            var input = BufferQueue(input)
            tokenizer.tokenize(&input)
        }
    }
}

let benchmarks: @Sendable () -> Void = {
    let conf = Benchmark.Configuration(
        metrics: [.wallClock],
        warmupIterations: 10,
        scalingFactor: .kilo,
        maxDuration: .seconds(60),
        maxIterations: 100,
    )

    runBench("lipsum", configuration: conf)
    runBench("lipsum-zh", configuration: conf)
    runBench("medium-fragment", configuration: conf)
    runBench("small-fragment", configuration: conf)
    runBench("tiny-fragment", configuration: conf)
    runBench("strong", configuration: conf)
}
