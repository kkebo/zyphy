public struct Tokenizer<Sink: TokenSink> {
    var sink: Sink
    var state: State
    var charRefTokenzier: Optional<CharRefTokenizer>

    public init(sink: Sink) {
        self.sink = sink
        self.state = .data
        self.charRefTokenzier = .none
    }

    // TODO: Consider input type
    public mutating func tokenize(_ input: inout String.Iterator) {
        while true {
            self.charRefTokenzier?.tokenize(&input)

            guard let c = input.next() else { break }
            self.consume(c)
        }

        self.consumeEOF()
    }

    @inline(__always)
    private mutating func consume(_ c: Character) {
        switch self.state {
        case .data:
            switch c {
            case "&": self.consumeCharRef()
            case "<": self.go(to: .tagOpen)
            case "\0": self.emit(.error(.unexpectedNullCharacter), "\0")
            case let c: self.emit(c)
            }
        case _:
            preconditionFailure("Not implemented")
        }
    }

    @inline(__always)
    private mutating func consumeEOF() {
        switch self.state {
        case .data:
            self.emit(.eof)
        case _:
            preconditionFailure("Not implemented")
        }
    }

    @inline(__always)
    private mutating func go(to state: State) {
        self.state = state
    }

    @inline(__always)
    private mutating func consumeCharRef() {
        self.charRefTokenzier = .init()
    }

    @inline(__always)
    private mutating func emit(_ tokens: Token...) {
        for token in tokens {
            self.sink.process(token)
        }
    }

    @inline(__always)
    private mutating func emit(_ c: Character) {
        self.sink.process(.char(c))
    }
}
