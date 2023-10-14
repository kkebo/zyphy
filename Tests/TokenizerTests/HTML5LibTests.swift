import FoundationEssentials
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

// swift-format-ignore: NeverUseForceTry
@Test("html5lib-tests", arguments: try! parseTestCases(from: Data(PackageResources.test1_test)))
public func html5libTests(_ testCase: TestCase) throws {
    // TODO: Do not ignore any test cases
    switch testCase.description {
    case "Simple comment": return
    case "Comment, Central dash no space": return
    case "Comment, two central dashes": return
    case "Comment, central less-than bang": return
    case "Unfinished comment": return
    case "Unfinished comment after start of nested comment": return
    case "Start of a comment": return
    case "Short comment": return
    case "Short comment two": return
    case "Short comment three": return
    case "< in comment": return
    case "<< in comment": return
    case "<! in comment": return
    case "<!- in comment": return
    case "Nested comment": return
    case "Nested comment with extra <": return
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
