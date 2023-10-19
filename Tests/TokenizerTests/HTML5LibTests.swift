import Foundation
public import Testing

@testable import Tokenizer

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
]
.flatMap { try parseTestCases(from: Data(contentsOf: $0)) }

@Test("html5lib-tests", arguments: testCases)
public func html5libTests(_ testCase: TestCase) throws {
    // TODO: Do not ignore any test cases
    switch testCase.title {
    case "<! in script data": return
    case "<!- in script data": return
    case "Escaped script data": return
    case "< in script HTML comment": return
    case "</ in script HTML comment": return
    case "Start tag in script HTML comment": return
    case "End tag in script HTML comment": return
    case "- in script HTML comment double escaped": return
    case "-- in script HTML comment double escaped": return
    case "--- in script HTML comment double escaped": return
    case "- spaced in script HTML comment double escaped": return
    case "-- spaced in script HTML comment double escaped": return
    case "Ampersand EOF": return
    case "Ampersand ampersand EOF": return
    case "Ampersand space EOF": return
    case "Unfinished entity": return
    case "Ampersand, number sign": return
    case "Unfinished numeric entity": return
    case "Entity with trailing semicolon (1)": return
    case "Entity with trailing semicolon (2)": return
    case "Entity without trailing semicolon (1)": return
    case "Entity without trailing semicolon (2)": return
    case "Partial entity match at end of file": return
    case "Non-ASCII character reference name": return
    case "ASCII decimal entity": return
    case "ASCII hexadecimal entity": return
    case "Hexadecimal entity in attribute": return
    case "Entity in attribute without semicolon ending in x": return
    case "Entity in attribute without semicolon ending in 1": return
    case "Entity in attribute without semicolon ending in i": return
    case "Entity in attribute without semicolon": return
    case "Unquoted attribute ending in ampersand": return
    case "Unquoted attribute at end of tag with final character of &, with tag followed by characters": return
    case "Numeric entity representing the NUL character": return
    case "Hexadecimal entity representing the NUL character": return
    case "Numeric entity representing a codepoint after 1114111 (U+10FFFF)": return
    case "Hexadecimal entity representing a codepoint after 1114111 (U+10FFFF)": return
    case "Hexadecimal entity pair representing a surrogate pair": return
    case "Hexadecimal entity with mixed uppercase and lowercase": return
    case "Entity without a name": return
    case "Unescaped ampersand in attribute value": return
    case "Entity + newline": return
    case "Start tag with no attributes but space before the greater-than sign": return
    case "&": return
    case "<!-- &": return
    case "<!-- -&": return
    case "<!--&": return
    case "<!---&": return
    case "<!----!CRLF>": return
    case "<!----&": return
    case "<&": return
    case "<a a=\"&\">": return
    case "<a a=&>": return
    case "<a a='&'>": return
    case "<a a=a&>": return
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
