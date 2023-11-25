private enum CharRefState {
    case initial
    case named
    case ambiguousAmpersand
    case numeric
    case hexadecimalStart(uppercase: Bool)
    case decimalStart
    case hexadecimal
    case decimal
    case numericEnd
}

private enum CharRefProcessResult: ~Copyable {
    case done([Unicode.Scalar])
    case doneNone
    case progress
}

struct CharRefTokenizer {
    private var state: CharRefState = .initial
    private var num: Int = 0
    private var numTooBig: Bool = false

    mutating func tokenize(tokenizer: inout Tokenizer<some TokenSink>, input: inout String.Iterator) -> [Unicode.Scalar]? {
        while true {
            switch self.step(tokenizer: &tokenizer, input: &input) {
            case .done(let scalars): return scalars
            case .doneNone: return nil
            case .progress: break
            }
        }
    }

    private mutating func step(tokenizer: inout Tokenizer<some TokenSink>, input: inout String.Iterator) -> CharRefProcessResult {
        switch self.state {
        case .initial:
            switch tokenizer.peek(input) {
            case let c? where c.isASCII && (c.isLetter || c.isWholeNumber):
                self.state = .named
                return .progress
            case "#":
                tokenizer.discardChar(&input)
                self.state = .numeric
                return .progress
            case _: return .done(["&"])
            }
        case .named:
            // TODO: If there is a match
            guard false else {
                // TODO: Flush code points consumed as a character reference
                tokenizer.processCharRef("&")
                self.state = .ambiguousAmpersand
                return .progress
            }
        case .ambiguousAmpersand:
            switch tokenizer.peek(input) {
            case let c? where c.isASCII && c.isLetter:
                tokenizer.discardChar(&input)
                tokenizer.processCharRef(c)
                return .progress
            case ";":
                tokenizer.emitError(.unknownNamedCharRef)
                return .doneNone
            case _?: return .doneNone
            case nil: return .doneNone
            }
        case .numeric:
            switch tokenizer.peek(input) {
            case "X":
                tokenizer.discardChar(&input)
                self.state = .hexadecimalStart(uppercase: true)
                return .progress
            case "x":
                tokenizer.discardChar(&input)
                self.state = .hexadecimalStart(uppercase: false)
                return .progress
            case _:
                self.state = .decimalStart
                return .progress
            }
        case .hexadecimalStart(let uppercase):
            guard let c = tokenizer.peek(input), c.isHexDigit else {
                tokenizer.emitError(.absenceDigits)
                return .done(["&", "#", uppercase ? "X" : "x"])
            }
            self.state = .hexadecimal
            return .progress
        case .decimalStart:
            guard let c = tokenizer.peek(input), c.isASCII && c.isWholeNumber else {
                tokenizer.emitError(.absenceDigits)
                return .done(["&", "#"])
            }
            self.state = .decimal
            return .progress
        case .hexadecimal:
            if let c = tokenizer.peek(input) {
                if let n = c.hexDigitValue {
                    tokenizer.discardChar(&input)
                    self.num &*= 16
                    if self.num > 0x10FFFF {
                        self.numTooBig = true
                    }
                    self.num &+= n
                    return .progress
                } else if ";" ~= c {
                    tokenizer.discardChar(&input)
                    self.state = .numericEnd
                    return .progress
                }
            }
            tokenizer.emitError(.missingSemicolon)
            self.state = .numericEnd
            return .progress
        case .decimal:
            if let c = tokenizer.peek(input) {
                if c.isASCII, let n = c.wholeNumberValue {
                    tokenizer.discardChar(&input)
                    self.num &*= 10
                    if self.num > 0x10FFFF {
                        self.numTooBig = true
                    }
                    self.num &+= n
                    return .progress
                } else if ";" ~= c {
                    tokenizer.discardChar(&input)
                    self.state = .numericEnd
                    return .progress
                }
            }
            tokenizer.emitError(.missingSemicolon)
            self.state = .numericEnd
            return .progress
        case .numericEnd:
            // swift-format-ignore: NeverForceUnwrap
            @inline(__always)
            func conv(_ n: Int) -> Unicode.Scalar { .init(n)! }
            switch self.num {
            case 0x00:
                tokenizer.emitError(.nullCharRef)
                return .done(["\u{FFFD}"])
            case let n where n > 0x10FFFF || self.numTooBig:
                tokenizer.emitError(.charRefOutOfRange)
                return .done(["\u{FFFD}"])
            case 0xD800...0xDBFF, 0xDC00...0xDFFF:
                tokenizer.emitError(.surrogateCharRef)
                return .done(["\u{FFFD}"])
            case 0xFDD0...0xFDEF, 0xFFFE, 0xFFFF, 0x1FFFE, 0x1FFFF, 0x2FFFE, 0x2FFFF,
                0x3FFFE, 0x3FFFF, 0x4FFFE, 0x4FFFF, 0x5FFFE, 0x5FFFF, 0x6FFFE, 0x6FFFF,
                0x7FFFE, 0x7FFFF, 0x8FFFE, 0x8FFFF, 0x9FFFE, 0x9FFFF, 0xAFFFE, 0xAFFFF,
                0xBFFFE, 0xBFFFF, 0xCFFFE, 0xCFFFF, 0xDFFFE, 0xDFFFF, 0xEFFFE, 0xEFFFF,
                0xFFFFE, 0xFFFFF, 0x10FFFE, 0x10FFFF:
                tokenizer.emitError(.noncharacterCharRef)
                return .done([conv(self.num)])
            case 0x0D, 0x01...0x08, 0x0B, 0x0D...0x1F, 0x7F:
                tokenizer.emitError(.controlCharRef)
                return .done([conv(self.num)])
            case 0x80...0x9F:
                tokenizer.emitError(.controlCharRef)
                return switch replacements[self.num - 0x80] {
                case "\0": .done([conv(self.num)])
                case let c: .done([c])
                }
            case let n: return .done([conv(n)])
            }
        }
    }
}
