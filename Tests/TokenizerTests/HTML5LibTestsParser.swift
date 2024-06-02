import Foundation
private import Str
import Tokenizer

struct TestFile: Decodable {
    var tests: [TestFileEntry]
}

struct TestFileEntry {
    var description: String
    var input: String
    var output: [ExpectedToken]
    var initialStates: [InitialState]
    var lastStartTag: Optional<String>
    var errors: [ExpectedError]

    consuming func into() throws -> [TestCase] {
        try self.initialStates.map { state in
            .init(
                title: self.description,
                input: self.input,
                tokens: try self.output.flatMap { try $0.into() } + [.eof],
                initialState: .init(state),
                errors: self.errors
            )
        }
    }
}

extension TestFileEntry: Decodable {
    enum CodingKeys: String, CodingKey {
        case description, input, output, initialStates, lastStartTag, errors
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try container.decode(String.self, forKey: .description)
        self.input = try container.decode(String.self, forKey: .input)
        self.output = try container.decode([ExpectedToken].self, forKey: .output)
        self.initialStates = try container.decodeIfPresent([InitialState].self, forKey: .initialStates) ?? [.data]
        self.lastStartTag = try container.decodeIfPresent(String.self, forKey: .lastStartTag)
        self.errors = try container.decodeIfPresent([ExpectedError].self, forKey: .errors) ?? []
    }
}

struct ExpectedToken {
    var fields: [ExpectedTokenField?]

    consuming func into() throws -> [Token] {
        let fields = self.fields
        switch fields[0] {
        case .str("DOCTYPE"):
            return switch (fields[1], fields[2], fields[3], fields[4]) {
            case (.str(let name), .str(let publicID), .str(let systemID), .bool(let correctness)):
                [.doctype(.init(name: name, publicID: publicID, systemID: systemID, forceQuirks: !correctness))]
            case (.str(let name), .str(let publicID), nil, .bool(let correctness)):
                [.doctype(.init(name: name, publicID: publicID, forceQuirks: !correctness))]
            case (.str(let name), nil, .str(let systemID), .bool(let correctness)):
                [.doctype(.init(name: name, systemID: systemID, forceQuirks: !correctness))]
            case (.str(let name), nil, nil, .bool(let correctness)):
                [.doctype(.init(name: name, forceQuirks: !correctness))]
            case (nil, nil, nil, .bool(let correctness)):
                [.doctype(.init(name: nil, forceQuirks: !correctness))]
            case _: throw TestParseError.invalidTokenFormat(fields)
            }
        case .str("StartTag"):
            switch fields.count {
            case 4:
                guard case (.str(let name), .dict(let attrs), .bool(true)) = (fields[1], fields[2], fields[3]) else {
                    throw TestParseError.invalidTokenFormat(fields)
                }
                return [.tag(.init(name: name, kind: .start, attrs: attrs, selfClosing: true))]
            case 3:
                guard case (.str(let name), .dict(let attrs)) = (fields[1], fields[2]) else {
                    throw TestParseError.invalidTokenFormat(fields)
                }
                return [.tag(.init(name: name, kind: .start, attrs: attrs))]
            case _: throw TestParseError.invalidTokenFormat(fields)
            }
        case .str("EndTag"):
            guard case .str(let name) = fields[1] else { throw TestParseError.invalidTokenFormat(fields) }
            return [.tag(.init(name: name, kind: .end))]
        case .str("Comment"):
            guard case .str(let data) = fields[1] else { throw TestParseError.invalidTokenFormat(fields) }
            return [.comment(Str(data.unicodeScalars))]
        case .str("Character"):
            guard case .str(let data) = fields[1] else { throw TestParseError.invalidTokenFormat(fields) }
            return data.unicodeScalars.map(Token.char)
        case let type: throw TestParseError.invalidTokenType(type)
        }
    }
}

extension ExpectedToken: Decodable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.fields = try container.decode([ExpectedTokenField?].self)
    }
}

extension Token {
}

enum ExpectedTokenField {
    case str(String)
    case bool(Bool)
    case dict([String: String])
}

extension ExpectedTokenField: Decodable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let s = try? container.decode(String.self) {
            self = .str(s)
        } else if let b = try? container.decode(Bool.self) {
            self = .bool(b)
        } else if let d = try? container.decode([String: String].self) {
            self = .dict(d)
        } else {
            preconditionFailure()
        }
    }
}

enum InitialState: String, Decodable {
    case data = "Data state"
    case plaintext = "PLAINTEXT state"
    case rcdata = "RCDATA state"
    case rawtext = "RAWTEXT state"
    case scriptData = "Script data state"
    case cdataSection = "CDATA section state"
}

extension State {
    init(_ state: consuming InitialState) {
        self =
            switch state {
            case .data: .data
            case .plaintext: .plaintext
            case .rcdata: .rcdata
            case .rawtext: .rawtext
            case .scriptData: .scriptData
            case .cdataSection: .cdataSection
            }
    }
}

public struct ExpectedError: Equatable, Sendable, Decodable {
    var code: String
    var line: Int
    var col: Int
}

public struct TestCase: Equatable, Sendable {
    var title: String
    var input: String
    var tokens: [Token]
    var initialState: State
    var errors: [ExpectedError]
}

extension TestCase: CustomStringConvertible {
    public var description: String {
        switch self.initialState {
        case .data: self.title
        case let state: "\(self.title) (\(state))"
        }
    }
}

enum TestParseError: Error {
    case invalidTokenType(ExpectedTokenField?)
    case invalidTokenFormat([ExpectedTokenField?])
}

func parseTestCases(from data: consuming Data) throws -> [TestCase] {
    try JSONDecoder().decode(TestFile.self, from: data).tests.flatMap { try $0.into() }
}
