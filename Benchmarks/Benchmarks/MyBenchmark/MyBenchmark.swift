private import Benchmark
private import DequeModule
private import Tokenizer

private struct TestSink {}

extension TestSink: TokenSink {
    func process(_: consuming Token) {}
}

@MainActor
let benchmarks = {
    let html = #"""
        <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="UTF-8" />
        <title>title</title>
        </head>
        <body>
        hi
        </body>
        </html>
        """#

    Benchmark(
        "TokenizerBenchmark",
        configuration: .init(
            metrics: .microbenchmark,
            scalingFactor: .kilo
        )
    ) { benchmark in
        for _ in benchmark.scaledIterations {
            var tokenizer = Tokenizer(sink: TestSink())
            var input = Deque(html)
            tokenizer.tokenize(&input)
        }
    }
}
