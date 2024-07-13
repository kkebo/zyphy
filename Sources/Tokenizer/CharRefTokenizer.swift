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

enum CharRefProcessResult: ~Copyable {
    case `continue`
    case doneChars(StrSlice)
    case doneChar(Char)
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

    mutating func step(tokenizer: inout Tokenizer<some ~Copyable & TokenSink>, input: inout BufferQueue) -> CharRefProcessResult {
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
            return .continue
        case "#":
            input.removeFirst()
            self.state = .numeric
            return .continue
        case _: return .doneChar("&")
        }
    }

    @inline(__always)
    private mutating func named(input: inout BufferQueue) -> CharRefProcessResult {
        repeat {
            guard let c = input.peek() else {
                guard let (endIndex, chars) = lastMatch else {
                    input.prepend(StrSlice(self.nameBuffer.unicodeScalars))
                    return .doneChar("&")
                }
                self.state = .namedEnd(endIndex: endIndex, replaceChars: chars)
                return .continue
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
                return .continue
            }
        } while true
    }

    @inline(__always)
    private mutating func namedEnd(endIndex: String.Index, replaceChars: (Char, Char), tokenizer: inout Tokenizer<some ~Copyable & TokenSink>, input: inout BufferQueue) -> CharRefProcessResult {
        let lastChar = self.nameBuffer[..<endIndex].last
        let nextChar: Char? =
            if self.nameBuffer.endIndex != endIndex {
                // swift-format-ignore: NeverForceUnwrap
                self.nameBuffer[endIndex].unicodeScalars.first
            } else {
                nil
            }
        switch (isInAttr, lastChar, nextChar) {
        case (_, ";", _): break
        case (true, _, "="?), (true, _, ("0"..."9")?), (true, _, ("A"..."Z")?), (true, _, ("a"..."z")?):
            input.prepend(StrSlice(self.nameBuffer.unicodeScalars))
            return .doneChar("&")
        case _: tokenizer.emitError(.missingSemicolon)
        }
        input.prepend(StrSlice(self.nameBuffer[endIndex...].unicodeScalars))
        return switch replaceChars {
        case (let c1, "\0"): .doneChar(c1)
        case (let c1, let c2): .doneChars([c1, c2])
        }
    }

    @inline(__always)
    private mutating func ambiguousAmpersand(tokenizer: inout Tokenizer<some ~Copyable & TokenSink>, input: inout BufferQueue) -> CharRefProcessResult {
        repeat {
            guard let c = input.peek() else {
                input.prepend(StrSlice(self.nameBuffer.unicodeScalars))
                return .doneChar("&")
            }
            switch c {
            case "0"..."9", "A"..."Z", "a"..."z":
                input.removeFirst()
                self.nameBuffer.append(Character(c))
                continue
            case ";": tokenizer.emitError(.unknownNamedCharRef)
            case _: break
            }
            input.prepend(StrSlice(self.nameBuffer.unicodeScalars))
            return .doneChar("&")
        } while true
    }

    @inline(__always)
    private mutating func numeric(input: inout BufferQueue) -> CharRefProcessResult {
        switch input.peek() {
        case "X":
            input.removeFirst()
            self.state = .hexadecimalStart(uppercase: true)
        case "x":
            input.removeFirst()
            self.state = .hexadecimalStart(uppercase: false)
        case _:
            self.state = .decimalStart
        }
        return .continue
    }

    @inline(__always)
    private mutating func hexadecimalStart(uppercase: Bool, tokenizer: inout Tokenizer<some ~Copyable & TokenSink>, input: inout BufferQueue) -> CharRefProcessResult {
        switch input.peek() {
        case ("0"..."9")?, ("A"..."F")?, ("a"..."f")?:
            self.state = .hexadecimal
            return .continue
        case _:
            tokenizer.emitError(.absenceDigits)
            input.prepend(uppercase ? "#X" : "#x")
            return .doneChar("&")
        }
    }

    @inline(__always)
    private mutating func decimalStart(tokenizer: inout Tokenizer<some ~Copyable & TokenSink>, input: inout BufferQueue) -> CharRefProcessResult {
        switch input.peek() {
        case ("0"..."9")?:
            self.state = .decimal
            return .continue
        case _:
            tokenizer.emitError(.absenceDigits)
            input.prepend("#")
            return .doneChar("&")
        }
    }

    @inline(__always)
    private mutating func hexadecimal(tokenizer: inout Tokenizer<some ~Copyable & TokenSink>, input: inout BufferQueue) -> CharRefProcessResult {
        repeat {
            if let c = input.peek() {
                switch c {
                case "0"..."9":
                    input.removeFirst()
                    self.num &*= 16
                    if self.num > 0x10FFFF {
                        self.numTooBig = true
                    }
                    self.num &+= Int(c.value &- 0x30)
                    continue
                case "A"..."F":
                    input.removeFirst()
                    self.num &*= 16
                    if self.num > 0x10FFFF {
                        self.numTooBig = true
                    }
                    self.num &+= Int(c.value &- 0x37)
                    continue
                case "a"..."f":
                    input.removeFirst()
                    self.num &*= 16
                    if self.num > 0x10FFFF {
                        self.numTooBig = true
                    }
                    self.num &+= Int(c.value &- 0x57)
                    continue
                case ";":
                    input.removeFirst()
                    self.state = .numericEnd
                    return .continue
                case _: break
                }
            }
            tokenizer.emitError(.missingSemicolon)
            self.state = .numericEnd
            return .continue
        } while true
    }

    @inline(__always)
    private mutating func decimal(tokenizer: inout Tokenizer<some ~Copyable & TokenSink>, input: inout BufferQueue) -> CharRefProcessResult {
        repeat {
            if let c = input.peek() {
                switch c {
                case "0"..."9":
                    input.removeFirst()
                    self.num &*= 10
                    if self.num > 0x10FFFF {
                        self.numTooBig = true
                    }
                    self.num &+= Int(c.value &- 0x30)
                    continue
                case ";":
                    input.removeFirst()
                    self.state = .numericEnd
                    return .continue
                case _: break
                }
            }
            tokenizer.emitError(.missingSemicolon)
            self.state = .numericEnd
            return .continue
        } while true
    }

    // swift-format-ignore: NeverForceUnwrap
    @inline(__always)
    private mutating func numericEnd(tokenizer: inout Tokenizer<some ~Copyable & TokenSink>, input: inout BufferQueue) -> CharRefProcessResult {
        switch self.num {
        case 0x00:
            tokenizer.emitError(.nullCharRef)
            return .doneChar("\u{FFFD}")
        case let n where n > 0x10FFFF || self.numTooBig:
            tokenizer.emitError(.charRefOutOfRange)
            return .doneChar("\u{FFFD}")
        case 0xD800...0xDBFF, 0xDC00...0xDFFF:
            tokenizer.emitError(.surrogateCharRef)
            return .doneChar("\u{FFFD}")
        case 0xFDD0...0xFDEF, 0xFFFE, 0xFFFF, 0x1FFFE, 0x1FFFF, 0x2FFFE, 0x2FFFF,
            0x3FFFE, 0x3FFFF, 0x4FFFE, 0x4FFFF, 0x5FFFE, 0x5FFFF, 0x6FFFE, 0x6FFFF,
            0x7FFFE, 0x7FFFF, 0x8FFFE, 0x8FFFF, 0x9FFFE, 0x9FFFF, 0xAFFFE, 0xAFFFF,
            0xBFFFE, 0xBFFFF, 0xCFFFE, 0xCFFFF, 0xDFFFE, 0xDFFFF, 0xEFFFE, 0xEFFFF,
            0xFFFFE, 0xFFFFF, 0x10FFFE, 0x10FFFF:
            tokenizer.emitError(.noncharacterCharRef)
            return .doneChar(Char(self.num)!)
        case 0x0D, 0x01...0x08, 0x0B, 0x0D...0x1F, 0x7F:
            tokenizer.emitError(.controlCharRef)
            return .doneChar(Char(self.num)!)
        case 0x80...0x9F:
            tokenizer.emitError(.controlCharRef)
            return switch replacements[self.num &- 0x80] {
            case "\0": .doneChar(Char(self.num)!)
            case let c: .doneChar(c)
            }
        case let n: return .doneChar(Char(n)!)
        }
    }
}
