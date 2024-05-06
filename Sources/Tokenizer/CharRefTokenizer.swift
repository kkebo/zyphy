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
        case .initial: self.initial(input: &input)
        case .named: self.named(input: &input)
        case .namedEnd(let endIndex, let replaceChars): self.namedEnd(endIndex: endIndex, replaceChars: replaceChars, tokenizer: &tokenizer, input: &input)
        case .ambiguousAmpersand: self.ambiguousAmpersand(tokenizer: &tokenizer, input: &input)
        case .numeric: self.numeric(input: &input)
        case .hexadecimalStart(let uppercase): self.hexadecimalStart(uppercase: uppercase, tokenizer: &tokenizer, input: &input)
        case .decimalStart: self.decimalStart(tokenizer: &tokenizer, input: &input)
        case .hexadecimal: self.hexadecimal(tokenizer: &tokenizer, input: &input)
        case .decimal: self.decimal(tokenizer: &tokenizer, input: &input)
        case .numericEnd: self.numericEnd(tokenizer: &tokenizer, input: &input)
        }
    }

    @inline(__always)
    private mutating func initial(input: inout BufferQueue) -> CharRefProcessResult {
        switch input.peek() {
        case ("0"..."9")?, ("A"..."Z")?, ("a"..."z")?:
            self.state = .named
            return .progress
        case "#":
            input.removeFirst()
            self.state = .numeric
            return .progress
        case _: return .doneNone
        }
    }

    @inline(__always)
    private mutating func named(input: inout BufferQueue) -> CharRefProcessResult {
        guard let c = input.peek() else {
            guard let (endIndex, chars) = lastMatch else {
                input.prepend(StrSlice(self.nameBuffer.unicodeScalars))
                return .doneNone
            }
            self.state = .namedEnd(endIndex: endIndex, replaceChars: chars)
            return .progress
        }
        input.removeFirst()
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
    }

    @inline(__always)
    private mutating func namedEnd(endIndex: String.Index, replaceChars: (Char, Char), tokenizer: inout Tokenizer<some ~Copyable & TokenSink>, input: inout BufferQueue) -> CharRefProcessResult {
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
    }

    @inline(__always)
    private mutating func ambiguousAmpersand(tokenizer: inout Tokenizer<some ~Copyable & TokenSink>, input: inout BufferQueue) -> CharRefProcessResult {
        guard let c = input.peek() else {
            input.prepend(StrSlice(self.nameBuffer.unicodeScalars))
            return .doneNone
        }
        switch c {
        case "0"..."9", "A"..."Z", "a"..."z":
            input.removeFirst()
            self.nameBuffer.append(Character(c))
            return .progress
        case ";": tokenizer.emitError(.unknownNamedCharRef)
        case _: break
        }
        input.prepend(StrSlice(self.nameBuffer.unicodeScalars))
        return .doneNone
    }

    @inline(__always)
    private mutating func numeric(input: inout BufferQueue) -> CharRefProcessResult {
        switch input.peek() {
        case "X":
            input.removeFirst()
            self.state = .hexadecimalStart(uppercase: true)
            return .progress
        case "x":
            input.removeFirst()
            self.state = .hexadecimalStart(uppercase: false)
            return .progress
        case _:
            self.state = .decimalStart
            return .progress
        }
    }

    @inline(__always)
    private mutating func hexadecimalStart(uppercase: Bool, tokenizer: inout Tokenizer<some ~Copyable & TokenSink>, input: inout BufferQueue) -> CharRefProcessResult {
        switch input.peek() {
        case ("0"..."9")?, ("A"..."F")?, ("a"..."f")?:
            self.state = .hexadecimal
            return .progress
        case _:
            tokenizer.emitError(.absenceDigits)
            input.prepend(uppercase ? ["#", "X"] : ["#", "x"])
            return .doneNone
        }
    }

    @inline(__always)
    private mutating func decimalStart(tokenizer: inout Tokenizer<some ~Copyable & TokenSink>, input: inout BufferQueue) -> CharRefProcessResult {
        switch input.peek() {
        case ("0"..."9")?:
            self.state = .decimal
            return .progress
        case _:
            tokenizer.emitError(.absenceDigits)
            input.prepend(["#"])
            return .doneNone
        }
    }

    @inline(__always)
    private mutating func hexadecimal(tokenizer: inout Tokenizer<some ~Copyable & TokenSink>, input: inout BufferQueue) -> CharRefProcessResult {
        if let firstScalar = input.peek() {
            switch firstScalar {
            case "0"..."9":
                input.removeFirst()
                self.num &*= 16
                if self.num > 0x10FFFF {
                    self.numTooBig = true
                }
                self.num &+= Int(firstScalar.value &- 0x30)
                return .progress
            case "A"..."F":
                input.removeFirst()
                self.num &*= 16
                if self.num > 0x10FFFF {
                    self.numTooBig = true
                }
                self.num &+= Int(firstScalar.value &- 0x37)
                return .progress
            case "a"..."f":
                input.removeFirst()
                self.num &*= 16
                if self.num > 0x10FFFF {
                    self.numTooBig = true
                }
                self.num &+= Int(firstScalar.value &- 0x57)
                return .progress
            case ";":
                input.removeFirst()
                self.state = .numericEnd
                return .progress
            case _: break
            }
        }
        tokenizer.emitError(.missingSemicolon)
        self.state = .numericEnd
        return .progress
    }

    @inline(__always)
    private mutating func decimal(tokenizer: inout Tokenizer<some ~Copyable & TokenSink>, input: inout BufferQueue) -> CharRefProcessResult {
        if let firstScalar = input.peek() {
            switch firstScalar {
            case "0"..."9":
                input.removeFirst()
                self.num &*= 10
                if self.num > 0x10FFFF {
                    self.numTooBig = true
                }
                self.num &+= Int(firstScalar.value &- 0x30)
                return .progress
            case ";":
                input.removeFirst()
                self.state = .numericEnd
                return .progress
            case _: break
            }
        }
        tokenizer.emitError(.missingSemicolon)
        self.state = .numericEnd
        return .progress
    }

    @inline(__always)
    private mutating func numericEnd(tokenizer: inout Tokenizer<some ~Copyable & TokenSink>, input: inout BufferQueue) -> CharRefProcessResult {
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
