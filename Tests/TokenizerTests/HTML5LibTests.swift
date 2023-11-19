import Foundation
public import Testing
import Tokenizer

private struct TestSink {
    var tokens = [Token]()
    var errors = [ParseError]()
}

extension TestSink: TokenSink {
    mutating func process(_ token: consuming Token) {
        switch consume token {
        case .error(let error): self.errors.append(consume error)
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
]
.flatMap { try parseTestCases(from: Data(contentsOf: $0)) }

@Test("html5lib-tests", arguments: testCases)
public func html5libTests(_ testCase: TestCase) throws {
    // TODO: Do not ignore any test cases
    switch testCase.title {
    // test1.test
    case "Entity with trailing semicolon (1)": return
    case "Entity with trailing semicolon (2)": return
    case "Entity without trailing semicolon (1)": return
    case "Entity without trailing semicolon (2)": return
    case "Entity in attribute without semicolon": return
    // test2.test
    case "Entity + newline": return
    // test4.test
    case "U+FDD1 in lookahead region": return
    case "U+1FFFF in lookahead region": return
    // unicodeChars.test
    case "Invalid Unicode character U+FDD0": return
    case "Invalid Unicode character U+FDD1": return
    case "Invalid Unicode character U+FDD2": return
    case "Invalid Unicode character U+FDD3": return
    case "Invalid Unicode character U+FDD4": return
    case "Invalid Unicode character U+FDD5": return
    case "Invalid Unicode character U+FDD6": return
    case "Invalid Unicode character U+FDD7": return
    case "Invalid Unicode character U+FDD8": return
    case "Invalid Unicode character U+FDD9": return
    case "Invalid Unicode character U+FDDA": return
    case "Invalid Unicode character U+FDDB": return
    case "Invalid Unicode character U+FDDC": return
    case "Invalid Unicode character U+FDDD": return
    case "Invalid Unicode character U+FDDE": return
    case "Invalid Unicode character U+FDDF": return
    case "Invalid Unicode character U+FDE0": return
    case "Invalid Unicode character U+FDE1": return
    case "Invalid Unicode character U+FDE2": return
    case "Invalid Unicode character U+FDE3": return
    case "Invalid Unicode character U+FDE4": return
    case "Invalid Unicode character U+FDE5": return
    case "Invalid Unicode character U+FDE6": return
    case "Invalid Unicode character U+FDE7": return
    case "Invalid Unicode character U+FDE8": return
    case "Invalid Unicode character U+FDE9": return
    case "Invalid Unicode character U+FDEA": return
    case "Invalid Unicode character U+FDEB": return
    case "Invalid Unicode character U+FDEC": return
    case "Invalid Unicode character U+FDED": return
    case "Invalid Unicode character U+FDEE": return
    case "Invalid Unicode character U+FDEF": return
    case "Invalid Unicode character U+FFFE": return
    case "Invalid Unicode character U+FFFF": return
    case "Invalid Unicode character U+1FFFE": return
    case "Invalid Unicode character U+1FFFF": return
    case "Invalid Unicode character U+2FFFE": return
    case "Invalid Unicode character U+2FFFF": return
    case "Invalid Unicode character U+3FFFE": return
    case "Invalid Unicode character U+3FFFF": return
    case "Invalid Unicode character U+4FFFE": return
    case "Invalid Unicode character U+4FFFF": return
    case "Invalid Unicode character U+5FFFE": return
    case "Invalid Unicode character U+5FFFF": return
    case "Invalid Unicode character U+6FFFE": return
    case "Invalid Unicode character U+6FFFF": return
    case "Invalid Unicode character U+7FFFE": return
    case "Invalid Unicode character U+7FFFF": return
    case "Invalid Unicode character U+8FFFE": return
    case "Invalid Unicode character U+8FFFF": return
    case "Invalid Unicode character U+9FFFE": return
    case "Invalid Unicode character U+9FFFF": return
    case "Invalid Unicode character U+AFFFE": return
    case "Invalid Unicode character U+AFFFF": return
    case "Invalid Unicode character U+BFFFE": return
    case "Invalid Unicode character U+BFFFF": return
    case "Invalid Unicode character U+CFFFE": return
    case "Invalid Unicode character U+CFFFF": return
    case "Invalid Unicode character U+DFFFE": return
    case "Invalid Unicode character U+DFFFF": return
    case "Invalid Unicode character U+EFFFE": return
    case "Invalid Unicode character U+EFFFF": return
    case "Invalid Unicode character U+FFFFE": return
    case "Invalid Unicode character U+FFFFF": return
    case "Invalid Unicode character U+10FFFE": return
    case "Invalid Unicode character U+10FFFF": return
    case _: break
    }

    var tokenizer = Tokenizer(sink: TestSink())
    tokenizer.state = testCase.initialState
    var iter = testCase.input.makeIterator()
    tokenizer.tokenize(&iter)

    let tokens = tokenizer.sink.tokens
    let errors = tokenizer.sink.errors
    #expect(tokens == testCase.tokens)
    #expect(errors.count == testCase.errors.count)  // TODO: Make it stricter
}
