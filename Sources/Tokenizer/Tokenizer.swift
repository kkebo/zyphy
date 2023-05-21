public enum ParseError {
    case unexpectedNullCharacter
}

extension ParseError: Error {}

public struct Tokenizer {
    public init() {}

    public func tokenize(input: String) throws {
        var state = State.data
        var returnState: State?
        for c in input {
            try consume(c, state: &state, returnState: &returnState)
        }
    }

    @inline(__always)
    private func consume(
        _ c: Character,
        state: inout State,
        returnState: inout State?
    ) throws {
        switch (state, c) {
        case (.data, "&"):
            returnState = .data
            state = .characterReference
        case (.data, "<"):
            state = .tagOpen
        case (.data, "\0"):
            throw ParseError.unexpectedNullCharacter
            // emit the current input character as a character token
        // case (.data, EOF):
            // emit an end-of-file token
        case (.data, _):
            // emit the current input character as a character token
            break
        case _:
            preconditionFailure("Not implemented")
        }
    }
}
