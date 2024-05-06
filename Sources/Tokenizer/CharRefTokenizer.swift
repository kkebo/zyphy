private import HTMLEntities

private enum CharRefState {
    case initial
    case named
    case namedEnd(endIndex: String.Index, replaceChars: (Char, Char))
    case ambiguousAmpersand
    case numeric
    case hexadecimalStart(uppercase: Bool)
    case decimalStart
    case hexadecimal
    case decimal
    case numericEnd
}

private enum CharRefProcessResult: ~Copyable {
    case done(StrSlice)
    case doneNone
    case progress
}

struct CharRefTokenizer {
    private var state: CharRefState = .initial
    private var num: Int = 0
    private var numTooBig: Bool = false
    private var nameBuffer: String = ""
    private var lastMatch: (endIndex: String.Index, replaceChars: (Char, Char))?
    private let isInAttr: Bool

    init(inAttr isInAttr: Bool) {
        self.isInAttr = isInAttr
    }

    mutating func tokenize(tokenizer: inout Tokenizer<some ~Copyable & TokenSink>, input: inout BufferQueue) -> StrSlice? {
        repeat {
            switch self.step(tokenizer: &tokenizer, input: &input) {
            case .done(let scalars): return scalars
            case .doneNone: return ["&"]
            case .progress: break
            }
        } while true
    }

    private mutating func step(tokenizer: inout Tokenizer<some ~Copyable & TokenSink>, input: inout BufferQueue) -> CharRefProcessResult {
        switch self.state {
        case .initial:
            switch tokenizer.peek(input) {
            case ("0"..."9")?, ("A"..."Z")?, ("a"..."z")?:
                self.state = .named
                return .progress
            case "#":
                tokenizer.discardChar(&input)
                self.state = .numeric
                return .progress
            case _: return .doneNone
            }
        case .named:
            guard let c = tokenizer.peek(input) else {
                guard let (endIndex, chars) = lastMatch else {
                    input.prepend(StrSlice(self.nameBuffer.unicodeScalars))
                    return .doneNone
                }
                self.state = .namedEnd(endIndex: endIndex, replaceChars: chars)
                return .progress
            }
            tokenizer.discardChar(&input)
            self.nameBuffer.append(Character(c))
            switch processedNamedChars[self.nameBuffer] {
            case ("\0", _)?: break
            case let chars?: lastMatch = (self.nameBuffer.endIndex, chars)
            case nil:
                if let (endIndex, chars) = lastMatch {
                    self.state = .namedEnd(endIndex: endIndex, replaceChars: chars)
                } else {
                    self.state = .ambiguousAmpersand
                }
            }
            return .progress
        case .namedEnd(let endIndex, let replaceChars):
            // swift-format-ignore: NeverForceUnwrap
            let lastChar = self.nameBuffer[..<endIndex].last!
            let nextChar: Char? =
                if self.nameBuffer.endIndex != endIndex {
                    self.nameBuffer[endIndex].firstScalar
                } else {
                    nil
                }
            switch (isInAttr, lastChar, nextChar) {
            case (_, ";", _): break
            case (true, _, "="?), (true, _, ("0"..."9")?), (true, _, ("A"..."Z")?), (true, _, ("a"..."z")?):
                input.prepend(StrSlice(self.nameBuffer.unicodeScalars))
                return .doneNone
            case _: tokenizer.emitError(.missingSemicolon)
            }
            input.prepend(StrSlice(self.nameBuffer[endIndex...].unicodeScalars))
            return switch replaceChars {
            case (let c1, "\0"): .done([c1])
            case (let c1, let c2): .done([c1, c2])
            }
        case .ambiguousAmpersand:
            guard let c = tokenizer.peek(input) else {
                input.prepend(StrSlice(self.nameBuffer.unicodeScalars))
                return .doneNone
            }
            switch c {
            case "0"..."9", "A"..."Z", "a"..."z":
                tokenizer.discardChar(&input)
                self.nameBuffer.append(Character(c))
                return .progress
            case ";": tokenizer.emitError(.unknownNamedCharRef)
            case _: break
            }
            input.prepend(StrSlice(self.nameBuffer.unicodeScalars))
            return .doneNone
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
            switch tokenizer.peek(input) {
            case ("0"..."9")?, ("A"..."F")?, ("a"..."f")?:
                self.state = .hexadecimal
                return .progress
            case _:
                tokenizer.emitError(.absenceDigits)
                input.prepend(uppercase ? ["#", "X"] : ["#", "x"])
                return .doneNone
            }
        case .decimalStart:
            switch tokenizer.peek(input) {
            case ("0"..."9")?:
                self.state = .decimal
                return .progress
            case _:
                tokenizer.emitError(.absenceDigits)
                input.prepend(["#"])
                return .doneNone
            }
        case .hexadecimal:
            if let firstScalar = tokenizer.peek(input) {
                switch firstScalar {
                case "0"..."9":
                    tokenizer.discardChar(&input)
                    self.num &*= 16
                    if self.num > 0x10FFFF {
                        self.numTooBig = true
                    }
                    self.num &+= Int(firstScalar.value &- 0x30)
                    return .progress
                case "A"..."F":
                    tokenizer.discardChar(&input)
                    self.num &*= 16
                    if self.num > 0x10FFFF {
                        self.numTooBig = true
                    }
                    self.num &+= Int(firstScalar.value &- 0x37)
                    return .progress
                case "a"..."f":
                    tokenizer.discardChar(&input)
                    self.num &*= 16
                    if self.num > 0x10FFFF {
                        self.numTooBig = true
                    }
                    self.num &+= Int(firstScalar.value &- 0x57)
                    return .progress
                case ";":
                    tokenizer.discardChar(&input)
                    self.state = .numericEnd
                    return .progress
                case _: break
                }
            }
            tokenizer.emitError(.missingSemicolon)
            self.state = .numericEnd
            return .progress
        case .decimal:
            if let firstScalar = tokenizer.peek(input) {
                switch firstScalar {
                case "0"..."9":
                    tokenizer.discardChar(&input)
                    self.num &*= 10
                    if self.num > 0x10FFFF {
                        self.numTooBig = true
                    }
                    self.num &+= Int(firstScalar.value &- 0x30)
                    return .progress
                case ";":
                    tokenizer.discardChar(&input)
                    self.state = .numericEnd
                    return .progress
                case _: break
                }
            }
            tokenizer.emitError(.missingSemicolon)
            self.state = .numericEnd
            return .progress
        case .numericEnd:
            // swift-format-ignore: NeverForceUnwrap
            @inline(__always)
            func conv(_ n: Int) -> Char { .init(n)! }
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
                return switch replacements[self.num &- 0x80] {
                case "\0": .done([conv(self.num)])
                case let c: .done([c])
                }
            case let n: return .done([conv(n)])
            }
        }
    }
}
