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
        loop: while true {
            self.charRefTokenzier?.tokenize(&input)

            switch self.state {
            case .data: while true {
                switch self.getChar(from: &input) {
                case "&": self.consumeCharRef(); continue loop
                case "<": self.go(to: .tagOpen); continue loop
                case "\0": self.emit(.error(.unexpectedNull), "\0");
                case nil: self.emit(.eof); break loop
                case let c?: self.emit(c)
                }
            }
            case .rcdata: while true {
                switch self.getChar(from: &input) {
                case "&": self.consumeCharRef(); continue loop
                case "<": self.go(to: .rcdataLessThanSign); continue loop
                case "\0": self.emit(.error(.unexpectedNull), "\u{FFFD}")
                case nil: self.emit(.eof); break loop
                case let c?: self.emit(c)
                }
            }
            case .rawtext: while true {
                switch self.getChar(from: &input) {
                case "<": self.go(to: .rawtextLessThanSign); continue loop
                case "\0": self.emit(.error(.unexpectedNull), "\u{FFFD}")
                case nil: self.emit(.eof); break loop
                case let c?: self.emit(c)
                }
            }
            case .scriptData: while true {
                switch self.getChar(from: &input) {
                case "<": self.go(to: .scriptDatalessThanSign); continue loop
                case "\0": self.emit(.error(.unexpectedNull), "\u{FFFD}")
                case nil: self.emit(.eof); break loop
                case let c?: self.emit(c)
                }
            }
            case .plaintext: while true {
                switch self.getChar(from: &input) {
                case "\0": self.emit(.error(.unexpectedNull), "\u{FFFD}")
                case nil: self.emit(.eof); break loop
                case let c?: self.emit(c)
                }
            }
            case .tagOpen: while true {
                switch self.getChar(from: &input) {
                case "!": self.go(to: .markupDeclarationOpen); continue loop
                case "/": self.go(to: .endTagOpen); continue loop
                case "?":
                    self.emit(.error(.unexpectedQuestionMark))
                    self.createComment(with: "?")
                    self.go(to: .bogusComment); continue loop
                case nil: self.emit(.error(.eofBeforeTagName), "<", .eof); break loop
                case let c? where c.isASCII && c.isLetter:
                    self.createStartTag(with: c.lowercased())
                    self.go(to: .tagName); continue loop
                case let c?:
                    self.emit(.error(.invalidFirstCharacter), "<")
                    self.reconsume(c, in: .data); continue loop
                }
            }
            case .endTagOpen: while true {
                switch self.getChar(from: &input) {
                case ">":
                    self.emit(.error(.missingEndTagName))
                    self.go(to: .data); continue loop
                case "\0":
                    self.emit(.error(.invalidFirstCharacter), .error(.unexpectedNull))
                    self.createComment(with: "\u{FFFD}")
                    self.go(to: .bogusComment); continue loop
                case nil: self.emit(.error(.eofBeforeTagName), "<", "/", .eof); break loop
                case let c? where c.isASCII && c.isLetter:
                    self.createEndTag(with: c.lowercased())
                    self.go(to: .tagName); continue loop
                case let c?:
                    self.emit(.error(.invalidFirstCharacter))
                    self.createComment(with: c)
                    self.go(to: .bogusComment); continue loop
                }
            }
            case .tagName: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": self.go(to: .beforeAttributeName); continue loop
                case "/": self.go(to: .selfClosingStartTag); continue loop
                case ">": self.emitTagAndGo(to: .data); continue loop
                case "\0":
                    self.emit(.error(.unexpectedNull))
                    self.appendTagName("\u{FFFD}" as Character)
                case nil: self.emit(.error(.eofInTag), .eof); break loop
                case let c? where c.isASCII && c.isUppercase: self.appendTagName(c.lowercased())
                case let c?: self.appendTagName(c)
                }
            }
            case .rcdataLessThanSign: while true {
                switch self.getChar(from: &input) {
                case "/":
                    // TODO: Set the temporary buffer to the empty string
                    self.go(to: .rcdataEndTagOpen); continue loop
                case nil: self.emit("<", .eof); break loop
                case let c?:
                    self.emit("<")
                    self.reconsume(c, in: .rcdata); continue loop
                }
            }
            case .rcdataEndTagOpen: while true {
                switch self.getChar(from: &input) {
                case let c? where c.isASCII && c.isLetter:
                    self.createEndTag(with: c)
                    self.go(to: .rcdataEndTagName); continue loop
                case nil: self.emit("<", "/", .eof); break loop
                case let c?:
                    self.emit("<", "/")
                    self.reconsume(c, in: .rcdata); continue loop
                }
            }
            case .rcdataEndTagName: while true {
                // FIXME: Implement
                preconditionFailure("Not implemented")
            }
            case .bogusComment: while true {
                switch self.getChar(from: &input) {
                case ">": self.emitCommentAndGo(to: .data); continue loop
                case "\0":
                    self.emit(.error(.unexpectedNull))
                    self.appendComment("\u{FFFD}" as Character)
                case nil: self.emitCommentAndEOF(); break loop
                case let c?: self.appendComment(c)
                }
            }
            case _:
                preconditionFailure("Not implemented")
            }
        }
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
    private mutating func emitTagAndGo(to state: State) {
        self.sink.process(.tag(self.currentTagName, kind: self.currentTagKind))
        self.state = state
    }

    @inline(__always)
    private mutating func emitCommentAndGo(to state: State) {
        self.sink.process(.comment(self.currentComment))
        self.state = state
    }

    @inline(__always)
    private mutating func emitCommentAndEOF() {
        self.sink.process(.comment(self.currentComment))
        self.sink.process(.eof)
    }
}

#if TESTING_ENABLED
    import Foundation
    import PlaygroundTester

    // TODO: Make TestSink a struct
    final class TestSink {
        var tokens = [Token]()
    }

    extension TestSink: TokenSink {
        func process(_ token: Token) {
            self.tokens.append(token)
        }
    }

    @objcMembers
    final class TokenizerTests: TestCase {
        func testTokenizeBasicHTML() {
            let html = "<html>hi</html>"

            let sink = TestSink()
            var tokenizer = Tokenizer(sink: sink)
            var iter = html.makeIterator()
            tokenizer.tokenize(&iter)

            AssertEqual(
                [.tag("html", kind: .start), "h", "i", .tag("html", kind: .end), .eof],
                other: sink.tokens
            )
        }
    }
#endif
