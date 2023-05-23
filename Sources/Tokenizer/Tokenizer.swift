public struct Tokenizer<Sink: TokenSink> {
    var sink: Sink
    var state: State
    var reconsumeChar: Optional<Character>
    var charRefTokenzier: Optional<CharRefTokenizer>
    var currentTagName: String
    var currentTagKind: TagKind
    var currentComment: String

    public init(sink: Sink) {
        self.sink = sink
        self.state = .data
        self.reconsumeChar = nil
        self.charRefTokenzier = nil
        self.currentTagName = ""
        self.currentTagKind = .start
        self.currentComment = ""
    }

    // TODO: Consider input type
    public mutating func tokenize(_ input: inout String.Iterator) {
        while true {
            self.charRefTokenzier?.tokenize(&input)

            guard let c = self.getChar(from: &input) else { break }
            self.consume(c)
        }

        self.consumeEOF()
    }

    @inline(__always)
    private mutating func getChar(from input: inout String.Iterator) -> Character? {
        if let reconsumeChar {
            self.reconsumeChar = nil
            return reconsumeChar
        } else {
            return input.next()
        }
    }

    @inline(__always)
    private mutating func consume(_ c: Character) {
        switch self.state {
        case .data:
            switch c {
            case "&": self.consumeCharRef()
            case "<": self.go(to: .tagOpen)
            case "\0": self.emit(.error(.unexpectedNull), "\0")
            case let c: self.emit(c)
            }
        case .rcdata:
            switch c {
            case "&": self.consumeCharRef()
            case "<": self.go(to: .rcdataLessThanSign)
            case "\0": self.emit(.error(.unexpectedNull), "\u{FFFD}")
            case let c: self.emit(c)
            }
        case .rawtext:
            switch c {
            case "<": self.go(to: .rawtextLessThanSign)
            case "\0": self.emit(.error(.unexpectedNull), "\u{FFFD}")
            case let c: self.emit(c)
            }
        case .scriptData:
            switch c {
            case "<": self.go(to: .scriptDatalessThanSign)
            case "\0": self.emit(.error(.unexpectedNull), "\u{FFFD}")
            case let c: self.emit(c)
            }
        case .plaintext:
            switch c {
            case "\0": self.emit(.error(.unexpectedNull), "\u{FFFD}")
            case let c: self.emit(c)
            }
        case .tagOpen:
            switch c {
            case "!": self.go(to: .markupDeclarationOpen)
            case "/": self.go(to: .endTagOpen)
            case "?":
                self.emit(.error(.unexpectedQuestionMark))
                self.createComment(with: "?")
                self.go(to: .bogusComment)
            case let c where c.isASCII && c.isLetter:
                self.createStartTag(with: c.lowercased())
                self.go(to: .tagName)
            case let c:
                self.emit(.error(.invalidFirstCharacter), "<")
                self.reconsume(c, in: .data)
            }
        case .endTagOpen:
            switch c {
            case ">":
                self.emit(.error(.missingEndTagName))
                self.go(to: .data)
            case "\0":
                self.emit(.error(.invalidFirstCharacter), .error(.unexpectedNull))
                self.createComment(with: "\u{FFFD}")
                self.go(to: .bogusComment)
            case let c where c.isASCII && c.isLetter:
                self.createEndTag(with: c.lowercased())
                self.go(to: .tagName)
            case let c:
                self.emit(.error(.invalidFirstCharacter))
                self.createComment(with: c)
                self.go(to: .bogusComment)
            }
        case .tagName:
            switch c {
            case "\t", "\n", "\u{0C}", " ": self.go(to: .beforeAttributeName)
            case "/": self.go(to: .selfClosingStartTag)
            case ">":
                self.emitTag()
                self.go(to: .data)
            case "\0":
                self.emit(.error(.unexpectedNull))
                self.appendTagName("\u{FFFD}" as Character)
            case let c where c.isASCII && c.isUppercase:
                self.appendTagName(c.lowercased())
            case let c: self.appendTagName(c)
            }
        case .rcdataLessThanSign:
            switch c {
            case "/":
                // TODO: Set the temporary buffer to the empty string
                self.go(to: .rcdataEndTagOpen)
            case let c:
                self.emit("<")
                self.reconsume(c, in: .rcdata)
            }
        case .rcdataEndTagOpen:
            switch c {
            case let c where c.isASCII && c.isLetter:
                self.createEndTag(with: c)
                self.go(to: .rcdataEndTagName)
            case let c:
                self.emit("<", "/")
                self.reconsume(c, in: .rcdata)
            }
        case .rcdataEndTagName:
            // FIXME: Implement
            preconditionFailure("Not implemented")
        case .bogusComment:
            switch c {
            case ">":
                self.emitComment()
                self.go(to: .data)
            case "\0":
                self.emit(.error(.unexpectedNull))
                self.appendComment("\u{FFFD}" as Character)
            case let c: self.appendComment(c)
            }
        case _:
            preconditionFailure("Not implemented")
        }
    }

    @inline(__always)
    private mutating func consumeEOF() {
        switch self.state {
        case .data, .rcdata, .rawtext, .scriptData, .plaintext:
            self.emit(.eof)
        case .tagOpen:
            self.emit(.error(.eofBeforeTagName), "<", .eof)
        case .endTagOpen:
            self.emit(.error(.eofBeforeTagName), "<", "/", .eof)
        case .tagName:
            self.emit(.error(.eofInTag), .eof)
        case .bogusComment:
            self.emitComment()
            self.emit(.eof)
        case _:
            preconditionFailure("Not implemented")
        }
    }

    @inline(__always)
    private mutating func go(to state: State) {
        self.state = state
    }

    @inline(__always)
    private mutating func reconsume(_ c: Character, in state: State) {
        self.reconsumeChar = c
        self.state = state
    }

    @inline(__always)
    private mutating func consumeCharRef() {
        self.charRefTokenzier = .init()
    }

    @inline(__always)
    private mutating func createComment(with c: Character) {
        self.currentComment = String(c)
    }

    @inline(__always)
    private mutating func appendComment(_ c: Character) {
        self.currentComment.append(c)
    }

    @inline(__always)
    private mutating func createStartTag(with c: Character) {
        self.currentTagName = String(c)
        self.currentTagKind = .start
    }

    @inline(__always)
    private mutating func createStartTag(with s: String) {
        self.currentTagName = s
        self.currentTagKind = .start
    }

    @inline(__always)
    private mutating func createEndTag(with c: Character) {
        self.currentTagName = String(c)
        self.currentTagKind = .end
    }

    @inline(__always)
    private mutating func createEndTag(with s: String) {
        self.currentTagName = s
        self.currentTagKind = .end
    }

    @inline(__always)
    private mutating func appendTagName(_ c: Character) {
        self.currentTagName.append(c)
    }

    @inline(__always)
    private mutating func appendTagName(_ s: String) {
        self.currentTagName.append(s)
    }

    @inline(__always)
    private mutating func emit(_ tokens: Token...) {
        for token in tokens {
            self.sink.process(token)
        }
    }

    @inline(__always)
    private mutating func emit(_ c: Character) {
        self.sink.process(.char(c))
    }

    @inline(__always)
    private mutating func emitTag() {
        self.sink.process(.tag(self.currentTagName))
    }

    @inline(__always)
    private mutating func emitComment() {
        self.sink.process(.comment(self.currentComment))
    }
}
