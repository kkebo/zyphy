public struct Tokenizer<Sink: TokenSink> {
    public var sink: Sink
    var state: State
    var reconsumeChar: Optional<Character>
    var charRefTokenizer: Optional<CharRefTokenizer>
    var currentTagName: String
    var currentTagKind: TagKind
    var currentAttrName: String
    var currentAttrValue: String
    var currentAttrs: [Attribute]
    var currentTagSelfClosing: Bool
    var currentComment: String
    var currentDOCTYPE: Optional<String>

    public init(sink: __owned Sink) {
        self.sink = _move sink
        self.state = .data
        self.reconsumeChar = nil
        self.charRefTokenizer = nil
        self.currentTagName = ""
        self.currentTagKind = .start
        self.currentAttrName = ""
        self.currentAttrValue = ""
        self.currentAttrs = []
        self.currentTagSelfClosing = false
        self.currentComment = ""
        self.currentDOCTYPE = nil
    }

    // TODO: Consider input type
    public mutating func tokenize(_ input: inout String.Iterator) {
        loop: while true {
            self.charRefTokenizer?.tokenize(&input)

            switch self.state {
            case .data: while true {
                switch self.getChar(from: &input) {
                case "&": self.consumeCharRef(); continue loop
                case "<": self.go(to: .tagOpen); continue loop
                case "\0":
                    self.emitError(.unexpectedNull)
                    self.emit("\0")
                case nil: self.emitEOF(); break loop
                case let c?: self.emit(c)
                }
            }
            case .rcdata: while true {
                switch self.getChar(from: &input) {
                case "&": self.consumeCharRef(); continue loop
                case "<": self.go(to: .rcdataLessThanSign); continue loop
                case "\0":
                    self.emitError(.unexpectedNull)
                    self.emit("\u{FFFD}")
                case nil: self.emitEOF(); break loop
                case let c?: self.emit(c)
                }
            }
            case .rawtext: while true {
                switch self.getChar(from: &input) {
                case "<": self.go(to: .rawtextLessThanSign); continue loop
                case "\0":
                    self.emitError(.unexpectedNull)
                    self.emit("\u{FFFD}")
                case nil: self.emitEOF(); break loop
                case let c?: self.emit(c)
                }
            }
            case .scriptData: while true {
                switch self.getChar(from: &input) {
                case "<": self.go(to: .scriptDatalessThanSign); continue loop
                case "\0":
                    self.emitError(.unexpectedNull)
                    self.emit("\u{FFFD}")
                case nil: self.emitEOF(); break loop
                case let c?: self.emit(c)
                }
            }
            case .plaintext: while true {
                switch self.getChar(from: &input) {
                case "\0":
                    self.emitError(.unexpectedNull)
                    self.emit("\u{FFFD}")
                case nil: self.emitEOF(); break loop
                case let c?: self.emit(c)
                }
            }
            case .tagOpen: while true {
                switch self.getChar(from: &input) {
                case "!": self.go(to: .markupDeclarationOpen); continue loop
                case "/": self.go(to: .endTagOpen); continue loop
                case "?":
                    self.emitError(.unexpectedQuestionMark)
                    self.createComment(with: "?")
                    self.go(to: .bogusComment); continue loop
                case nil:
                    self.emitError(.eofBeforeTagName)
                    self.emit("<")
                    self.emitEOF(); break loop
                case let c? where c.isASCII && c.isLetter:
                    self.createTag(with: c.lowercased(), kind: .start)
                    self.go(to: .tagName); continue loop
                case let c?:
                    self.emitError(.invalidFirstChar)
                    self.emit("<")
                    self.reconsume(c, in: .data); continue loop
                }
            }
            case .endTagOpen: while true {
                switch self.getChar(from: &input) {
                case ">":
                    self.emitError(.missingEndTagName)
                    self.go(to: .data); continue loop
                case "\0":
                    self.emitError(.invalidFirstChar)
                    self.emitError(.unexpectedNull)
                    self.createComment(with: "\u{FFFD}")
                    self.go(to: .bogusComment); continue loop
                case nil:
                    self.emitError(.eofBeforeTagName)
                    self.emit("<")
                    self.emit("/")
                    self.emitEOF(); break loop
                case let c? where c.isASCII && c.isLetter:
                    self.createTag(with: c.lowercased(), kind: .end)
                    self.go(to: .tagName); continue loop
                case let c?:
                    self.emitError(.invalidFirstChar)
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
                    self.emitError(.unexpectedNull)
                    self.appendTagName("\u{FFFD}")
                case nil:
                    self.emitError(.eofInTag)
                    self.emitEOF(); break loop
                case let c? where c.isASCII && c.isUppercase: self.appendTagName(c.lowercased())
                case let c?: self.appendTagName(c)
                }
            }
            case .rcdataLessThanSign: while true {
                switch self.getChar(from: &input) {
                case "/":
                    // TODO: Set the temporary buffer to the empty string
                    self.go(to: .rcdataEndTagOpen); continue loop
                case nil:
                    self.emit("<")
                    self.emitEOF(); break loop
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
                case nil:
                    self.emit("<")
                    self.emit("/")
                    self.emitEOF(); break loop
                case let c?:
                    self.emit("<")
                    self.emit("/")
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
                    self.emitError(.unexpectedEqualsSign)
                    self.createAttr(with: "=")
                    self.go(to: .attributeName); continue loop
                case "\0":
                    self.emitError(.unexpectedNull)
                    self.createAttr(with: "\u{FFFD}")
                    self.go(to: .attributeName); continue loop
                case "\"":
                    self.emitError(.unexpectedCharInAttrName)
                    self.createAttr(with: "\"")
                    self.go(to: .attributeName); continue loop
                case "'":
                    self.emitError(.unexpectedCharInAttrName)
                    self.createAttr(with: "'")
                    self.go(to: .attributeName); continue loop
                case "<":
                    self.emitError(.unexpectedCharInAttrName)
                    self.createAttr(with: "<")
                    self.go(to: .attributeName); continue loop
                case nil:
                    self.emitError(.eofInTag)
                    self.emitEOF(); break loop
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
                    self.emitError(.unexpectedNull)
                    self.appendAttrName("\u{FFFD}")
                case "\"":
                    self.emitError(.unexpectedCharInAttrName)
                    self.appendAttrName("\"")
                case "'":
                    self.emitError(.unexpectedCharInAttrName)
                    self.appendAttrName("'")
                case "<":
                    self.emitError(.unexpectedCharInAttrName)
                    self.appendAttrName("<")
                case nil:
                    self.emitError(.eofInTag)
                    self.emitEOF(); break loop
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
                    self.emitError(.unexpectedNull)
                    self.createAttr(with: "\u{FFFD}")
                    self.go(to: .attributeName); continue loop
                case "\"":
                    self.emitError(.unexpectedCharInAttrName)
                    self.createAttr(with: "\"")
                    self.go(to: .attributeName); continue loop
                case "'":
                    self.emitError(.unexpectedCharInAttrName)
                    self.createAttr(with: "'")
                    self.go(to: .attributeName); continue loop
                case "<":
                    self.emitError(.unexpectedCharInAttrName)
                    self.createAttr(with: "<")
                    self.go(to: .attributeName); continue loop
                case nil:
                    self.emitError(.eofInTag)
                    self.emitEOF(); break loop
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
                    self.emitError(.missingAttrValue)
                    self.emitTagAndGo(to: .data); continue loop
                case nil:
                    self.emitError(.eofInTag)
                    self.emitEOF(); break loop
                case let c?: self.reconsume(c, in: .attributeValueUnquoted); continue loop
                }
            }
            case .attributeValueDoubleQuoted: while true {
                switch self.getChar(from: &input) {
                case "\"": self.go(to: .afterAttributeValueQuoted); continue loop
                case "&": self.consumeCharRef(); continue loop
                case "\0":
                    self.emitError(.unexpectedNull)
                    self.appendAttrValue("\u{FFFD}")
                case nil:
                    self.emitError(.eofInTag)
                    self.emitEOF(); break loop
                case let c?: self.appendAttrValue(c)
                }
            }
            case .attributeValueSingleQuoted: while true {
                switch self.getChar(from: &input) {
                case "'": self.go(to: .afterAttributeValueQuoted); continue loop
                case "&": self.consumeCharRef(); continue loop
                case "\0":
                    self.emitError(.unexpectedNull)
                    self.appendAttrValue("\u{FFFD}")
                case nil:
                    self.emitError(.eofInTag)
                    self.emitEOF(); break loop
                case let c?: self.appendAttrValue(c)
                }
            }
            case .attributeValueUnquoted: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": self.go(to: .beforeAttributeName); continue loop
                case "&": self.consumeCharRef(); continue loop
                case ">": self.emitTagAndGo(to: .data); continue loop
                case "\0":
                    self.emitError(.unexpectedNull)
                    self.appendAttrValue("\u{FFFD}")
                case nil:
                    self.emitError(.eofInTag)
                    self.emitEOF(); break loop
                case "\"":
                    self.emitError(.unexpectedCharInUnquotedAttrValue)
                    self.appendAttrValue("\"")
                case "'":
                    self.emitError(.unexpectedCharInUnquotedAttrValue)
                    self.appendAttrValue("'")
                case "<":
                    self.emitError(.unexpectedCharInUnquotedAttrValue)
                    self.appendAttrValue("\"")
                case "=":
                    self.emitError(.unexpectedCharInUnquotedAttrValue)
                    self.appendAttrValue("\"")
                case "`":
                    self.emitError(.unexpectedCharInUnquotedAttrValue)
                    self.appendAttrValue("\"")
                case let c?: self.appendAttrValue(c)
                }
            }
            case .afterAttributeValueQuoted: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": self.go(to: .beforeAttributeName); continue loop
                case "/": self.go(to: .selfClosingStartTag); continue loop
                case ">": self.emitTagAndGo(to: .data); continue loop
                case nil:
                    self.emitError(.eofInTag)
                    self.emitEOF(); break loop
                case let c?:
                    self.emitError(.missingSpaceBetweenAttrs)
                    self.reconsume(c, in: .beforeAttributeName); continue loop
                }
            }
            case .selfClosingStartTag: while true {
                switch self.getChar(from: &input) {
                case ">":
                    self.currentTagSelfClosing = true
                    self.emitTagAndGo(to: .data); continue loop
                case nil:
                    self.emitError(.eofInTag)
                    self.emitEOF(); break loop
                case let c?:
                    self.emitError(.unexpectedSolidus)
                    self.reconsume(c, in: .beforeAttributeName); continue loop
                }
            }
            case .bogusComment: while true {
                switch self.getChar(from: &input) {
                case ">": self.emitCommentAndGo(to: .data); continue loop
                case "\0":
                    self.emitError(.unexpectedNull)
                    self.appendComment("\u{FFFD}")
                case nil: self.emitCommentAndEOF(); break loop
                case let c?: self.appendComment(c)
                }
            }
            case .markupDeclarationOpen: while true {
                if self.startsExact(&input, with: "--") == true {
                    self.clearComment()
                    self.go(to: .commentStart); continue loop
                } else if self.starts(&input, with: "doctype") == true {
                    self.go(to: .doctype); continue loop
                } else if self.startsExact(&input, with: "[CDATA[") == true {
                    if false {
                        // TODO: If there is an adjusted current node and it is not an element in the HTML namespace, then switch to the CDATA section state.
                        self.go(to: .cdataSection); continue loop
                    } else {
                        self.emitError(.cdataInHTML)
                        self.createComment(with: "[CDATA[")
                        self.go(to: .bogusComment); continue loop
                    }
                } else {
                    self.emitError(.incorrectlyOpenedComment)
                    self.clearComment()
                    self.go(to: .bogusComment); continue loop
                }
            }
            case .doctype: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": self.go(to: .beforeDOCTYPEName); continue loop
                case ">": self.reconsume(">", in: .beforeDOCTYPEName); continue loop
                case nil:
                    self.emitError(.eofInDOCTYPE)
                    self.createDOCTYPE()
                    // TODO: Set its force-quirks flag to on
                    self.emitDOCTYPEAndEOF(); break loop
                case let c?:
                    self.emitError(.missingSpaceBeforeDOCTYPEName)
                    self.reconsume(c, in: .beforeDOCTYPEName); continue loop
                }
            }
            case .beforeDOCTYPEName: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": break
                case "\0":
                    self.emitError(.unexpectedNull)
                    self.createDOCTYPE(with: "\u{FFFD}")
                    self.go(to: .doctypeName); continue loop
                case ">":
                    self.emitError(.missingDOCTYPEName)
                    self.createDOCTYPE()
                    // TODO: Set its force-quirks flag to on
                    self.emitDOCTYPEAndGo(to: .data); continue loop
                case nil:
                    self.emitError(.eofInDOCTYPE)
                    self.createDOCTYPE()
                    // TODO: Set its force-quirks flag to on
                    self.emitDOCTYPEAndEOF(); break loop
                case let c? where c.isASCII && c.isUppercase:
                    self.createDOCTYPE(with: c.lowercased())
                    self.go(to: .doctypeName); continue loop
                case let c?:
                    self.createDOCTYPE(with: c)
                    self.go(to: .doctypeName); continue loop
                }
            }
            case .doctypeName: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": self.go(to: .afterDOCTYPEName); continue loop
                case ">": self.emitDOCTYPEAndGo(to: .data); continue loop
                case "\0":
                    self.emitError(.unexpectedNull)
                    self.appendDOCTYPEName("\u{FFFD}")
                case nil:
                    self.emitError(.eofInDOCTYPE)
                    // TODO: Set the current DOCTYPE token's force-quirks flag to on
                    self.emitDOCTYPEAndEOF(); break loop
                case let c? where c.isASCII && c.isUppercase: self.appendDOCTYPEName(c.lowercased())
                case let c?: self.appendDOCTYPEName(c)
                }
            }
            case .afterDOCTYPEName: while true {
                if self.starts(&input, with: "public") == true {
                    self.go(to: .afterDOCTYPEPublicKeyword); continue loop
                } else if self.starts(&input, with: "system") == true {
                    self.go(to: .afterDOCTYPESystemKeyword); continue loop
                } else {
                    switch self.getChar(from: &input) {
                    case "\t", "\n", "\u{0C}", " ": break
                    case ">": self.emitDOCTYPEAndGo(to: .data); continue loop
                    case "\0":
                        self.emitError(.invalidCharSequence)
                        // TODO: Set the current DOCTYPE token's force-quirks flag to on
                        self.emitError(.unexpectedNull)
                        self.go(to: .bogusDOCTYPE); continue loop
                    case nil:
                        self.emitError(.eofInDOCTYPE)
                        // TODO: Set the current DOCTYPE token's force-quirks flag to on
                        self.emitDOCTYPEAndEOF(); break loop
                    case _:
                        self.emitError(.invalidCharSequence)
                        // TODO: Set the current DOCTYPE token's force-quirks flag to on
                        self.go(to: .bogusDOCTYPE); continue loop
                    }
                }
            }
            case .afterDOCTYPEPublicKeyword: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .beforeDOCTYPEPublicIdentifier: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .doctypePublicIdentifierDoubleQuoted: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .doctypePublicIdentifierSingleQuoted: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .afterDOCTYPEPublicIdentifier: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .betweenDOCTYPEPublicAndSystemIdentifiers: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .afterDOCTYPESystemKeyword: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .beforeDOCTYPESystemIdentifier: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .doctypeSystemIdentifierDoubleQuoted: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .doctypeSystemIdentifierSingleQuoted: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .afterDOCTYPESystemIdentifier: while true {
                switch self.getChar(from: &input) {
                case _: preconditionFailure("Not implemented")
                }
            }
            case .bogusDOCTYPE: while true {
                switch self.getChar(from: &input) {
                case ">": self.emitDOCTYPEAndGo(to: .data); continue loop
                case "\0": self.emitError(.unexpectedNull)
                case nil: self.emitDOCTYPEAndEOF(); break loop
                case _: break
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

    private mutating func startsExact(
        _ input: inout String.Iterator,
        with pattern: __owned some StringProtocol
    ) -> Bool? {
        let initial = input
        for pc in _move pattern {
            guard let c = input.next() else {
                input = _move initial
                return nil
            }
            guard c == pc else {
                input = _move initial
                return false
            }
        }
        return true
    }

    private mutating func starts(
        _ input: inout String.Iterator,
        with pattern: __owned some StringProtocol
    ) -> Bool? {
        let initial = input
        for pc in _move pattern {
            guard let c = input.next() else {
                input = _move initial
                return nil
            }
            guard c.lowercased() == pc.lowercased() else {
                input = _move initial
                return false
            }
        }
        return true
    }

    @inline(__always)
    private mutating func go(to state: __owned State) {
        self.state = _move state
    }

    @inline(__always)
    private mutating func reconsume(
        _ c: __owned Character,
        in state: __owned State
    ) {
        self.reconsumeChar = _move c
        self.state = _move state
    }

    @inline(__always)
    private mutating func consumeCharRef() {
        self.charRefTokenizer = .init()
    }

    @inline(__always)
    private mutating func clearComment() {
        self.currentComment = ""
    }

    @inline(__always)
    private mutating func createComment(with c: __owned Character) {
        self.currentComment = String(_move c)
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func createComment(with s: __owned String) {
        self.currentComment = _move s
    }

    @inline(__always)
    private mutating func appendComment(_ c: __owned Character) {
        self.currentComment.append(_move c)
    }

    @inline(__always)
    private mutating func createTag(
        with c: __owned Character,
        kind: __owned TagKind
    ) {
        self.currentTagName = String(_move c)
        self.currentTagKind = _move kind
        self.currentAttrs.removeAll()
        self.currentTagSelfClosing = false
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func createTag(
        with s: __owned String,
        kind: __owned TagKind
    ) {
        self.currentTagName = _move s
        self.currentTagKind = _move kind
        self.currentAttrs.removeAll()
        self.currentTagSelfClosing = false
    }

    @inline(__always)
    private mutating func appendTagName(_ c: __owned Character) {
        self.currentTagName.append(_move c)
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func appendTagName(_ s: __owned String) {
        self.currentTagName.append(_move s)
    }

    @inline(__always)
    private mutating func createAttr(with c: __owned Character) {
        self.pushAttr()
        self.currentAttrName = String(_move c)
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func createAttr(with s: __owned String) {
        self.pushAttr()
        self.currentAttrName = _move s
    }

    @inline(__always)
    private mutating func appendAttrName(_ c: __owned Character) {
        self.currentAttrName.append(_move c)
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func appendAttrName(_ s: __owned String) {
        self.currentAttrName.append(_move s)
    }

    @inline(__always)
    private mutating func appendAttrValue(_ c: __owned Character) {
        self.currentAttrValue.append(_move c)
    }

    @inline(__always)
    private mutating func pushAttr() {
        guard !self.currentAttrName.isEmpty else { return }
        self.currentAttrs.append(.init(name: self.currentAttrName, value: self.currentAttrValue))
        self.currentAttrName.removeAll()
        self.currentAttrValue.removeAll()
    }

    @inline(__always)
    private mutating func createDOCTYPE() {
        self.currentDOCTYPE = nil
    }

    @inline(__always)
    private mutating func createDOCTYPE(with c: __owned Character) {
        self.currentDOCTYPE = String(_move c)
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func createDOCTYPE(with s: __owned String) {
        self.currentDOCTYPE = _move s
    }

    @inline(__always)
    private mutating func appendDOCTYPEName(_ c: __owned Character) {
        switch self.currentDOCTYPE {
        case .some: self.currentDOCTYPE?.append(_move c)
        case .none: self.currentDOCTYPE = String(_move c)
        }
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func appendDOCTYPEName(_ s: __owned String) {
        switch self.currentDOCTYPE {
        case .some: self.currentDOCTYPE?.append(_move s)
        case .none: self.currentDOCTYPE = _move s
        }
    }

    @inline(__always)
    private mutating func emitError(_ error: __owned ParseError) {
        self.sink.process(.error(_move error))
    }

    @inline(__always)
    private mutating func emitEOF() {
        self.sink.process(.eof)
    }

    @inline(__always)
    private mutating func emit(_ c: __owned Character) {
        self.sink.process(.char(_move c))
    }

    @inline(__always)
    private mutating func emitTagAndGo(to state: __owned State) {
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
        self.state = _move state
    }

    @inline(__always)
    private mutating func emitCommentAndGo(to state: __owned State) {
        self.sink.process(.comment(self.currentComment))
        self.state = _move state
    }

    @inline(__always)
    private mutating func emitCommentAndEOF() {
        self.sink.process(.comment(self.currentComment))
        self.sink.process(.eof)
    }

    @inline(__always)
    private mutating func emitDOCTYPEAndGo(to state: __owned State) {
        self.sink.process(.doctype(self.currentDOCTYPE))
        self.state = _move state
    }

    @inline(__always)
    private mutating func emitDOCTYPEAndEOF() {
        self.sink.process(.doctype(self.currentDOCTYPE))
        self.sink.process(.eof)
    }
}

#if TESTING_ENABLED
    import Foundation
    import PlaygroundTester

    struct TestSink {
        var tokens = [Token]()
    }

    extension TestSink: TokenSink {
        mutating func process(_ token: __owned Token) {
            self.tokens.append(_move token)
        }
    }

    @objcMembers
    final class TokenizerTests: TestCase {
        func testTokenizeBasicHTML() {
            let html = #"""
            <!DOCTYPE html>
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
            var tokenizer = Tokenizer(sink: _move sink)
            var iter = html.makeIterator()
            tokenizer.tokenize(&iter)

            let tokens: [Token] = [
                .doctype("html"),
                "\n",
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
            AssertEqual(tokens, other: tokenizer.sink.tokens)
        }
    }
#endif
