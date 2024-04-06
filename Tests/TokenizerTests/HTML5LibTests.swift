private import DequeModule
private import Foundation
import Testing
private import Tokenizer

private struct TestSink {
    var tokens = [Token]()
    var errors = [ParseError]()
    var pendingChars = ""

    consuming func finalize() -> ([Token], [ParseError]) {
        self.processChars()
        return (self.tokens, self.errors)
    }

    private mutating func processChars() {
        self.tokens.append(contentsOf: self.pendingChars.map(Token.char))
        self.pendingChars.removeAll()
    }
}

extension TestSink: TokenSink {
    mutating func process(_ token: consuming Token) {
        switch token {
        case .error(let error): self.errors.append(error)
        case .char(let c): self.pendingChars.append(c)
        case let token:
            self.processChars()
            self.tokens.append(token)
        }
    }
}

// swift-format-ignore: NeverUseForceTry, NeverForceUnwrap
private let testCases = try! [
    Bundle.module.url(forResource: "test1", withExtension: "test")!,
    Bundle.module.url(forResource: "test2", withExtension: "test")!,
    Bundle.module.url(forResource: "test3", withExtension: "test")!,
    Bundle.module.url(forResource: "test4", withExtension: "test")!,
    Bundle.module.url(forResource: "unicodeChars", withExtension: "test")!,
    Bundle.module.url(forResource: "entities", withExtension: "test")!,
    Bundle.module.url(forResource: "namedEntities", withExtension: "test")!,
    Bundle.module.url(forResource: "numericEntities", withExtension: "test")!,
    Bundle.module.url(forResource: "pendingSpecChanges", withExtension: "test")!,
    // Bundle.module.url(forResource: "contentModelFlags", withExtension: "test")!,
    // Bundle.module.url(forResource: "escapeFlag", withExtension: "test")!,
    // Bundle.module.url(forResource: "domjs", withExtension: "test")!,
]
.flatMap { try parseTestCases(from: Data(contentsOf: $0)) }

@Test("html5lib-tests", arguments: testCases)
func html5libTests(_ testCase: TestCase) throws {
    var tokenizer = Tokenizer(sink: TestSink())
    tokenizer.state = testCase.initialState
    var input = Deque(testCase.input)
    tokenizer.tokenize(&input)

    let (tokens, errors) = tokenizer.sink.finalize()
    #expect(tokens == testCase.tokens)
    #expect(errors.count == testCase.errors.count)  // TODO: Make it stricter
}
