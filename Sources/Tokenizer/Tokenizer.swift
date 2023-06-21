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
    var currentComment: String
    var currentDOCTYPE: DOCTYPE

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
        self.currentComment = ""
        self.currentDOCTYPE = .init()
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
                case "\0": self.emit(.error(.unexpectedNull), "\0")
                case nil: self.emitEOF(); break loop
                case let c?: self.emit(c)
                }
            }
            case .rcdata: while true {
                switch self.getChar(from: &input) {
                case "&": self.consumeCharRef(); continue loop
                case "<": self.go(to: .rcdataLessThanSign); continue loop
                case "\0": self.emit(.error(.unexpectedNull), "\u{FFFD}")
                case nil: self.emitEOF(); break loop
                case let c?: self.emit(c)
                }
            }
            case .rawtext: while true {
                switch self.getChar(from: &input) {
                case "<": self.go(to: .rawtextLessThanSign); continue loop
                case "\0": self.emit(.error(.unexpectedNull), "\u{FFFD}")
                case nil: self.emitEOF(); break loop
                case let c?: self.emit(c)
                }
            }
            case .scriptData: while true {
                switch self.getChar(from: &input) {
                case "<": self.go(to: .scriptDatalessThanSign); continue loop
                case "\0": self.emit(.error(.unexpectedNull), "\u{FFFD}")
                case nil: self.emitEOF(); break loop
                case let c?: self.emit(c)
                }
            }
            case .plaintext: while true {
                switch self.getChar(from: &input) {
                case "\0": self.emit(.error(.unexpectedNull), "\u{FFFD}")
                case nil: self.emitEOF(); break loop
                case let c?: self.emit(c)
                }
            }
            case .tagOpen: while true {
                switch self.getChar(from: &input) {
                case "!": self.go(to: .markupDeclarationOpen); continue loop
                case "/": self.go(to: .endTagOpen); continue loop
                case "?": self.emitError(.unexpectedQuestionMark, createCommentWith: "?", goTo: .bogusComment); continue loop
                case nil: self.emit(.error(.eofBeforeTagName), "<", .eof); break loop
                case let c? where c.isASCII && c.isLetter: self.createStartTag(with: c.lowercased(), goTo: .tagName); continue loop
                case let c?: self.emit(.error(.invalidFirstChar), "<", reconsume: c, in: .data); continue loop
                }
            }
            case .endTagOpen: while true {
                switch self.getChar(from: &input) {
                case ">": self.emitError(.missingEndTagName, goTo: .data); continue loop
                case "\0": self.emitErrors(.invalidFirstChar, .unexpectedNull, createCommentWith: "\u{FFFD}", goTo: .bogusComment); continue loop
                case nil: self.emit(.error(.eofBeforeTagName), "<", "/", .eof); break loop
                case let c? where c.isASCII && c.isLetter: self.createEndTag(with: c.lowercased(), goTo: .tagName); continue loop
                case let c?: self.emitError(.invalidFirstChar, createCommentWith: c, goTo: .bogusComment); continue loop
                }
            }
            case .tagName: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": self.go(to: .beforeAttributeName); continue loop
                case "/": self.go(to: .selfClosingStartTag); continue loop
                case ">": self.emitTagAndGo(to: .data); continue loop
                case "\0": self.emitError(.unexpectedNull, appendTagName: "\u{FFFD}")
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
                case let c?: self.emit("<", reconsume: c, in: .rcdata); continue loop
                }
            }
            case .rcdataEndTagOpen: while true {
                switch self.getChar(from: &input) {
                case let c? where c.isASCII && c.isLetter: self.createEndTag(with: c, goTo: .rcdataEndTagName); continue loop
                case nil: self.emit("<", "/", .eof); break loop
                case let c?: self.emit("<", "/", reconsume: c, in: .rcdata); continue loop
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
                case "=": self.emitError(.unexpectedEqualsSign, createAttrWith: "=", goTo: .attributeName); continue loop
                case "\0": self.emitError(.unexpectedNull, createAttrWith: "\u{FFFD}", goTo: .attributeName); continue loop
                case "\"": self.emitError(.unexpectedCharInAttrName, createAttrWith: "\"", goTo: .attributeName); continue loop
                case "'": self.emitError(.unexpectedCharInAttrName, createAttrWith: "'", goTo: .attributeName); continue loop
                case "<": self.emitError(.unexpectedCharInAttrName, createAttrWith: "<", goTo: .attributeName); continue loop
                case nil: self.emit(.error(.eofInTag), .eof); break loop
                case let c? where c.isASCII && c.isUppercase: self.createAttr(with: c.lowercased(), goTo: .attributeName); continue loop
                case let c?: self.createAttr(with: c, goTo: .attributeName); continue loop
                }
            }
            case .attributeName: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": break
                case "/": self.go(to: .selfClosingStartTag); continue loop
                case ">": self.emitTagAndGo(to: .data); continue loop
                case "=": self.go(to: .beforeAttributeValue); continue loop
                case "\0": self.emitError(.unexpectedNull, appendAttrName: "\u{FFFD}")
                case "\"": self.emitError(.unexpectedCharInAttrName, appendAttrName: "\"")
                case "'": self.emitError(.unexpectedCharInAttrName, appendAttrName: "'")
                case "<": self.emitError(.unexpectedCharInAttrName, appendAttrName: "<")
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
                case "\0": self.emitError(.unexpectedNull, createAttrWith: "\u{FFFD}", goTo: .attributeName); continue loop
                case "\"": self.emitError(.unexpectedCharInAttrName, createAttrWith: "\"", goTo: .attributeName); continue loop
                case "'": self.emitError(.unexpectedCharInAttrName, createAttrWith: "'", goTo: .attributeName); continue loop
                case "<": self.emitError(.unexpectedCharInAttrName, createAttrWith: "<", goTo: .attributeName); continue loop
                case nil: self.emit(.error(.eofInTag), .eof); break loop
                case let c? where c.isASCII && c.isUppercase: self.createAttr(with: c.lowercased(), goTo: .attributeName); continue loop
                case let c?: self.createAttr(with: c, goTo: .attributeName); continue loop
                }
            }
            case .beforeAttributeValue: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": break
                case "\"": self.go(to: .attributeValueDoubleQuoted); continue loop
                case "'": self.go(to: .attributeValueSingleQuoted); continue loop
                case ">": self.emitError(.missingAttrValue, emitTagAndGoTo: .data); continue loop
                case nil: self.emit(.error(.eofInTag), .eof); break loop
                case let c?: self.reconsume(c, in: .attributeValueUnquoted); continue loop
                }
            }
            case .attributeValueDoubleQuoted: while true {
                switch self.getChar(from: &input) {
                case "\"": self.go(to: .afterAttributeValueQuoted); continue loop
                case "&": self.consumeCharRef(); continue loop
                case "\0": self.emitError(.unexpectedNull, appendAttrValue: "\u{FFFD}")
                case nil: self.emit(.error(.eofInTag), .eof); break loop
                case let c?: self.appendAttrValue(c)
                }
            }
            case .attributeValueSingleQuoted: while true {
                switch self.getChar(from: &input) {
                case "'": self.go(to: .afterAttributeValueQuoted); continue loop
                case "&": self.consumeCharRef(); continue loop
                case "\0": self.emitError(.unexpectedNull, appendAttrValue: "\u{FFFD}")
                case nil: self.emit(.error(.eofInTag), .eof); break loop
                case let c?: self.appendAttrValue(c)
                }
            }
            case .attributeValueUnquoted: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": self.go(to: .beforeAttributeName); continue loop
                case "&": self.consumeCharRef(); continue loop
                case ">": self.emitTagAndGo(to: .data); continue loop
                case "\0": self.emitError(.unexpectedNull, appendAttrValue: "\u{FFFD}")
                case nil: self.emit(.error(.eofInTag), .eof); break loop
                case "\"": self.emitError(.unexpectedCharInUnquotedAttrValue, appendAttrValue: "\"")
                case "'": self.emitError(.unexpectedCharInUnquotedAttrValue, appendAttrValue: "'")
                case "<": self.emitError(.unexpectedCharInUnquotedAttrValue, appendAttrValue: "\"")
                case "=": self.emitError(.unexpectedCharInUnquotedAttrValue, appendAttrValue: "\"")
                case "`": self.emitError(.unexpectedCharInUnquotedAttrValue, appendAttrValue: "\"")
                case let c?: self.appendAttrValue(c)
                }
            }
            case .afterAttributeValueQuoted: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": self.go(to: .beforeAttributeName); continue loop
                case "/": self.go(to: .selfClosingStartTag); continue loop
                case ">": self.emitTagAndGo(to: .data); continue loop
                case nil: self.emit(.error(.eofInTag), .eof); break loop
                case let c?: self.emitError(.missingSpaceBetweenAttrs, reconsume: c, in: .beforeAttributeName); continue loop
                }
            }
            case .selfClosingStartTag: while true {
                switch self.getChar(from: &input) {
                case ">": self.emitSelfClosingTagAndGo(to: .data); continue loop
                case nil: self.emit(.error(.eofInTag), .eof); break loop
                case let c?: self.emitError(.unexpectedSolidus, reconsume: c, in: .beforeAttributeName); continue loop
                }
            }
            case .bogusComment: while true {
                switch self.getChar(from: &input) {
                case ">": self.emitCommentAndGo(to: .data); continue loop
                case "\0": self.emitError(.unexpectedNull, appendComment: "\u{FFFD}")
                case nil: self.emitCommentAndEOF(); break loop
                case let c?: self.appendComment(c)
                }
            }
            case .markupDeclarationOpen: while true {
                if self.startsExact(&input, with: "--") == true {
                    self.clearCommentAndGo(to: .commentStart); continue loop
                } else if self.starts(&input, with: "doctype") == true {
                    self.go(to: .doctype); continue loop
                } else if self.startsExact(&input, with: "[CDATA[") == true {
                    if false {
                        // TODO: If there is an adjusted current node and it is not an element in the HTML namespace, then switch to the CDATA section state.
                        self.go(to: .cdataSection); continue loop
                    } else {
                        self.emitError(.cdataInHTML, createCommentWith: "[CDATA[", goTo: .bogusComment); continue loop
                    }
                } else {
                    self.emitError(.incorrectlyOpenedComment, clearCommentAndGoTo: .bogusComment); continue loop
                }
            }
            case .doctype: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": self.go(to: .beforeDOCTYPEName); continue loop
                case ">": self.reconsume(">", in: .beforeDOCTYPEName); continue loop
                case nil: self.emitErrorNewForceQuirksDOCTYPEAndEOF(.eofInDOCTYPE); break loop
                case let c?: self.emitError(.missingSpaceBeforeDOCTYPEName, reconsume: c, in: .beforeDOCTYPEName); continue loop
                }
            }
            case .beforeDOCTYPEName: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": break
                case "\0": self.emitError(.unexpectedNull, createDOCTYPEWith: "\u{FFFD}", goTo: .doctypeName); continue loop
                case ">": self.emitError(.missingDOCTYPEName, emitNewForceQuirksDOCTYPEAndGoTo: .data); continue loop
                case nil: self.emitErrorNewForceQuirksDOCTYPEAndEOF(.eofInDOCTYPE); break loop
                case let c? where c.isASCII && c.isUppercase: self.createDOCTYPE(with: c.lowercased(), goTo: .doctypeName); continue loop
                case let c?: self.createDOCTYPE(with: c, goTo: .doctypeName); continue loop
                }
            }
            case .doctypeName: while true {
                switch self.getChar(from: &input) {
                case "\t", "\n", "\u{0C}", " ": self.go(to: .afterDOCTYPEName); continue loop
                case ">": self.emitDOCTYPEAndGo(to: .data); continue loop
                case "\0": self.emitError(.unexpectedNull, appendDOCTYPEName: "\u{FFFD}")
                case nil: self.emitErrorForceQuirksDOCTYPEAndEOF(.eofInDOCTYPE); break loop
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
                    case "\0": self.emitErrors(.invalidCharSequence, .unexpectedNull, forceQuirksAndGoTo: .bogusDOCTYPE); continue loop
                    case nil: self.emitErrorForceQuirksDOCTYPEAndEOF(.eofInDOCTYPE); break loop
                    case _: self.emitError(.invalidCharSequence, forceQuirksAndGoTo: .bogusDOCTYPE); continue loop
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
            guard _move c == _move pc else {
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
    private mutating func emitError(_ error: __owned ParseError, goTo state: __owned State) {
        self.sink.process(.error(_move error))
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
    private mutating func emit(
        _ tokens: Token...,
        reconsume c: __owned Character,
        in state: __owned State
    ) {
        for token in tokens {
            self.sink.process(_move token)
        }
        self.reconsumeChar = _move c
        self.state = _move state
    }

    @inline(__always)
    private mutating func emitError(
        _ error: __owned ParseError,
        reconsume c: __owned Character,
        in state: __owned State
    ) {
        self.sink.process(.error(_move error))
        self.reconsumeChar = _move c
        self.state = _move state
    }

    @inline(__always)
    private mutating func consumeCharRef() {
        self.charRefTokenizer = .init()
    }

    @inline(__always)
    private mutating func emitError(
        _ error: __owned ParseError,
        clearCommentAndGoTo state: __owned State
    ) {
        self.sink.process(.error(_move error))
        self.currentComment = ""
        self.state = _move state
    }

    @inline(__always)
    private mutating func clearCommentAndGo(to state: __owned State) {
        self.currentComment = ""
        self.state = _move state
    }

    @inline(__always)
    private mutating func emitError(
        _ error: __owned ParseError,
        createCommentWith c: __owned Character
    ) {
        self.sink.process(.error(_move error))
        self.currentComment = String(_move c)
    }

    @inline(__always)
    private mutating func emitErrors(
        _ errors: ParseError...,
        createCommentWith c: __owned Character,
        goTo state: __owned State
    ) {
        for error in errors {
            self.sink.process(.error(_move error))
        }
        self.currentComment = String(_move c)
        self.state = _move state
    }

    @inline(__always)
    private mutating func emitError(
        _ error: __owned ParseError,
        createCommentWith c: __owned Character,
        goTo state: __owned State
    ) {
        self.sink.process(.error(_move error))
        self.currentComment = String(_move c)
        self.state = _move state
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func emitError(
        _ error: __owned ParseError,
        createCommentWith s: __owned String,
        goTo state: __owned State
    ) {
        self.sink.process(.error(_move error))
        self.currentComment = _move s
        self.state = _move state
    }

    @inline(__always)
    private mutating func appendComment(_ c: __owned Character) {
        self.currentComment.append(_move c)
    }

    @inline(__always)
    private mutating func emitError(
        _ error: __owned ParseError,
        appendComment c: __owned Character
    ) {
        self.sink.process(.error(_move error))
        self.currentComment.append(_move c)
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func createStartTag(with s: __owned String, goTo state: __owned State) {
        self.currentTagName = _move s
        self.currentTagKind = .start
        self.currentAttrs.removeAll()
        self.state = _move state
    }

    @inline(__always)
    private mutating func createEndTag(with c: __owned Character, goTo state: __owned State) {
        self.currentTagName = String(_move c)
        self.currentTagKind = .end
        self.currentAttrs.removeAll()
        self.state = _move state
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func createEndTag(with s: __owned String, goTo state: __owned State) {
        self.currentTagName = _move s
        self.currentTagKind = .end
        self.currentAttrs.removeAll()
        self.state = _move state
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
    private mutating func emitError(
        _ error: __owned ParseError,
        appendTagName c: __owned Character
    ) {
        self.sink.process(.error(_move error))
        self.currentTagName.append(_move c)
    }

    @inline(__always)
    private mutating func createAttr(with c: __owned Character, goTo state: __owned State) {
        self.pushAttr()
        self.currentAttrName = String(_move c)
        self.state = _move state
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func createAttr(with s: __owned String, goTo state: __owned State) {
        self.pushAttr()
        self.currentAttrName = _move s
        self.state = _move state
    }

    @inline(__always)
    private mutating func emitError(
        _ error: __owned ParseError,
        createAttrWith c: __owned Character,
        goTo state: __owned State
    ) {
        self.sink.process(.error(_move error))
        self.pushAttr()
        self.currentAttrName = String(_move c)
        self.state = _move state
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
    private mutating func emitError(
        _ error: __owned ParseError,
        appendAttrName c: __owned Character
    ) {
        self.sink.process(.error(_move error))
        self.currentAttrName.append(_move c)
    }

    @inline(__always)
    private mutating func appendAttrValue(_ c: __owned Character) {
        self.currentAttrValue.append(_move c)
    }

    @inline(__always)
    private mutating func emitError(
        _ error: __owned ParseError,
        appendAttrValue c: __owned Character
    ) {
        self.sink.process(.error(_move error))
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
        self.currentDOCTYPE = .init()
    }

    @inline(__always)
    private mutating func createDOCTYPE(
        with c: __owned Character,
        goTo state: __owned State
    ) {
        self.currentDOCTYPE = .init(name: String(_move c))
        self.state = _move state
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func createDOCTYPE(
        with s: __owned String,
        goTo state: __owned State
    ) {
        self.currentDOCTYPE = .init(name: _move s)
        self.state = _move state
    }

    @inline(__always)
    private mutating func emitError(
        _ error: __owned ParseError,
        createDOCTYPEWith c: __owned Character,
        goTo state: __owned State
    ) {
        self.sink.process(.error(_move error))
        self.currentDOCTYPE = .init(name: String(_move c))
        self.state = _move state
    }

    @inline(__always)
    private mutating func appendDOCTYPEName(_ c: __owned Character) {
        switch self.currentDOCTYPE.name {
        case .some: self.currentDOCTYPE.name?.append(_move c)
        case .none: self.currentDOCTYPE.name = String(_move c)
        }
    }

    @_disfavoredOverload
    @inline(__always)
    private mutating func appendDOCTYPEName(_ s: __owned String) {
        switch self.currentDOCTYPE.name {
        case .some: self.currentDOCTYPE.name?.append(_move s)
        case .none: self.currentDOCTYPE.name = _move s
        }
    }

    @inline(__always)
    private mutating func emitError(
        _ error: __owned ParseError,
        appendDOCTYPEName c: __owned Character
    ) {
        self.sink.process(.error(_move error))
        switch self.currentDOCTYPE.name {
        case .some: self.currentDOCTYPE.name?.append(_move c)
        case .none: self.currentDOCTYPE.name = String(_move c)
        }
    }

    @inline(__always)
    private mutating func emitError(
        _ error: __owned ParseError,
        forceQuirksAndGoTo state: __owned State
    ) {
        self.sink.process(.error(_move error))
        self.currentDOCTYPE.forceQuirks = true
        self.state = _move state
    }

    @inline(__always)
    private mutating func emitErrors(
        _ errors: ParseError...,
        forceQuirksAndGoTo state: __owned State
    ) {
        for error in errors {
            self.sink.process(.error(_move error))
        }
        self.currentDOCTYPE.forceQuirks = true
        self.state = _move state
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

    @_disfavoredOverload
    @inline(__always)
    private mutating func emit(_ tokens: Token...) {
        for token in tokens {
            self.sink.process(_move token)
        }
    }

    @inline(__always)
    private mutating func emit(_ tokens: Token..., goTo state: __owned State) {
        for token in tokens {
            self.sink.process(_move token)
        }
        self.state = _move state
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
                    selfClosing: false
                )
            )
        )
        self.state = _move state
    }

    @inline(__always)
    private mutating func emitError(
        _ error: __owned ParseError,
        emitTagAndGoTo state: __owned State
    ) {
        self.sink.process(.error(_move error))
        self.pushAttr()
        self.sink.process(
            .tag(
                Tag(
                    name: self.currentTagName,
                    kind: self.currentTagKind,
                    attrs: self.currentAttrs,
                    selfClosing: false
                )
            )
        )
        self.state = _move state
    }

    @inline(__always)
    private mutating func emitSelfClosingTagAndGo(to state: __owned State) {
        self.pushAttr()
        self.sink.process(
            .tag(
                Tag(
                    name: self.currentTagName,
                    kind: self.currentTagKind,
                    attrs: self.currentAttrs,
                    selfClosing: true
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
    private mutating func emitError(
        _ error: __owned ParseError,
        emitNewForceQuirksDOCTYPEAndGoTo state: __owned State
    ) {
        self.sink.process(.error(_move error))
        self.sink.process(.doctype(.init(forceQuirks: true)))
        self.state = _move state
    }

    @inline(__always)
    private mutating func emitDOCTYPEAndEOF() {
        self.sink.process(.doctype(self.currentDOCTYPE))
        self.sink.process(.eof)
    }

    @inline(__always)
    private mutating func emitErrorForceQuirksDOCTYPEAndEOF(_ error: __owned ParseError) {
        self.sink.process(.error(_move error))
        self.currentDOCTYPE.forceQuirks = true
        self.sink.process(.doctype(self.currentDOCTYPE))
        self.sink.process(.eof)
    }

    @inline(__always)
    private mutating func emitErrorNewForceQuirksDOCTYPEAndEOF(_ error: __owned ParseError) {
        self.sink.process(.error(_move error))
        self.sink.process(.doctype(.init(forceQuirks: true)))
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
                .doctype(.init(name: "html")),
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
