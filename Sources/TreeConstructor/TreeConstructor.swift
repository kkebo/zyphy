import Tokenizer

public struct TreeConstructor {
    private var mode: InsertionMode

    public init() {
        self.mode = .initial
    }
}

extension TreeConstructor: TokenSink {
    mutating func process(_ token: consuming Token) {
        // TODO: Implement here
    }
}
