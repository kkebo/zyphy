private import Foundation
import Testing
private import Tokenizer

private struct TestSink: ~Copyable {
    var tokens = [Token]()
    var errors = [ParseError]()
}

extension TestSink: TokenSink {
    mutating func process(_ token: consuming Token) {
        switch token {
        case .error(let error): self.errors.append(error)
        case .chars(let s): for c in s { self.tokens.append(.char(c)) }
        case let token: self.tokens.append(token)
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
func html5libTests(_ testCase: TestCase) {
    var tokenizer = Tokenizer(sink: TestSink(), emitsAllErrors: true)
    tokenizer.state = testCase.initialState
    var input = BufferQueue(ArraySlice(testCase.input.unicodeScalars))
    tokenizer.tokenize(&input)

    #expect(tokenizer.sink.tokens == testCase.tokens)
    #expect(tokenizer.sink.errors.count == testCase.errors.count)  // TODO: Make it stricter
}
