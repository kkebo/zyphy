public struct Tokenizer<Sink: TokenSink> {
    var sink: Sink
    var state: State
    var reconsumeChar: Optional<Character>
    var charRefTokenzier: Optional<CharRefTokenizer>
    var currentTagName: String
    var currentTagKind: TagKind
    var currentAttrName: String
    var currentAttrValue: String
    var currentAttrs: [Attribute]
    var currentTagSelfClosing: Bool
    var currentComment: String

    public init(sink: Sink) {
        self.sink = sink
        self.state = .data
        self.reconsumeChar = nil
        self.charRefTokenzier = nil
        self.currentTagName = ""
        self.currentTagKind = .start
        self.currentAttrName = ""
        self.currentAttrValue = ""
        self.currentAttrs = []
        self.currentTagSelfClosing = false
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
                    self.createTag(with: c.lowercased(), kind: .start)
                    self.go(to: .tagName); continue loop
                case let c?:
                    self.emit(.error(.invalidFirstChar), "<")
                    self.reconsume(c, in: .data); continue loop
                }
            }
            case .endTagOpen: while true {
                switch self.getChar(from: &input) {
                case ">":
                    self.emit(.error(.missingEndTagName))
                    self.go(to: .data); continue loop
                case "\0":
                    self.emit(.error(.invalidFirstChar), .error(.unexpectedNull))
                    self.createComment(with: "\u{FFFD}")
                    self.go(to: .bogusComment); continue loop
                case nil: self.emit(.error(.eofBeforeTagName), "<", "/", .eof); break loop
                case let c? where c.isASCII && c.isLetter:
                    self.createTag(with: c.lowercased(), kind: .end)
                    self.go(to: .tagName); continue loop
                case let c?:
                    self.emit(.error(.invalidFirstChar))
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
                    self.appendTagName("\u{FFFD}")
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
                    self.createTag(with: c, kind: .end)
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
            case .beforeAttributeName: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": break
                case "/": self.go(to: .selfClosingStartTag); continue loop
                case ">": self.emitTagAndGo(to: .data)
                case "=":
                    self.emit(.error(.unexpectedEqualsSign))
                    self.createAttr(with: "=")
                    self.go(to: .attributeName); continue loop
                case "\0":
                    self.emit(.error(.unexpectedNull))
                    self.createAttr(with: "\u{FFFD}")
                    self.go(to: .attributeName); continue loop
                case "\"":
                    self.emit(.error(.unexpectedCharInAttrName))
                    self.createAttr(with: "\"")
                    self.go(to: .attributeName); continue loop
                case "'":
                    self.emit(.error(.unexpectedCharInAttrName))
                    self.createAttr(with: "'")
                    self.go(to: .attributeName); continue loop
                case "<":
                    self.emit(.error(.unexpectedCharInAttrName))
                    self.createAttr(with: "<")
                    self.go(to: .attributeName); continue loop
                case nil: self.emit(.error(.eofInTag), .eof); break loop
                case let c? where c.isASCII && c.isUppercase:
                    self.createAttr(with: c.lowercased())
                    self.go(to: .attributeName); continue loop
                case let c?:
                    self.createAttr(with: c)
                    self.go(to: .attributeName); continue loop
                }
            }
            case .attributeName: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": break
                case "/": self.go(to: .selfClosingStartTag); continue loop
                case ">": self.emitTagAndGo(to: .data); continue loop
                case "=": self.go(to: .beforeAttributeValue); continue loop
                case "\0":
                    self.emit(.error(.unexpectedNull))
                    self.appendAttrName("\u{FFFD}")
                case "\"":
                    self.emit(.error(.unexpectedCharInAttrName))
                    self.appendAttrName("\"")
                case "'":
                    self.emit(.error(.unexpectedCharInAttrName))
                    self.appendAttrName("'")
                case "<":
                    self.emit(.error(.unexpectedCharInAttrName))
                    self.appendAttrName("<")
                case nil: self.emit(.error(.eofInTag), .eof); break loop
                case let c? where c.isASCII && c.isUppercase: self.appendAttrName(c.lowercased())
                case let c?: self.appendAttrName(c)
                }
            }
            case .afterAttributeName: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": break
                case "/": self.go(to: .selfClosingStartTag); continue loop
                case ">": self.emitTagAndGo(to: .data); continue loop
                case "=": self.go(to: .beforeAttributeValue); continue loop
                case "\0":
                    self.emit(.error(.unexpectedNull))
                    self.createAttr(with: "\u{FFFD}")
                    self.go(to: .attributeName); continue loop
                case "\"":
                    self.emit(.error(.unexpectedCharInAttrName))
                    self.createAttr(with: "\"")
                    self.go(to: .attributeName); continue loop
                case "'":
                    self.emit(.error(.unexpectedCharInAttrName))
                    self.createAttr(with: "'")
                    self.go(to: .attributeName); continue loop
                case "<":
                    self.emit(.error(.unexpectedCharInAttrName))
                    self.createAttr(with: "<")
                    self.go(to: .attributeName); continue loop
                case nil: self.emit(.error(.eofInTag), .eof); break loop
                case let c? where c.isASCII && c.isUppercase:
                    self.createAttr(with: c.lowercased())
                    self.go(to: .attributeName); continue loop
                case let c?:
                    self.createAttr(with: c)
                    self.go(to: .attributeName); continue loop
                }
            }
            case .beforeAttributeValue: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": break
                case "\"": self.go(to: .attributeValueDoubleQuoted); continue loop
                case "'": self.go(to: .attributeValueSingleQuoted); continue loop
                case ">":
                    self.emit(.error(.missingAttrValue))
                    self.emitTagAndGo(to: .data); continue loop
                case nil: self.emit(.error(.eofInTag), .eof); break loop
                case let c?: self.reconsume(c, in: .attributeValueUnquoted); continue loop
                }
            }
            case .attributeValueDoubleQuoted: while true {
                switch self.getChar(from: &input) {
                case "\"": self.go(to: .afterAttributeValueQuoted); continue loop
                case "&": self.consumeCharRef(); continue loop
                case "\0":
                    self.emit(.error(.unexpectedNull))
                    self.appendAttrValue("\u{FFFD}")
                case nil: self.emit(.error(.eofInTag), .eof); break loop
                case let c?: self.appendAttrValue(c)
                }
            }
            case .attributeValueSingleQuoted: while true {
                switch self.getChar(from: &input) {
                case "'": self.go(to: .afterAttributeValueQuoted); continue loop
                case "&": self.consumeCharRef(); continue loop
                case "\0":
                    self.emit(.error(.unexpectedNull))
                    self.appendAttrValue("\u{FFFD}")
                case nil: self.emit(.error(.eofInTag), .eof); break loop
                case let c?: self.appendAttrValue(c)
                }
            }
            case .attributeValueUnquoted: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": self.go(to: .beforeAttributeName); continue loop
                case "&": self.consumeCharRef(); continue loop
                case ">": self.emitTagAndGo(to: .data); continue loop
                case "\0":
                    self.emit(.error(.unexpectedNull))
                    self.appendAttrValue("\u{FFFD}")
                case nil: self.emit(.error(.eofInTag), .eof); break loop
                case "\"":
                    self.emit(.error(.unexpectedCharInUnquotedAttrValue))
                    self.appendAttrValue("\"")
                case "'":
                    self.emit(.error(.unexpectedCharInUnquotedAttrValue))
                    self.appendAttrValue("'")
                case "<":
                    self.emit(.error(.unexpectedCharInUnquotedAttrValue))
                    self.appendAttrValue("\"")
                case "=":
                    self.emit(.error(.unexpectedCharInUnquotedAttrValue))
                    self.appendAttrValue("\"")
                case "`":
                    self.emit(.error(.unexpectedCharInUnquotedAttrValue))
                    self.appendAttrValue("\"")
                case let c?: self.appendAttrValue(c)
                }
            }
            case .afterAttributeValueQuoted: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": self.go(to: .beforeAttributeName); continue loop
                case "/": self.go(to: .selfClosingStartTag); continue loop
                case ">": self.emitTagAndGo(to: .data); continue loop
                case nil: self.emit(.error(.eofInTag), .eof); break loop
                case let c?:
                    self.emit(.error(.missingWhitespaceBetweenAttrs))
                    self.reconsume(c, in: .beforeAttributeName); continue loop
                }
            }
            case .selfClosingStartTag: while true {
                switch self.getChar(from: &input) {
                case ">":
                    self.currentTagSelfClosing = true
                    self.emitTagAndGo(to: .data); continue loop
                case nil: self.emit(.error(.eofInTag), .eof); break loop
                case let c?:
                    self.emit(.error(.unexpectedSolidus))
                    self.reconsume(c, in: .beforeAttributeName); continue loop
                }
            }
            case .bogusComment: while true {
                switch self.getChar(from: &input) {
                case ">": self.emitCommentAndGo(to: .data); continue loop
                case "\0":
                    self.emit(.error(.unexpectedNull))
                    self.appendComment("\u{FFFD}")
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
    private mutating func createTag(with c: Character, kind: TagKind) {
        self.currentTagName = String(c)
        self.currentTagKind = kind
        self.currentAttrs.removeAll()
        self.currentTagSelfClosing = false
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func createTag(with s: String, kind: TagKind) {
        self.currentTagName = s
        self.currentTagKind = kind
        self.currentAttrs.removeAll()
        self.currentTagSelfClosing = false
    }

    @inline(__always)
    private mutating func appendTagName(_ c: Character) {
        self.currentTagName.append(c)
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func appendTagName(_ s: String) {
        self.currentTagName.append(s)
    }

    @inline(__always)
    private mutating func createAttr(with c: Character) {
        self.pushAttr()
        self.currentAttrName = String(c)
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func createAttr(with s: String) {
        self.pushAttr()
        self.currentAttrName = s
    }

    @inline(__always)
    private mutating func appendAttrName(_ c: Character) {
        self.currentAttrName.append(c)
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func appendAttrName(_ s: String) {
        self.currentAttrName.append(s)
    }

    @inline(__always)
    private mutating func appendAttrValue(_ c: Character) {
        self.currentAttrValue.append(c)
    }

    @inline(__always)
    private mutating func pushAttr() {
        guard !self.currentAttrName.isEmpty else { return }
        self.currentAttrs.append(.init(name: self.currentAttrName, value: self.currentAttrValue))
        self.currentAttrName.removeAll()
        self.currentAttrValue.removeAll()
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
        self.pushAttr()
        self.sink.process(
            .tag(
                Tag(
                    name: self.currentTagName,
                    kind: self.currentTagKind,
                    attrs: self.currentAttrs,
                    selfClosing: self.currentTagSelfClosing
                )
            )
        )
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
            let html = #"""
            <html lang="en">
            <head>
            <meta charset="UTF-8" />
            <title>title</title>
            </head>
            <body>
            hi
            </body>
            </html>
            """#

            let sink = TestSink()
            var tokenizer = Tokenizer(sink: sink)
            var iter = html.makeIterator()
            tokenizer.tokenize(&iter)

            let tokens: [Token] = [
                .tag(
                    Tag(
                        name: "html",
                        kind: .start,
                        attrs: [.init(name: "lang", value: "en")]
                    )
                ),
                "\n",
                .tag(Tag(name: "head", kind: .start)),
                "\n",
                .tag(
                    Tag(
                        name: "meta",
                        kind: .start,
                        attrs: [.init(name: "charset", value: "UTF-8")],
                        selfClosing: true
                    )
                ),
                "\n",
                .tag(Tag(name: "title", kind: .start)),
                "t",
                "i",
                "t",
                "l",
                "e",
                .tag(Tag(name: "title", kind: .end)),
                "\n",
                .tag(Tag(name: "head", kind: .end)),
                "\n",
                .tag(Tag(name: "body", kind: .start)),
                "\n",
                "h",
                "i",
                "\n",
                .tag(Tag(name: "body", kind: .end)),
                "\n",
                .tag(Tag(name: "html", kind: .end)),
                .eof,
            ]
            AssertEqual(tokens, other: sink.tokens)
        }
    }
#endif
